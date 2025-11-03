;;; Utilize the Quickcheck testing API to compare the behavior of parsers
;;; Instead of directly printing all the sexps out
#lang racket
(require megaparsack-indentation-shrubbery)
(require megaparsack)
(require megaparsack/text)
(require megaparsack-indentation)
(require quickcheck)
(require rackunit)
(require rackunit/text-ui)
(require shrubbery)
(require shrubbery/parse)
(require shrubbery/property)
(require shrubbery/write)
(require "./utils/parse_utils.rkt")
(require "./sexp-generator/utils/gen_helper.rkt")

(define (rand_test_main [n 100])
  (define str-port (open-output-string))
  (with-test-count
   n
   (quickcheck
    (property ([ele (gen-document)])
              (write-shrubbery ele str-port #:pretty? #t #:armor? #f #:prefer-multiline? #t)
              (check-sexps-equal? (syntax->datum 
                                    (parse-all (open-input-string (get-output-string str-port))))
                                  (call_self_defined_parser (get-output-string str-port)))))))

(module+ test
  (rand_test_main)
)