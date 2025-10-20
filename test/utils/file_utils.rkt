#lang racket
(require racket/port)
(require racket/runtime-path)

(provide read-file-into-string
         read-corpus
         corpus_path
         local_file
         is_valid_shrubbery?
         process-file
         main)

(define/contract (is_valid_shrubbery? s)
  (-> string? boolean?)
  (not (string-prefix? s "#lang")))

(define/contract (process-file s)
  (-> string? string?)
  (let ([str_xs (string-split s "\n")]) (string-join (filter is_valid_shrubbery? str_xs) "\n")))

(define/contract (read-corpus dir)
  (-> path? (listof path?))
  (for/list ([f (in-directory dir)]
             #:when (regexp-match? #rx"\\.rhm$" f))
    f))

(define/contract (read-file-into-string path)
  (-> path? string?)
  (process-file (file->string path)))

;;; Debugging
(define-runtime-path corpus_path "../corpus")
(define all_paths (read-corpus corpus_path))
(define local_file (car all_paths))
(define content (read-file-into-string local_file))

(define/contract (main)
  (-> void?)
  (display content))

;;; Local tests
(module+ main
  (main))
