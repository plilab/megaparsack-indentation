#lang racket
(require quickcheck)
(require "./utils.rkt")
(provide gen-item)

;;; Generating items
(define (gen-num [min-num 0] [max-num 999])
  (choose-integer min-num max-num))

(define (gen-string-fixed size [char-gen (choose-char #\a #\z)])
  (choose-string char-gen size))

(define (gen-name)
  (choose-mixed (list (delay
                        (gen-string-fixed 1))
                      (delay
                        (gen-string-fixed 2))
                      (delay
                        (gen-string-fixed 3))
                      (delay
                        (gen-string-fixed 4))
                      (delay
                        (gen-string-fixed 5)))))

;;; Generate items
;;; atom
(define (gen-atom)
  (choose-mixed (list (delay
                        (gen-num))
                      (delay
                        (gen-name)))))
;;; (op symbol)
(define (gen-operator)
  (bind-generators ([a (choose-one-of (list '+ '- '* '/ '= '==))]) (list 'op a)))

;;; (parens group)
(define (gen-parens [limit 5]) (error "unimplemented"))

;;; (brackets group)
(define (gen-brackets [limit 5]) (error "unimplemented"))

;;; (braces group)
(define (gen-braces [limit 5]) (error "unimplemented"))

;;; (quotes group)
(define (gen-quotes [limit 5]) (error "unimplemented"))

(define (gen-item)
  (choose-mixed (list (delay
                        (gen-atom))
                      (delay
                        (gen-operator)))))

;;; Small debug
(print_random_generated_vals gen-item)

;;; Generate gropus
;;; (group item* item)
(define (gen-group1 [recurse-limit 5])
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (and (positive? recurse-limit) (= 0 rand))]
                                                [a (gen-item)]
                                                [res
                                                 (if recurse?
                                                     (gen-group1 (sub1 recurse-limit))
                                                     (list))])
                   (append (list 'group a) res)))

;;; (group item* block)
(define (gen-group2 [recurse-limit 5])
  (error "not implemented"))

;;; (group item* alts)
(define (gen-group3 [recurse-limit 5])
  (error "not implemented"))

;;; (group item* block alts)
(define (gen-group4 [recurse-limit 5] (error "not implemented")))


(define (gen-group)
  (choose-mixed (list (delay
                        (gen-group1))
                      (delay
                        (gen-group2))
                      (delay
                        (gen-group3))
                      (delay
                        (gen-group4)))))

(print_random_generated_vals gen-group1)
