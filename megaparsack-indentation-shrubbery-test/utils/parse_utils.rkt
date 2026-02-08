#lang racket
(require shrubbery/parse)
(require rackunit)
(require racket/contract)
(require megaparsack)
(require megaparsack-indentation-shrubbery)
(require sexp-diff)

(provide
 parse-our
 parse-reference
 check-sexp-equal?)

;;; Racket shrubbery API to parse the program
(define (parse-reference s)
  (with-handlers ([exn:fail? (lambda (exn) (printf "Parse error: ~a\n" (exn-message exn)))])
    (define in (open-input-string s))
    (parse-all in)))

(define (parse-our code)
  (parse-result! (shrubbery-parser code)))

(define (check-sexp-equal? actual expected #:actual-marker [actual-marker '#:actual] #:expected-marker [expected-marker '#:expected])
  (with-check-info*
      (list
       (make-check-message (string-info (pretty-format (sexp-diff actual expected #:old-marker actual-marker #:new-marker expected-marker)))))
    (lambda ()
      (unless (equal? actual expected)
        (fail-check)))))
