#lang racket
(require racket/contract)
(require rackunit)

(require "file_utils.rkt")
(require "shrubbery_parse.rkt")

(define s1 (read-file-into-string local_file))
(define sexp1 (syntax->datum (parse-string s1)))
(test-begin
  (check-sexps-equal? sexp1 sexp1)
  (check-sexps-equal? sexp1 (cdr sexp1)))
