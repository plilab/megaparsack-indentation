import io
from pathlib import Path
import re
import time
from typing import ClassVar
from collections import defaultdict
from collections.abc import Generator
import urllib.parse
import os
import logging
import zipfile

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

def github_get(url: httpx.URL) -> httpx.Response:
    while True:
        r = httpx.get(url, headers={"Authorization": f"Bearer {GITHUB_API_TOKEN}"}, follow_redirects=True)
    
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
            time.sleep(wait)
            continue

        if r.is_error:
            logger.error(r.json())
            r.raise_for_status()

        return r

def get_pages():
    url = httpx.URL(ROOT).join(API_SEARCH).copy_with(query=f"q={BASE_QUERY}".encode())
    pattern = re.compile(r'(?<=<)([\S]*)(?=>; rel="next")', re.IGNORECASE)

    while True:
        logger.info(f"Getting page {url}")
        r = github_get(url)

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

def make_repo_listing(items_generator: Generator[list[Item], None, None]) -> dict[Repository, list[Item]]:
    ans: dict[Repository, list[Item]] = defaultdict(list)
    for items in items_generator:
        for item in items:
            ans[item.repository].append(item)
    return ans
        

def fetcher(repo: Repository) -> bytes:
    r = github_get(httpx.URL(f"{ROOT}repos/{repo.owner.login}/{repo.name}/zipball"))
    return r.content

def write_file(item: Item, manifest_f: io.TextIOBase, data: bytes):
    base, rest = item.sha[:2], item.sha[2:]

    dest = Path(f"files/{base}/{rest}.rhm")
    logging.info(f"Writing file: {dest}")
    dest.parent.mkdir(parents = True, exist_ok=True)

    with open(dest, "wb") as f:
        _ = f.write(data)

    _ = manifest_f.write(item.model_dump_json() + "\n")


def processor(repo_listing: dict[Repository, list[Item]], repo: Repository, data: bytes, manifest_f: io.TextIOBase):
    while True:
        items = repo_listing[repo]

        with zipfile.ZipFile(io.BytesIO(data)) as zf:
            basedir = zf.namelist()[0]
            
            for item in items:

                src = f"{basedir}{item.path}"
                with zf.open(src) as file:
                    file_data = file.read()

                _ = write_file(item, manifest_f, file_data)


def main():
    repo_listing = make_repo_listing(get_pages())
    logger.info(repo_listing)

    with open("manifest.jsonl", "a") as manifest_f:
        for repo in repo_listing.keys():
            data = fetcher(repo)
            processor(repo_listing, repo, data, manifest_f)


if __name__ == "__main__":
    main()
