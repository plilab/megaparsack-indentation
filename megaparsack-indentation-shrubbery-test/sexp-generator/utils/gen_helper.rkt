#lang racket
(require quickcheck)
(require "./utils.rkt")
(provide gen-item
         gen-group
         gen-document
         gen-block
         gen-alts)

;;; -------------------------
;;; Helper generators
;;; -------------------------

(define (gen-int [min-num 0] [max-num 1000])
  (choose-integer min-num max-num))

(define (gen-name [max-size 5] [char-gen (choose-char #\a #\z)])
  (bind-generators
   ([size (choose-integer 1 max-size)]
    [symbol (choose-symbol char-gen size)])
   symbol))

(define (gen-generator-list generator [recurse-limit 2])
  (bind-generators
   ([rand (choose-integer 0 10)]
    [recurse? (and (positive? recurse-limit) (= 0 rand))]
    [head (generator (sub1 recurse-limit))]
    [tail
     (if recurse?
         (gen-generator-list generator
                             (sub1 recurse-limit))
         (list))])
   (append (list head) tail)))

;;; --------------------------
;;; Generate items
;;; --------------------------
;;; atom
(define (gen-atom)
  (choose-mixed (list (gen-int)
                      (gen-name))))

;;; (op symbol)
(define (gen-operator)
  (bind-generators ([a (choose-one-of (list '+ '- '* '/ '= '==))]) (list 'op a)))

;;; (parens group)
(define (gen-parens [recurse-limit 2])
  (bind-generators
   ([grps (gen-group-list (sub1 recurse-limit))])
   (append (list 'parens) grps)))

;;; (brackets group)
(define (gen-brackets [recurse-limit 2])
  (bind-generators
   ([grps (gen-group-list (sub1 recurse-limit))])
   (append (list 'brackets) grps)))

;;; (braces group)
(define (gen-braces [recurse-limit 2])
  (bind-generators
   ([grps (gen-group-list (sub1 recurse-limit))])
   (append (list 'braces) grps)))

;;; (quotes group)
(define (gen-quotes [recurse-limit 2])
  (bind-generators
   ([grps (gen-group-list (sub1 recurse-limit))])
   (append (list 'quotes) grps)))

(define (gen-item [recurse-limit 2])
  (if (<= recurse-limit 0)
      (gen-atom)
      (choose-mixed (list (gen-atom)
                          (gen-operator)
                          (gen-parens (sub1 recurse-limit))
                          (gen-brackets (sub1 recurse-limit))
                          (gen-braces (sub1 recurse-limit))
                          (gen-quotes (sub1 recurse-limit))))))

(define (gen-item-list [recurse-limit 5])
  (gen-generator-list gen-item recurse-limit))

;;; ----------------------
;;; Generate groups
;;; ----------------------

;;; (group item* item)
(define (gen-group1 [recurse-limit 2])
  (bind-generators
   ([rand (choose-integer 0 1)]
    [recurse? (positive? recurse-limit)]
    [a (gen-item (sub1 recurse-limit))]
    [res
     (if recurse?
         (gen-item-list (sub1 recurse-limit))
         (list))])
   (append (list 'group a) res)))

;;; (group item* block)
(define (gen-group2 [recurse-limit 2])
  (bind-generators
   ([rand (choose-integer 0 1)]
    [recurse? (positive? recurse-limit)]
    [b (gen-block (sub1 recurse-limit))]
    [i (gen-item (sub1 recurse-limit))]
    [res
     (if recurse?
         (gen-item-list (sub1 recurse-limit))
         (list i))])
   (append (list 'group) res (list b))))

;;; (group item* alts)
(define (gen-group3 [recurse-limit 2])
  (bind-generators
   ([rand (choose-integer 0 1)]
    [recurse? (positive? recurse-limit)]
    [a (gen-alts (sub1 recurse-limit))]
    [i (gen-item (sub1 recurse-limit))]
    [res
     (if recurse?
         (gen-item-list (sub1 recurse-limit))
         (list i))])
   (append (list 'group) res (list a))))

;;; (group item* block alts)
(define (gen-group4 [recurse-limit 2])
  (bind-generators
   ([rand (choose-integer 0 1)]
    [recurse? (positive? recurse-limit)]
    [a (gen-alts (sub1 recurse-limit))]
    [b (gen-block (sub1 recurse-limit))]
    [i (gen-item (sub1 recurse-limit))]
    [res
     (if recurse?
         (gen-item-list (sub1 recurse-limit))
         (list i))])
   (append (list 'group) res (list b a))))

(define (gen-group [recurse-limit 5])
  (if (<= recurse-limit 0)
      (bind-generators ([atm (gen-atom)]) (list 'block atm))
      (choose-mixed (list (gen-group1 (sub1 recurse-limit))
                          (gen-group2 (sub1 recurse-limit))
                          (gen-group3 (sub1 recurse-limit))
                          (gen-group4 (sub1 recurse-limit))))))

(define (gen-group-list [recurse-limit 5])
  (gen-generator-list gen-group recurse-limit))

;;; --------------------
;;; Gen block
;;; --------------------
(define (gen-block [recurse-limit 2])
  (bind-generators
   ([rand (choose-integer 0 1)]
    [recurse? (positive? recurse-limit)]
    [grp (gen-group (sub1 recurse-limit))]
    [res
     (if recurse?
         (gen-group-list (sub1 recurse-limit))
         (list grp))])
   (append (list 'block) res)))

(define (gen-block-list [recurse-limit 5])
  (gen-generator-list gen-block recurse-limit))

;;; --------------------
;;; Gen alts
;;; --------------------
(define (gen-alts [recurse-limit 2])
  (bind-generators
   ([rand (choose-integer 0 1)]
    [recurse? (positive? recurse-limit)]
    [grp (gen-block (sub1 recurse-limit))]
    [res
     (if recurse?
         (gen-block-list (sub1 recurse-limit))
         (list grp))])
   (append (list 'alts) res)))

;;; (print_random_generated_vals gen-group)
;;; Generate documents

(define (gen-document [recurse-limit 10])
  (bind-generators
   ([grps (gen-group-list recurse-limit)])
   (append (list 'multi) grps)))

;;; Small demo to print shurbbery syntax generator
(module+ main
  (pretty_print_random_generated_vals gen-document))
