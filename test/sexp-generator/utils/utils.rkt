#lang racket
(require quickcheck)
(require shrubbery)
(require shrubbery/parse)
(require shrubbery/property)
(require shrubbery/write)
(require shrubbery/print)

(provide pretty_print_random_generated_vals)

(define (pretty_print_sexp s [test-port (open-output-string)])
  (write-shrubbery s (current-output-port) #:pretty? #t #:armor? #f #:prefer-multiline? #t)
  ;;; Verify the s exp; will fails if it does not work
  (write-shrubbery s test-port #:pretty? #t #:armor? #f #:prefer-multiline? #t)
  (define out-str (get-output-string test-port))
  (define in-port (open-input-string out-str))
  (parse-all in-port)
  (newline)
  (newline))

(define (pretty_print_random_generated_vals gen-generator [test-port (open-output-string)] [n 100])
  (with-test-count
   n
   (quickcheck (property ([ele (gen-generator)]) (pretty_print_sexp ele test-port) #t))))
