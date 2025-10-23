#lang racket/base

(require data/applicative)
(require data/either)
(require data/monad)
(require megaparsack)
(require racket/contract)
(require racket/match)
(require racket/format)
(require racket/function)
(require racket/generic)

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
 make-indentation-error)

(define-generics indent
  (least-indent indent)
  (indent=? indent other-indent)
  (indent<? indent other-indent)
  (indent<=? indent other-indent)
  (indent>? indent other-indent)
  (indent>=? indent other-indent)
  (indent-sub1 indent)
  #:requires [least-indent indent<=? indent-sub1]
  #:fast-defaults ([number?
                    (define indent=? =)
                    (define indent<? <)
                    (define indent<=? <=)
                    (define indent>? >)
                    (define indent>=? >=)
                    (define least-indent 0)
                    (define indent-sub1 sub1)])
  #:fallbacks [(define/generic i<=? indent<=?)
               (define (indent<? indent other-indent)
                 (not (i<=? other-indent indent)))
               (define (indent=? indent other-indent)
                 (and (i<=? indent other-indent) (i<=? other-indent indent)))
               (define (indent>? indent other-indent)
                 (not (i<=? indent other-indent)))
               (define (indent>=? indent other-indent)
                 (i<=? other-indent indent))])

(define inf-indentation
  'inf-indentation)

(define (inf-indentation? a)
  (eq? inf-indentation a))

(define (unbounded-indent? v) (or (indent? v) (inf-indentation? v)))

(define (relation? a)
  (or (eq? '> a)
      (eq? '>= a)
      (eq? '= a)
      (eq? '* a)
      (and (pair? a) (= (car a) 'const))))


; TODO Implement a gen:custom-write interface on this to make the errors look nicer
(struct indent-state (lower upper absmode relation)
  #:transparent
  #:guard (lambda (lower upper absmode relation _name)
            (unless (or (inf-indentation? upper) (lower . indent<=? . upper))
              (error "Lower bound is greater than upper bound"))
            (values lower upper absmode relation)))


(define (valid-indentation? state indent)
  (match-define (indent-state lower upper absmode relation) state)
  (define rel (cond [absmode '=] [else relation]))
  (match rel
    [(cons 'const x) (indent=? x indent)]
    ['* #t]
    ['> (indent>? indent lower)]
    ['>= (indent>=? indent lower)]
    ['= (and (indent<=? lower indent) (or (inf-indentation? upper) (indent<=? indent upper)))]))

(define (make-indentation-error state indentation)
  (match-define (indent-state lower upper absmode relation) state)
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
(define (update-indentation state indent)
  ;; Finds the minimum between the indentation and the potentially infinite upper indent
  (define/contract (upper-update indent upper)
    (-> indent? unbounded-indent? indent?)
    (cond
      [(or (inf-indentation? upper) (indent<=? indent upper)) indent]
      [else upper]))

  (match-define (indent-state _ upper absmode relation) state)

  (define rel (cond [absmode '=]
                    [else relation]))
  (define updated
    (match rel
      [(cons 'const x) [(indent=? x indent) state]]
      ['* state]
      ['> (struct-copy indent-state state [upper (upper-update (indent-sub1 indent) upper)])]
      ['>= (struct-copy indent-state state [upper (upper-update indent upper)])]
      ['= (struct-copy indent-state state [lower indent] [upper indent])]))
  (struct-copy indent-state updated [absmode #f]))



(define indent-parameter (make-parser-parameter (indent-state 0 inf-indentation #f '>)))

(define (indent/p parser accessor fail)
  (do
      [previous-state <- (indent-parameter)]
    [box <- (guard/p parser
                     (lambda (val) (valid-indentation? previous-state (accessor val)))
                     (format "~a" previous-state)
                     (fail previous-state))]
    (define box-indentation (accessor box))
    (define new-state (update-indentation previous-state box-indentation))
    (indent-parameter new-state)
    (pure (syntax-box-datum box))))


(define/contract (local-token-mode/p relation-transformer parser)
  (-> (-> relation? relation?) parser? parser?)
  (do
      [old-state <- (indent-parameter)]
    (define old-relation (indent-state-relation old-state))
    (indent-parameter
     (struct-copy indent-state old-state
                  [relation (relation-transformer old-relation)]))
    [val <- parser]
    [new-state <- (indent-parameter)]
    (indent-parameter (struct-copy indent-state new-state [relation old-relation]))
    (pure val)))

(define (set-local-indentation-range relation parent-state)
  (define (local-indentation-child-range relation parent-lower parent-upper)
    (match relation
      ['* (values 0 inf-indentation)]
      ['= (values parent-lower parent-upper)]
      [(cons 'const x)
       (cond
         [(inf-indentation? x)
          (error "local-indentation: Const indentation 'infIndentation' is out of bounds")]
         [else (values x x)])]
      ['>= (values parent-lower inf-indentation)]
      ['> (values (add1 parent-lower) inf-indentation)]))
  (match-define (indent-state lower upper _ _ ) parent-state)
  (match-define-values (child-lower child-upper) (local-indentation-child-range relation lower upper))
  (struct-copy indent-state parent-state [lower child-lower] [upper child-upper]))


(define (restrict-parent-range-from-child-range relation #:parent parent-state #:child child-state)
  (match-define (indent-state parent-lower parent-upper _ _) parent-state)
  (match-define (indent-state _ child-upper _ _) child-state)
  (match relation
    ['= child-state]
    ['* (struct-copy indent-state child-state [lower parent-lower] [upper parent-upper])]
    [(cons 'const _) (struct-copy indent-state child-state [lower parent-lower] [upper parent-upper])]
    ['>= (struct-copy indent-state child-state [lower parent-lower])]
    ['> (define restricted-upper
          (cond
            [(or (inf-indentation? child-upper) (< parent-upper child-upper)) parent-upper]
            [(> child-upper 0) (sub1 child-upper)]
            [else (error "local-indentation: assertion failed: child-upper > 0")]))
        (struct-copy indent-state child-state [lower parent-lower] [upper restricted-upper])]))

(define/contract (local-indentation/p relation parser)
  (-> relation? parser? parser?)
  (do
      [(and parent-state (indent-state _ _ absmode _)) <- (indent-parameter)] ; previous indentation interval
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
      [(and parent-state (indent-state _ _ parent-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indent-state parent-state [absmode #t]))
    [parsed-expression <- parser]
    [child-state <- (indent-parameter)]
    (indent-parameter (struct-copy indent-state child-state [absmode parent-absmode]))
    (pure parsed-expression)))

(define/contract (absolute-indentation/p parser)
  (-> parser? parser?)
  (do
      [(and parent-state (indent-state _ _ parent-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indent-state parent-state [absmode #t]))
    [parsed-expression <- parser]
    [(and child-state (indent-state _ _ child-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indent-state child-state [absmode (and parent-absmode child-absmode)]))
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

  (check-equal? (parse-string bracket-parser " (  [(\n     ) \n  ]\n )") (success '((parens ((bracket ((parens ())))))))))
