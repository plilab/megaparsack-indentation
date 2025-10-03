#lang racket
(require quickcheck)
(require "./utils.rkt")
(provide gen-item)

;;; -------------------------
;;; Helper generators
;;; -------------------------

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

(define (gen-generator-list generator [recurse-limit 2])
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (and (positive? recurse-limit) (= 0 rand))]
                                                [head (generator)]
                                                [tail
                                                 (if recurse?
                                                     (gen-generator-list generator
                                                                         (sub1 recurse-limit))
                                                     (list))])
                   (append (list head) tail)))

;;; -------------------------
;;; Forward declarations
;;; -------------------------
(define gen-item null)
(define gen-group null)
(define gen-block null)
(define gen-alts null)

(define gen-item-list null)
(define gen-group-list null)
(define gen-block-list null)

;;; --------------------------
;;; Generate items
;;; --------------------------
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
(define (gen-parens)
  (bind-generators ([grps (gen-group-list)]) (append (list 'parens) grps)))

;;; (brackets group)
(define (gen-brackets)
  (bind-generators ([grps (gen-group-list)]) (append (list 'brackets) grps)))

;;; (braces group)
(define (gen-braces)
  (bind-generators ([grps (gen-group-list)]) (append (list 'braces) grps)))

;;; (quotes group)
(define (gen-quotes [limit 5])
  (bind-generators ([grps (gen-group-list)]) (append (list 'quotes) grps)))

(set! gen-item
      (lambda ()
        (choose-mixed (list (delay
                              (gen-atom))
                            (delay
                              (gen-operator))
                            (delay
                              (gen-parens))
                            (delay
                              (gen-brackets))
                            (delay
                              (gen-braces))
                            (delay
                              (gen-quotes))))))

(set! gen-item-list (lambda () (gen-generator-list gen-item)))

;;; ----------------------
;;; Generate groups
;;; ----------------------

;;; (group item* item)
(define (gen-group1 [recurse-limit 2])
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (and (positive? recurse-limit) (= 0 rand))]
                                                [a (gen-item)]
                                                [res
                                                 (if recurse?
                                                     (gen-item-list)
                                                     (list))])
                   (append (list 'group a) res)))

;;; (group item* block)
(define (gen-group2)
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (= 0 rand)]
                                                [b (gen-block)]
                                                [i (gen-item)]
                                                [res
                                                 (if recurse?
                                                     (gen-item-list)
                                                     (list i))])
                   (append (list 'group) res (list b))))

;;; (group item* alts)
(define (gen-group3)
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (= 0 rand)]
                                                [a (gen-alts)]
                                                [i (gen-item)]
                                                [res
                                                 (if recurse?
                                                     (gen-item-list)
                                                     (list i))])
                   (append (list 'group) res (list a))))

;;; (group item* block alts)
(define (gen-group4)
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (= 0 rand)]
                                                [a (gen-alts)]
                                                [b (gen-block)]
                                                [i (gen-item)]
                                                [res
                                                 (if recurse?
                                                     (gen-item-list)
                                                     (list i))])
                   (append (list 'group) res (list b a))))

(set! gen-group
      (lambda ()
        (choose-mixed (list (delay
                              (gen-group1))
                            (delay
                              (gen-group2))
                            (delay
                              (gen-group3))
                            (delay
                              (gen-group4))))))

(set! gen-group-list (lambda () (gen-generator-list gen-group)))

;;; --------------------
;;; Gen block
;;; --------------------
(set! gen-block (lambda ([recurse-limit 2])
      (bind-generators ([rand (choose-integer 0 1)] [recurse?
                                                     (and (positive? recurse-limit) (= 0 rand))]
                                                    [res
                                                     (if recurse?
                                                         (gen-group-list)
                                                         (list))])
                       (append (list 'block) res))))

(set! gen-block-list (lambda () (gen-generator-list gen-block)))

;;; --------------------
;;; Gen alts
;;; --------------------
(set! gen-alts (lambda ([recurse-limit 2])
      (bind-generators ([rand (choose-integer 0 1)] [recurse?
                                                     (and (positive? recurse-limit) (= 0 rand))]
                                                    [res
                                                     (if recurse?
                                                         (gen-block-list)
                                                         (list))])
                       (append (list 'alts) res))))

(print_random_generated_vals gen-group)
