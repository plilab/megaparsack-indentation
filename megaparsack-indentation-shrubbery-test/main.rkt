#lang racket/base
(require racket/cmdline)
(require racket/runtime-path)
(require racket/match)
(require "./utils/file_utils.rkt")
(require "./utils/parse_utils.rkt")
(require rackunit)

;;; Main loop
(define-runtime-path cases-path "cases")

(define files-to-parse
  (command-line
   #:args files-and-directories
   files-and-directories))

(define (make-test-from-file filename)
  (test-case
   (path->string filename)
   (define code (read-file-into-string filename))
   (define reference-parsed-val (syntax->datum (parse-reference code)))
   (define our-parsed-val (parse-our code))
   (check-sexp-equal? reference-parsed-val our-parsed-val)))

(define (run-rhombus-compatibility-tests paths)
  (for ([path paths])
    (match (file-or-directory-type path #t)
      [(or 'file 'link) (make-test-from-file path)]
      [(or 'directory 'directory-link)
       (for ([filename (read-corpus path)])
         (make-test-from-file filename))]
      [_ (assert-unreachable)])))

(module+ test
  (define input-paths
    (match files-to-parse
      ['() (list cases-path)]
      [paths (map string->path paths)]))

  (run-rhombus-compatibility-tests input-paths))
