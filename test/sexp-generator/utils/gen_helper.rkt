#lang racket
(require quickcheck)
(require "./utils.rkt")
(provide gen-item
         gen-group
         gen-document
         gen-block
         gen-alts
)

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
                                                [head (generator (sub1 recurse-limit))]
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
(define (gen-parens [recurse-limit 2])
  (bind-generators ([grps (gen-group-list (sub1 recurse-limit))]) (append (list 'parens) grps)))

;;; (brackets group)
(define (gen-brackets [recurse-limit 2])
  (bind-generators ([grps (gen-group-list (sub1 recurse-limit))]) (append (list 'brackets) grps)))

;;; (braces group)
(define (gen-braces [recurse-limit 2])
  (bind-generators ([grps (gen-group-list (sub1 recurse-limit))]) (append (list 'braces) grps)))

;;; (quotes group)
(define (gen-quotes [recurse-limit 2])
  (bind-generators ([grps (gen-group-list (sub1 recurse-limit))]) (append (list 'quotes) grps)))

(set! gen-item
      (lambda ([recurse-limit 2])
        (choose-mixed (list (delay
                              (gen-atom))
                            (delay
                              (gen-operator))
                            (delay
                              (gen-parens (sub1 recurse-limit)))
                            (delay
                              (gen-brackets (sub1 recurse-limit)))
                            (delay
                              (gen-braces (sub1 recurse-limit)))
                            (delay
                              (gen-quotes (sub1 recurse-limit)))))))

(set! gen-item-list (lambda ([recurse-limit 5]) (gen-generator-list gen-item recurse-limit)))

;;; ----------------------
;;; Generate groups
;;; ----------------------

;;; (group item* item)
(define (gen-group1 [recurse-limit 2])
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (and (positive? recurse-limit) (= 0 rand))]
                                                [a (gen-item (sub1 recurse-limit))]
                                                [res
                                                 (if recurse?
                                                     (gen-item-list (sub1 recurse-limit))
                                                     (list))])
                   (append (list 'group a) res)))

;;; (group item* block)
(define (gen-group2 [recurse-limit 2])
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (and (positive? recurse-limit) (= 0 rand))]
                                                [b (gen-block (sub1 recurse-limit))]
                                                [i (gen-item (sub1 recurse-limit))]
                                                [res
                                                 (if recurse?
                                                     (gen-item-list (sub1 recurse-limit))
                                                     (list i))])
                   (append (list 'group) res (list b))))

;;; (group item* alts)
(define (gen-group3 [recurse-limit 2])
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (and (positive? recurse-limit) (= 0 rand))]
                                                [a (gen-alts (sub1 recurse-limit))]
                                                [i (gen-item (sub1 recurse-limit))]
                                                [res
                                                 (if recurse?
                                                     (gen-item-list (sub1 recurse-limit))
                                                     (list i))])
                   (append (list 'group) res (list a))))

;;; (group item* block alts)
(define (gen-group4 [recurse-limit 2])
  (bind-generators ([rand (choose-integer 0 1)] [recurse? (and (positive? recurse-limit) (= 0 rand))]
                                                [a (gen-alts (sub1 recurse-limit))]
                                                [b (gen-block (sub1 recurse-limit))]
                                                [i (gen-item (sub1 recurse-limit))]
                                                [res
                                                 (if recurse?
                                                     (gen-item-list (sub1 recurse-limit))
                                                     (list i))])
                   (append (list 'group) res (list b a))))

(set! gen-group
      (lambda ([recurse-limit 5])
        (choose-mixed (list (delay
                              (gen-group1 (sub1 recurse-limit)))
                            (delay
                              (gen-group2 (sub1 recurse-limit)))
                            (delay
                              (gen-group3 (sub1 recurse-limit)))
                            (delay
                              (gen-group4 (sub1 recurse-limit)))))))

(set! gen-group-list (lambda ([recurse-limit 5]) (gen-generator-list gen-group recurse-limit)))

;;; --------------------
;;; Gen block
;;; --------------------
(set! gen-block
      (lambda ([recurse-limit 2])
        (bind-generators ([rand (choose-integer 0 1)] [recurse?
                                                       (and (positive? recurse-limit) (= 0 rand))]
                                                      [res
                                                       (if recurse?
                                                           (gen-group-list (sub1 recurse-limit))
                                                           (list))])
                         (append (list 'block) res))))

(set! gen-block-list (lambda ([recurse-limit 5]) (gen-generator-list gen-block recurse-limit)))

;;; --------------------
;;; Gen alts
;;; --------------------
(set! gen-alts
      (lambda ([recurse-limit 2])
        (bind-generators ([rand (choose-integer 0 1)] [recurse?
                                                       (and (positive? recurse-limit) (= 0 rand))]
                                                      [res
                                                       (if recurse?
                                                           (gen-block-list (sub1 recurse-limit))
                                                           (list))])
                         (append (list 'alts) res))))

;;; (print_random_generated_vals gen-group)
;;; Generate documents

(define (gen-document [recurse-limit 5])
  (bind-generators ([grps (gen-group-list recurse-limit)]) (append (list 'top) grps)))

(print_random_generated_vals gen-document)
