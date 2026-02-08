#lang racket
(require racket/runtime-path)
(require "./file_utils.rkt")
(require "./parse_utils.rkt")

(define-runtime-path corpus_path "../corpus")

(define (print_expected_sexp)
  (define all_paths (read-corpus corpus_path))
  (for-each
   (lambda (app_path)
     (define code (read-file-into-string app_path))
     (define sexp (syntax->datum (parse-string-self-defined code)))
     (define out-path (string-append (path->string app_path) ".sexp"))
     (call-with-output-file out-path
       (lambda (out)
         (pretty-print sexp out))
       #:exists 'replace))
   all_paths))
