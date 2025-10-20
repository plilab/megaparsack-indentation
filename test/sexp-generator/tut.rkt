#lang racket
(require quickcheck)
(require quickcheck/generator)
;;; This is a tutorial document to try and learn Quick Check
;;; https://plt.cs.northwestern.edu/pkg-build/doc/quickcheck/index.html#%28part._top%29

;;; Sample from quick check number
(define string->number-returns-number
  (property ([str arbitrary-string]) (number? (string->number str))))

(quickcheck string->number-returns-number)

(define append-and-length-agree
  (property ([lst-1 (arbitrary-list arbitrary-integer)] [lst-2 (arbitrary-list arbitrary-integer)])
            (= (+ (length lst-1) (length lst-2)) (length (append lst-1 lst-2)))))

(quickcheck append-and-length-agree)

;;; self-defined element generator
(define (gen-num [min-num -99999] [max-num 99999])
  (choose-integer min-num max-num))

(define (gen-string-fixed size [char-gen (choose-char #\a #\z)])
  (choose-string char-gen size))

(define (gen-variable)
  (choose-mixed (list (delay
                        (gen-string-fixed 1))
                      (delay
                        (gen-string-fixed 2))
                      (delay
                        (gen-string-fixed 3))
                      (delay
                        (gen-string-fixed 4)))))

(define (gen-operator)
  (choose-one-of (list '+ '- '* '/ '= '==)))

;;; Test for binop
(define (gen-binop)
  (bind-generators ([op1 (gen-variable)] [op2 (gen-variable)] [binop (gen-operator)])
                   (list op1 binop op2)))

(define (gen-operator2)
  (bind-generators ([a (choose-one-of (list '+ '- '* '/ '= '==))]) (list 'op a)))

(struct foo (a b) #:transparent)
; choose-foo creates a generator that produces a foo such that
;   foo-a is an integer?
;   foo-b is (or/c foo? #f)
(define (choose-foo [recurse-limit 13])
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (and (positive? recurse-limit) (= 0 rand))]
                                                [a (choose-integer 0 9)]
                                                [b
                                                 (if recurse?
                                                     (choose-foo (sub1 recurse-limit))
                                                     #f)])
                   (foo a b)))

;;; For debugging
(define (print_random_generated_vals gen-generator [n 10])
  (with-test-count n (quickcheck (property ([ele (gen-generator)]) (displayln ele) #t))))

(define (store_random_generated_vals gen-generator [n 10])
  (generate (gen:list gen-generator n)))

(print_random_generated_vals gen-variable)
(print_random_generated_vals (lambda () (choose-integer 1 2)))
(store_random_generated_vals gen-operator2)
