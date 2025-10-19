#lang racket
(require quickcheck)
(require shrubbery/write)
(require shrubbery/print)
(provide print_random_generated_vals
         pretty_print_random_generated_vals)

(define (print_random_generated_vals gen-generator [n 500])
  (with-test-count n (quickcheck (property ([ele (gen-generator)]) (displayln ele) #t))))

(define (pretty_print_random_generated_vals gen-generator [n 600])
  (with-test-count
   n
   (quickcheck (property ([ele (gen-generator)]) (displayln (shrubbery-syntax->string ele) #t))))
)

