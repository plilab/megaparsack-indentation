#lang racket/base

; TODO Check if the file already exists and has the correct SHA

(require
  racket/cmdline
  racket/generator
  racket/string
  file/sha1
  json

  dotenv
  net/http-easy)

(dotenv-load!)
(current-logger (make-logger 'corpus-generator (current-logger)))


;;; All SHAs for files in this program are git blob SHA-1's. That is what
;;; github's API returns.

(define GITHUB_API_TOKEN
  (let ([value (getenv "CORPUS_GITHUB_API_TOKEN")])
    (if (not value)
        (error "Could not load the GitHub API token")
        value)))
(define RATELIMIT_INTERVAL_S 5)



(define new-corpus? (make-parameter #f))
(define manifest-file (make-parameter "manifest.jsonl"))

(define _args
  (command-line
    #:once-each
    ["--create" "Create a new corpus"
     (new-corpus? #t)]
    ["--manifest-file" manifest "Location of the manifest file (default: manifest.jsonl)"
     (manifest-file (resolve-path manifest))]
    #:args args
    args))



(define (make-rate-limited-get interval-s)
  (define last-call (box 0))
  (define ratelimit-wait (box 0))

  (define (get-int-header response symbol)
    (cond
      [(response-headers-ref response symbol)
       => (lambda (header-value) (string->number (bytes->string/utf-8 header-value)))]
      [else
       (log-fatal "Header ~a not found" symbol)
       (error "Nonexistent header")]))

  (make-keyword-procedure
    (lambda (keywords keyword-arguments . positionals)

      (define now (current-seconds))
      (define elapsed-time (- now (unbox last-call)))
      (define sleepytime (max (+ (- (unbox ratelimit-wait) now) 10)
                              (max 0 (- interval-s elapsed-time))))
      (sleep sleepytime)
      (set-box! last-call (+ sleepytime now))
      (set-box! ratelimit-wait 0)

      (define response (keyword-apply get keywords keyword-arguments positionals))

      (define status-code (response-status-code response))
      (cond
        [(not (= status-code 200))
         (log-fatal "Could not get resource ~a: status code ~a"
                    (car positionals)
                    status-code)
         (error "Non-success status-code")]
        [else
         (when (= (get-int-header response 'x-ratelimit-remaining) 0)
           (set-box! ratelimit-wait (get-int-header response 'x-ratelimit-reset)))
         response]))))

(define search-get (make-rate-limited-get RATELIMIT_INTERVAL_S))



(define (binary-search-count-under-1000 size-lower-bound size-upper-bound)
  (let loop ([low size-lower-bound]
             [high size-upper-bound])
    (define mid (+ (quotient (- high low) 2) low))

    (define query-string (format "size:~a..~a rhombus extension:rhm" size-lower-bound mid))
    (log-warning "Fetching query ~v" query-string)
    (define response (search-get "https://api.github.com/search/code"
                                 #:params `((q . ,query-string))
                                 #:auth (bearer-auth GITHUB_API_TOKEN)
                                 #:timeouts (make-timeout-config #:request 120)))

    (define json (response-json response))
    (when (eof-object? json)
      (log-fatal "JSON was not returned by http request")
      (error "JSON was not returned by http request"))

    (define count (hash-ref json 'total_count))
    (log-warning "Got ~a entries for range low=~a to=~a" count size-lower-bound mid)
    (cond
      [(and (>= count 500) (< count 1000)) (values response mid)]
      [(<= (- high low) 1)
       (when (> count 1000) (log-warning "Number of entries > 1000 for size = ~aB" low))
       (values response mid)]
      [(< count 500) (loop mid high)]
      [(>= count 1000) (loop low mid)])))

(define (item->manifest item)
  (define path (hash-ref item 'path))
  (define sha (hash-ref item 'sha))
  (define commit-hash (cadr (regexp-match #px"[?&]ref=([a-f0-9]+)" (hash-ref item 'url))))
  (define repo-name (hash-ref (hash-ref item 'repository) 'full_name))
  (hash
    'path path
    'sha sha
    'commit_hash commit-hash
    'repo_name repo-name))

(define (get-next-page-link link-header-bytes)
  (define value (bytes->string/utf-8 link-header-bytes))
  (for/or ([part (in-list (string-split value ","))])
    (define m (regexp-match #px"<([^>]*)>;\\s*rel=\"([^\"]*)\"" part))
    (and m
         (string=? (caddr m) "next")
         (cadr m))))

(define (manifest-from-pages first-response)
  (generator ()
    (let loop ([response first-response])
      (define json (response-json response))
      (define items (hash-ref (response-json response) 'items))

      (for ([item items])
        (yield (item->manifest item)))
      (define link-header (response-headers-ref response 'link))
      (cond
        [(and link-header (get-next-page-link link-header))
         => (lambda (next) (loop (search-get next
                                             #:auth (bearer-auth GITHUB_API_TOKEN)
                                             #:timeouts (make-timeout-config #:request 120))))]))))



(define manifest-new-generator
  (generator ()
    (define min-size 1)
    ;; [Limit defined by
    ;; GitHub](https://docs.github.com/en/search-github/searching-on-github/searching-code#considerations-for-code-search).
    ;; It says 384KB, that may be misspelled kibibytes, but I'll assume the
    ;; lower SI value. The documentation makes it seems like this range is
    ;; exclusive.
    (define max-size 30000)
    (let loop ([searched-upper-bound min-size])
      (define-values (response new-searched-upper-bound)
        (binary-search-count-under-1000 searched-upper-bound max-size))
      (define json (response-json response))
      (cond
        [(or (= 0 (hash-ref json 'total_count))
             (= new-searched-upper-bound max-size))
         (log-warning "Exhausted binary search range")]
        [else
         (for ([i (in-producer
                    (manifest-from-pages response)
                    (void))])
           (yield i))
         (loop new-searched-upper-bound)]))))

(define (manifest-from-file)
  (define file-name (manifest-file))
  (log-warning "Reading from manifest file ~v" file-name)

  (define entries
    (call-with-input-file* file-name
      (lambda (in)
        ;; in-port repeatedly calls read-json on 'in' until it hits eof
        (for/list ([entry (in-port read-json in)])
          entry))))

  (log-warning "Finished reading manifest file")
  entries)


(define (download-file-from-manifest-entry corpus-directory entry)
  (define path (hash-ref entry 'path))
  (define sha (hash-ref entry 'sha))
  (define commit-hash (hash-ref entry 'commit_hash))
  (define repo-name (hash-ref entry 'repo_name))

  (define download-url
    (format "https://raw.githubusercontent.com/~a/~a/~a" repo-name commit-hash path))
  (define response (get download-url))
  (define file-data (response-body response))

  (define header (string->bytes/utf-8 (format "blob ~a\0" (bytes-length file-data))))
  (define actual-sha
    (bytes->hex-string (sha1-bytes (open-input-bytes (bytes-append header file-data)))))

  (cond
    [(equal? sha actual-sha)
     (define filename (format "~a/~a.rhm" corpus-directory sha))
     (log-warning "Writing file ~a" filename)
     (call-with-output-file filename
       #:exists 'replace
       (lambda (out)
         (write-bytes file-data out)))
     (log-warning "Wrote file ~a" filename)
     filename]
    [else
     (log-error "Git blob SHA-1 hash does not match: expected ~a, got ~a. Skipping" sha actual-sha)
     #f]))

(define (write-manifest-entry out entry)
  (write-json entry out)
  (newline out))

(define (create-new-corpus corpus-directory)
  (call-with-output-file (manifest-file)
    #:exists 'truncate
    (lambda (out)
      (for ([entry (in-producer manifest-new-generator (void))])
        (define sha (hash-ref entry 'sha))
        (cond
          [(download-file-from-manifest-entry corpus-directory entry)
           => (lambda (filename)
                (log-warning "Adding manifest entry for ~a at ~a" sha filename)
                (write-manifest-entry out entry))]
          [else (log-warning "Skipping manifest entry")])))))

(define (regenerate-corpus corpus-directory)
  (for ([entry (in-list (manifest-from-file))])
    (define sha (hash-ref entry 'sha))
    (cond
      [(download-file-from-manifest-entry corpus-directory entry)
       => (lambda (filename)
            (log-warning "Retrieved file for ~a at ~a" sha filename))]
      [else (log-error "Couldn't get file for ~a" sha)])))



(module+ main
  (define corpus-directory "corpus")
  (unless (directory-exists? corpus-directory)
    (make-directory corpus-directory))
  (if (new-corpus?)
      (create-new-corpus corpus-directory)
      (regenerate-corpus corpus-directory)))

