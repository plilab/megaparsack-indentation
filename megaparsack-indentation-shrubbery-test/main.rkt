#lang racket/base
(require racket/cmdline)
(require racket/runtime-path)
(require racket/match)
(require "./utils/file_utils.rkt")
(require "./utils/parse_utils.rkt")
(require rackunit)
(require data/either)
(require megaparsack)

(provide run-rhombus-compatibility-tests)

(define-runtime-path test-path "./cases/")

;; Creates a test case to compare between our parser and the reference parser
(define (make-comparative-test filepath)
  (test-case
    (path->string filepath)
    (define-values (our-parse reference-parse) (parse-with-both filepath))
    (cond
      [(and (failure? our-parse) (failure? reference-parse))
       (fail-check (format "Both failed"))]
      [(failure? our-parse) (parse-result! our-parse)]
      [(failure? reference-parse) (raise (from-either reference-parse))]
      [else (check-sexp-equal? (from-either reference-parse) (from-either our-parse))])))


(define (run-rhombus-compatibility-tests paths)
  (for ([path paths])
    (match (file-or-directory-type path #t)
      [(or 'file 'link) (make-comparative-test path)]
      [(or 'directory 'directory-link)
       (for ([filename (read-corpus path)])
         (make-comparative-test filename))]
      [_ (assert-unreachable)])))

(module+ test

  (define command-line-paths
    (map string->path
         (command-line
           #:args files-and-directories
           files-and-directories)))

  (run-rhombus-compatibility-tests (if (null? command-line-paths) (list test-path) command-line-paths)))
