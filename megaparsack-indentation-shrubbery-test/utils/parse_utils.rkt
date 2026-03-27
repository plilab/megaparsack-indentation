#lang racket
(require shrubbery/parse)
(require rackunit)
(require megaparsack)
(require megaparsack-indentation-shrubbery)
(require sexp-diff)
(require data/either)
(require "./file_utils.rkt")

(provide
 parse-with-both
 parse-our
 parse-reference
 check-sexp-equal?)

;;; Racket shrubbery API to parse the program
(define (parse-reference s)
  (define in (open-input-string s))
  (parse-all in))

(define (parse-with-both filepath)
 (call-with-input-file
   filepath
   (lambda (in)
     (port-count-lines! in)
     (skip-lang-prefix! in)
     ; Store location after #lang line (or start if #lang doesn't exist) to reset between tests
     (define code-start (file-position in))

     (define our-parse
       (with-handlers ([exn:fail? (lambda (e) (failure e))])
         (shrubbery-parser in)))

     ; Reset back to after the #lang line 
     (file-position in code-start)

     (define reference-parse
       (with-handlers ([exn:fail? (lambda (e) (failure e))])
         (success (syntax->datum (parse-all in)))))
     (values our-parse reference-parse))))

(define (parse-our code)
  (parse-result! (shrubbery-parser code)))

(define (check-sexp-equal? actual expected)
  (with-check-info*
      (list
       (make-check-message (string-info (pretty-format (sexp-diff expected actual #:old-marker '#:actual #:new-marker '#:expected)))))
    (lambda ()
      (unless (equal? actual expected)
        (fail-check)))))
