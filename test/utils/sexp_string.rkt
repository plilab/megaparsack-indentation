#lang racket
(require racket/runtime-path)
(require "./file_utils.rkt")
(require "./parse_utils.rkt")

;;; Generate expected sexp ast and print it into file with extension .sexp

;;; Define the relative paths of the repository of rhm code that wants to return sexp
(define-runtime-path corpus_path "../sample_rangen")

;;; Stores string format of sexp to a file with an extension of .sexp
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

(module+ main 
  (print_expected_sexp)
)