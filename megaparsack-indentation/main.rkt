#lang racket/base

(require data/applicative)
(require data/either)
(require data/monad)
(require megaparsack)
(require megaparsack/text)
(require racket/contract)
(require racket/fixnum)
(require racket/match)
(require racket/format)
(require racket/function)

(module+ test
  (require rackunit))

(provide
 update-indentation
 inf-indentation
 inf-indentation?
 (contract-out
  [struct indentation-state ((lower indentation?) (upper indentation?) (absmode boolean?) (relation relation?))]))


(define (indentation? a)
  (and/c (natural-number/c a) (fixnum? a)))

(define (relation? a)
  (or (eq? '> a)
      (eq? '>= a)
      (eq? '= a)
      (eq? '* a)
      (and (pair? a) (= (car a) 'const) (indentation? (cdr a)))))

(define/contract (syntax-box-indentation box)
  (-> syntax-box? indentation?)
  (add1 (srcloc-column (syntax-box-srcloc box))))

; TODO Implement a gen:custom-write interface on this to make the errors look nicer
(struct indentation-state (lower upper absmode relation)
  #:transparent
  #:guard (lambda (lower upper absmode relation _name)
            (unless (lower . <= . upper)
              (error "Lower bound is greater than upper bound"))
            (values lower upper absmode relation)))


(define/contract inf-indentation
  indentation?
  (most-positive-fixnum))

(define/contract (inf-indentation? a)
  (-> indentation? boolean?)
  (= inf-indentation a))

(define/contract ((has-valid-indentation state) box)
  (-> indentation-state? (-> syntax-box? boolean?))
  (match-define (indentation-state lower upper absmode relation) state)
  (define indentation (syntax-box-indentation box))
  (define rel (cond [absmode '=] [else relation]))
  (match rel
    [(cons 'const x) (= x indentation)]
    ['* #t]
    ['> (< lower indentation)]
    ['>= (<= lower indentation)]
    ['= (and (<= lower indentation) (<= indentation upper))]))

(define/contract ((make-indentation-error state) box)
  (-> indentation-state? (-> syntax-box? string?))
  (match-define (indentation-state lower upper absmode relation) state)
  (define indentation (syntax-box-indentation box))
  (define (make-error place)
    (format "indentation ~a. Expecting a token at ~a." indentation place))
  (define rel (cond [absmode '=] [else relation]))
  (match rel
    [(cons 'const x) (make-error (~a "indentation" x #:separator " "))]
    ['* (error "* relation in indentation state should not fail")]
    ['> (make-error (~a "indentation greater than" lower #:separator " "))]
    ['>= (make-error (~a "indentation greater than or equal to" lower #:separator " "))]
    ['= (make-error (~a "indentation between" lower "and" upper #:separator " "))]))

;; Updates the indentation state's range to a sub-range based on the
;; indentation and the interal relation.
;;
;; This function assumes that the indentation is valid for the initial given indentation state.
;; To validate indentaiton see `has-valid-indentation`.
(define/contract (update-indentation state indentation)
  (-> indentation-state? indentation? indentation-state?)
  (define (throw-error place)
    (error (format "Found a token at indentation ~a. Expecting a token at ~a." indentation place)))
  (match-define (indentation-state lower upper absmode relation) state)
  (define rel (cond [absmode '=]
                    [else relation]))
  (match rel
    [(cons 'const x)
     (cond
       [(= x indentation) (struct-copy indentation-state state [absmode #f])]
       [else (throw-error (~a "indentation" x #:separator " "))])]
    ['* (struct-copy indentation-state state [absmode #f])]
    ['>
     (cond
       [(< lower indentation)
        (struct-copy indentation-state state [upper (min (sub1 indentation) upper)] [absmode #f])]
       [else (throw-error (~a "an indentation greater than" lower #:separator " "))])]
    ['>=
     (cond
       [(<= lower indentation)
        (struct-copy indentation-state state [upper (min indentation upper)] [absmode #f])]
       [else (throw-error (~a "an indentation greater than or equal to" lower #:separator " "))])]
    ['=
     (cond
       [(and (<= lower indentation) (<= indentation upper))
        (struct-copy indentation-state state [lower indentation] [upper indentation] [absmode #f])]
       [else (throw-error (~a "indentation between" lower "and" upper #:separator " "))])]))

(define indent-parameter (make-parser-parameter (indentation-state 0 inf-indentation #f '>)))

(define (local-token-mode/p relation-transformer parser)
  (do
    [old-state <- (indent-parameter)]
    (define old-relation (indentation-state-relation old-state))
    (indent-parameter
     (struct-copy indentation-state old-state
                  [relation (relation-transformer old-relation)]))
    [val <- parser]
    [new-state <- (indent-parameter)]
    (indent-parameter (struct-copy indentation-state new-state [relation old-relation]))
    (pure val)))

(define (set-local-indentation-range relation parent-state)
  (define (local-indentation-child-range relation parent-lower parent-upper)
    (match relation
      ['* (cons 0 inf-indentation)]
      ['= (cons parent-lower parent-upper)]
      [(cons 'const x)
       ; TODO Check if allowing infinity breaks things
       (cond
         [(= x inf-indentation)
          (error "local-indentation: Const indentation 'infIndentation' is out of bounds")]
         [else (cons x x)])]
      ['>= (cons parent-lower inf-indentation)]
      ['> (cons (add1 parent-lower) inf-indentation)]))
  (match-define (indentation-state lower upper _ _) parent-state)
  (match-define (cons child-lower child-upper) (local-indentation-child-range relation lower upper))
  (struct-copy indentation-state parent-state [lower child-lower] [upper child-upper]))


(define (restrict-parent-range-from-child-range relation #:parent parent-state #:child child-state)
  (match-define (indentation-state parent-lower parent-upper _ _) parent-state)
  (match-define (indentation-state _ child-upper _ _) child-state)
  (match relation
    ['= child-state]
    ['* (struct-copy indentation-state child-state [lower parent-lower] [upper parent-upper])]
    [(cons 'const _) (struct-copy indentation-state child-state [lower parent-lower] [upper parent-upper])]
    ['>= (struct-copy indentation-state child-state [lower parent-lower])]
    ['> (define restricted-upper
          (cond
            ;; TODO Calculate why this is true
            [(or (= child-upper inf-indentation) (< parent-upper child-upper)) parent-upper]
            [(> child-upper 0) (sub1 child-upper)]
            [else (error "local-indentation: assertion failed: child-upper > 0")]))
        (struct-copy indentation-state child-state [lower parent-lower] [upper restricted-upper])]))

;; TODO Analyze why the absmode cond is here
(define (local-indentation/p relation parser)
  (do
    [(and parent-state (indentation-state _ _ absmode _)) <- (indent-parameter)] ; previous indentation interval
    (cond
      [absmode parser]
      [else
       (do
         (indent-parameter (set-local-indentation-range relation parent-state)) ; set interval for child
         [parsed-expression <- parser] ; run child parser
         [child-state <- (indent-parameter)] ; check child interval
         (indent-parameter (restrict-parent-range-from-child-range relation #:parent parent-state #:child child-state)) ; calculate indentation based on previous and this range
         (pure parsed-expression))]))) ; This is the range of the expression

(define (absolute-indentation/p parser)
  (do
    [(and parent-state (indentation-state _ _ parent-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indentation-state parent-state [absmode #t]))
    [parsed-expression <- parser]
    [(and child-state (indentation-state _ _ child-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indentation-state child-state [absmode (and parent-absmode child-absmode)]))
    (pure parsed-expression)))

(define (indent/p parser)
  (do
    [previous-state <- (indent-parameter)]
    [box <- (guard/p (syntax-box/p parser)
              (has-valid-indentation previous-state) (~a previous-state) (make-indentation-error previous-state))]
    (define box-indentation (syntax-box-indentation box))
    (define new-state (update-indentation previous-state box-indentation))
    (indent-parameter new-state)
    (pure (syntax-box-datum box))))

;; (define (indent-token/p rel check-soucrce-loc parser)
;;   (do
;;       ; set beforehand
;;       ; look at source location; use relation in state to compare
;;       ; modifies interval
;;       ; calls the parser
;;       ; grab indentation afterwards and source location
;;     [box <- (syntax-box/p parser)]
;;     (define box-starting-column (add1 (srcloc-column (syntax-box-srcloc box))))
;;     (do [previous-state <- (indent-parameter)]
;;       [new-state <- (update-indentation previous-state box-starting-column)]
;;       (indent-parameter new-state)
;;       (pure (syntax-box-datum box)))))
;;

(define whitespace/p (many/p space/p))

;; Parens example
(define bracket-parser
  ;; TODO What did professor say to add here? Something about the token mode
  (many/p
   (do whitespace/p
     [x <- (or/p
             (local-token-mode/p (const '=)
               (do
                 (indent/p (char/p #\())
                 whitespace/p
                 [x <- (local-indentation/p '> (delay/p bracket-parser))]
                 whitespace/p
                 (indent/p (char/p #\)))
                 (pure (list 'parens x))))
             (local-token-mode/p (const '>=)
               (do
                (indent/p (char/p #\[))
                whitespace/p
                [x <- (local-indentation/p '> (delay/p bracket-parser))]
                whitespace/p
                (indent/p (char/p #\]))
                (pure (list 'bracket x)))))]
     whitespace/p
     (pure x))))

(module+ test
  ;; Any code in this `test` submodule runs when this file is run using DrRacket
  ;; or with `raco test`. The code here does not run when this file is
  ;; required by another module.

  (check-equal? (+ 2 2) 4))

(module+ main
  ;; (printf "~a\n"
  ;;         (parse-result! (parse-string iswim-expr "x + y")))
  ;; (printf "~a\n"
  ;;         (parse-result! (parse-string iswim-expr "x + v where\n x = -(\ny + z) + w")))
  (printf "~a\n"
          (parse-result! (parse-string bracket-parser "(  [(\n    ) ]\n)")))
  ;; (printf "~a\n"
  ;;         (parse-result! (parse-string bracket-parser "()")))

  (printf "~a\n"
          (parse-result! (parse-string bracket-parser " (  [(\n     ) \n]\n )"))))

