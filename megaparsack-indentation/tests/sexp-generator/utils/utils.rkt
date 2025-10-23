#lang racket
(require quickcheck)

(provide print_random_generated_vals)

(define (print_random_generated_vals gen-generator [n 10])
  (with-test-count n (quickcheck (property ([ele (gen-generator)]) (displayln ele) #t))))
