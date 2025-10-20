#lang racket/base

(require data/applicative)
(require data/either)
(require data/monad)
(require megaparsack)
(require racket/contract)
(require racket/fixnum)
(require racket/match)
(require racket/format)
(require racket/function)

(module+ test
  (require rackunit))

(provide
 indent/p
 update-indentation
 inf-indentation
 inf-indentation?
 absolute-indentation/p
 local-absolute-indentation/p
 local-indentation/p
 local-token-mode/p
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

(define (valid-indentation? state indentation)
  (match-define (indentation-state lower upper absmode relation) state)
  (define rel (cond [absmode '=] [else relation]))
  (match rel
    [(cons 'const x) (= x indentation)]
    ['* #t]
    ['> (< lower indentation)]
    ['>= (<= lower indentation)]
    ['= (and (<= lower indentation) (<= indentation upper))]))

(define (make-indentation-error state indentation)
  (match-define (indentation-state lower upper absmode relation) state)
  (define (make-error place)
    (format "indentation ~a. Expecting ~a." indentation place))
  (define rel (cond [absmode '=] [else relation]))
  (match rel
    [(cons 'const x) (make-error (~a "indentation" x #:separator " "))]
    ['* (error "* relation in indentation state should not fail")]
    ['> (make-error (~a "indentation greater than" lower #:separator " "))]
    ['>= (make-error (~a "indentation greater than or equal to" lower #:separator " "))]
    ['= (make-error (~a "indentation between" lower "and" upper #:separator " "))]))

(define (indentation-in-range/c state)
  (flat-contract-with-explanation
    (lambda (indentation)
      (cond
        [(valid-indentation? state indentation) #t]
        [else
          (lambda (blame)
            (raise-blame-error blame indentation (make-indentation-error state indentation)))]))
    #:name 'indentation-in-range/c))

;; Updates the indentation state's range to a sub-range based on the
;; indentation and the interal relation.
(define/contract (update-indentation state indentation)
  ;; This function has defensive checking for valid indentation, but it raises
  ;; an error. If you want to fail the megaparsack parser instead, use
  ;; `guard/p`, `box-valid-indentation?` and `make-box-indentation-error`. See
  ;; `indent/p` for an example.
  (->i ([state indentation-state?]
        [indentation (state) (and/c indentation? (indentation-in-range/c state))])
       [result indentation-state?])
  (match-define (indentation-state _ upper absmode relation) state)
  (define rel (cond [absmode '=]
                    [else relation]))
  (match rel
    [(cons 'const x) [(= x indentation) (struct-copy indentation-state state [absmode #f])]]
    ['* (struct-copy indentation-state state [absmode #f])]
    ['> (struct-copy indentation-state state [upper (min (sub1 indentation) upper)] [absmode #f])]
    ['>= (struct-copy indentation-state state [upper (min indentation upper)] [absmode #f])]
    ['= (struct-copy indentation-state state [lower indentation] [upper indentation] [absmode #f])]))


(define ((make-box-indentation-error state) box)
  (define token (syntax-box-datum box))
  (define indentation (syntax-box-indentation box))
  (format "Token ~a at ~a" token (make-indentation-error state indentation)))

(define ((box-valid-indentation? state) box)
  (define indentation (syntax-box-indentation box))
  (valid-indentation? state indentation))

(define indent-parameter (make-parser-parameter (indentation-state 0 inf-indentation #f '>)))

(define (indent/p parser)
  (do
    [previous-state <- (indent-parameter)]
    [box <- (guard/p (syntax-box/p parser)
              (box-valid-indentation? previous-state) (format "~a" previous-state) (make-box-indentation-error previous-state))]
    (define box-indentation (syntax-box-indentation box))
    (define new-state (update-indentation previous-state box-indentation))
    (indent-parameter new-state)
    (pure (syntax-box-datum box))))


(define/contract (local-token-mode/p relation-transformer parser)
  (-> (-> relation? relation?) parser? parser?)
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
      ['* (values 0 inf-indentation)]
      ['= (values parent-lower parent-upper)]
      [(cons 'const x)
       ; TODO Check if allowing infinity breaks things
       (cond
         [(= x inf-indentation)
          (error "local-indentation: Const indentation 'infIndentation' is out of bounds")]
         [else (values x x)])]
      ['>= (values parent-lower inf-indentation)]
      ['> (values (add1 parent-lower) inf-indentation)]))
  (match-define (indentation-state lower upper _ _) parent-state)
  (match-define-values (child-lower child-upper) (local-indentation-child-range relation lower upper))
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

(define/contract (local-indentation/p relation parser)
  (-> relation? parser? parser?)
  (do
    [(and parent-state (indentation-state _ _ absmode _)) <- (indent-parameter)] ; previous indentation interval
    ;; TODO Analyze why the absmode cond is here
    (cond
      [absmode parser]
      [else
       (do
         (indent-parameter (set-local-indentation-range relation parent-state)) ; set interval for child
         [parsed-expression <- parser] ; run child parser
         [child-state <- (indent-parameter)] ; check child interval
         (indent-parameter (restrict-parent-range-from-child-range relation #:parent parent-state #:child child-state)) ; calculate indentation based on previous and this range
         (pure parsed-expression))]))) ; This is the range of the expression

(define/contract (local-absolute-indentation/p parser)
  (-> parser? parser?)
  (do
    [(and parent-state (indentation-state _ _ parent-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indentation-state parent-state [absmode #t]))
    [parsed-expression <- parser]
    [child-state <- (indent-parameter)]
    (indent-parameter (struct-copy indentation-state child-state [absmode parent-absmode]))
    (pure parsed-expression)))

(define/contract (absolute-indentation/p parser)
  (-> parser? parser?)
  (do
    [(and parent-state (indentation-state _ _ parent-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indentation-state parent-state [absmode #t]))
    [parsed-expression <- parser]
    [(and child-state (indentation-state _ _ child-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indentation-state child-state [absmode (and parent-absmode child-absmode)]))
    (pure parsed-expression)))

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


(module+ test
  (require megaparsack/text)

  (define whitespace/p (many/p space/p))

  ;; Parens example
  (define bracket-parser
    (many/p
     (do whitespace/p
       [x <- (or/p
               (local-token-mode/p (const '=)
                 (do
                   (indent/p (char/p #\())
                   whitespace/p
                   [x <- (local-indentation/p '> bracket-parser)]
                   whitespace/p
                   (indent/p (char/p #\)))
                   (pure (list 'parens x))))
               (local-token-mode/p (const '>=)
                 (do
                  (indent/p (char/p #\[))
                  whitespace/p
                  [x <- (local-indentation/p '> bracket-parser)]
                  whitespace/p
                  (indent/p (char/p #\]))
                  (pure (list 'bracket x)))))]
       whitespace/p
       (pure x))))

  (check-equal? (parse-string bracket-parser "(  [(\n    ) ]\n)") (success '((parens ((bracket ((parens ()))))))))

  (check-equal? (parse-string bracket-parser " (  [(\n     ) \n ]\n )") (success '((parens ((bracket ((parens ())))))))))
