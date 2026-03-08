import io
from pathlib import Path
import re
import time
from typing import ClassVar
from collections import defaultdict
import urllib.parse
import asyncio
import os
import logging
import zipfile

import aiofiles
from aiofiles.threadpool.text import AsyncTextIOWrapper
from aiolimiter import AsyncLimiter
import httpx
from dotenv import load_dotenv
from pydantic import BaseModel, ConfigDict, TypeAdapter

#### Logging

logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)


#### Env

if(not load_dotenv()):
    raise RuntimeError("Could not load env")


GITHUB_API_TOKEN = os.environ["CORPUS_GITHUB_API_TOKEN"]

ROOT = httpx.URL("https://api.github.com/")
API_SEARCH = httpx.URL("search/code")
BASE_QUERY = r'rhombus+in:file+extension:rhm'

class Owner(BaseModel):
    model_config: ClassVar[ConfigDict] = ConfigDict(extra="ignore", frozen=True)
    
    login: str

class Repository(BaseModel):
    model_config: ClassVar[ConfigDict] = ConfigDict(extra="ignore", frozen=True)

    name: str
    owner: Owner

class Item(BaseModel):
    model_config: ClassVar[ConfigDict] = ConfigDict(extra="ignore", frozen=True)

    name: str
    path: str
    sha: str
    repository: Repository

async def github_get(client: httpx.AsyncClient, url: httpx.URL, limiter: AsyncLimiter) -> httpx.Response:
    while True:
        async with limiter:
            r = await client.get(url, headers={"Authorization": f"Bearer {GITHUB_API_TOKEN}"}, follow_redirects=True)
        
        if r.status_code == 429 or r.status_code == 403:
            logger.warning(f"Rate limited. Headers: { {k: v for k, v in r.headers.items() if 'rate' in k.lower() or 'retry' in k.lower()} }")

            if "Retry-After" in r.headers:
                wait = float(r.headers["Retry-After"])
            elif "X-RateLimit-Reset" in r.headers:
                wait = max(0, float(r.headers["X-RateLimit-Reset"]) - time.time())
            else:
                wait = 60

            if wait == 0:
                wait = 60

            logger.warning(f"Rate limited, waiting {wait:.1f}s")
            await asyncio.sleep(wait)
            continue  # retry

        if r.is_error:
            logger.error(r.json())
            r.raise_for_status()

        return r

async def get_pages(client: httpx.AsyncClient, limiter: AsyncLimiter):
    url = httpx.URL(ROOT).join(API_SEARCH).copy_with(query=f"q={BASE_QUERY}".encode())
    pattern = re.compile(r'(?<=<)([\S]*)(?=>; rel="next")', re.IGNORECASE)

    while True:
        logger.info(f"Getting page {url}")
        r = await github_get(client, url, limiter)

        json = r.json()
        items = TypeAdapter(list[Item]).validate_python(json["items"])
        logger.info([(item.name, item.repository.name, item.repository.owner.login) for item in items])
        assert len(items) > 0
        yield items

        if json["incomplete_results"]:
            logger.warning("Incomplete results from github")

        if "link" not in r.headers or 'rel="next"' not in r.headers["link"]:
            break
        match = pattern.search(urllib.parse.unquote(r.headers["link"]))
        if not match:
            raise ValueError(f"link header does not match format: {r.headers["link"]}")
        url = httpx.URL(match.group(1))

def process_items(items: list[Item]) -> dict[Repository, list[Item]]:
    ans: dict[Repository, list[Item]] = defaultdict(list)
    for item in items:
        ans[item.repository].append(item)
    return ans
        

async def fetcher(client: httpx.AsyncClient, repo: Repository, queue: asyncio.Queue[tuple[Repository, bytes]], limiter: AsyncLimiter):
    r = await github_get(client, httpx.URL(f"{ROOT}repos/{repo.owner.login}/{repo.name}/zipball"), limiter)
    await queue.put((repo, r.content))

async def write_file(item: Item, manifest_f: AsyncTextIOWrapper, data: bytes, lock: asyncio.Lock):
    base, rest = item.sha[:2], item.sha[2:]

    dest = Path(f"files/{base}/{rest}.rhm")
    logging.info(f"Writing file: {dest}")
    dest.parent.mkdir(parents = True, exist_ok=True)

    async with aiofiles.open(dest, "wb") as f:
        _ = await f.write(data)

    async with lock:
        _ = await manifest_f.write(item.model_dump_json() + "\n")


async def processor(repo_listing: dict[Repository, list[Item]], manifest_f: AsyncTextIOWrapper, queue: asyncio.Queue[tuple[Repository, bytes]], lock: asyncio.Lock):
    while True:
        repo, data = await queue.get()
        items = repo_listing[repo]

        with zipfile.ZipFile(io.BytesIO(data)) as zf:
            basedir = zf.namelist()[0]
            
            tasks: list[asyncio.Task[None]] = []
            for item in items:

                src = f"{basedir}{item.path}"
                with zf.open(src) as file:
                    file_data = file.read()

                tasks.append(asyncio.create_task(write_file(item, manifest_f, file_data, lock)))

            _ = await asyncio.gather(*tasks)

        queue.task_done()


async def main():
    limiter = AsyncLimiter(max_rate=5, time_period=60)
    async with httpx.AsyncClient() as client:
        tasks = [asyncio.create_task(asyncio.to_thread(process_items, items)) async for items in get_pages(client, limiter)]

        results = await asyncio.gather(*tasks)
        repo_listing: dict[Repository, list[Item]] = defaultdict(list)
        for result in results:
            for k, v in result.items():
                repo_listing[k].extend(v)
        logger.info(repo_listing)
        
        queue: asyncio.Queue[tuple[Repository, bytes]] = asyncio.Queue(maxsize = 10)

        fetchers = [asyncio.create_task(fetcher(client, repo, queue, limiter)) for repo in repo_listing.keys()]
        lock = asyncio.Lock()
        async with aiofiles.open("manifest.jsonl", "a") as manifest_f:
            processors = [asyncio.create_task(processor(repo_listing, manifest_f, queue, lock)) for _ in range(3)]
        
            _ = await asyncio.gather(*fetchers)
            await queue.join()
        for p in processors:
            _ = p.cancel()
        _ = await asyncio.gather(*processors, return_exceptions=True)



if __name__ == "__main__":
    asyncio.run(main())
