;;; Utilize the Quickcheck testing API to compare the behavior of parsers
;;; Instead of directly printing all the sexps out
#lang racket

(require quickcheck)
(require shrubbery/parse)
(require shrubbery/write)
(require "./utils/parse_utils.rkt")
(require "./sexp-generator/utils/gen_helper.rkt")

(define (rand_test_main [n 10000])
  (define str-port (open-output-string))
  (with-test-count
      n
    (quickcheck
     (property ([ele (gen-document)])
               (write-shrubbery ele str-port #:pretty? #t #:armor? #f #:prefer-multiline? #t)
               (check-sexp-equal? (parse-our (get-output-string str-port))
                                  (syntax->datum
                                   (parse-all (open-input-string (get-output-string str-port)))))))))


(module+ test
  (rand_test_main))
