#lang racket/base

(require
  data/applicative
  data/either
  data/monad
  megaparsack
  megaparsack/text
  racket/contract
  racket/fixnum
  racket/match
  racket/format
  racket/trace)

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


(define/contract inf-indentation indentation? (most-positive-fixnum))
(define/contract (inf-indentation? a) (-> indentation? boolean?) (= inf-indentation a))

(define ((has-valid-indentation state) box)
  (match-define (indentation-state lower upper absmode relation) state)
  (define indentation (syntax-box-indentation box))
  (define rel (cond [absmode '=] [else relation]))
  (match rel
    [(cons 'const x) (= x indentation)]
    ['* #t]
    ['> (< lower indentation)]
    ['>= (<= lower indentation)]
    ['= (and (<= lower indentation) (<= indentation upper))]))

(define ((make-indentation-error state) box)
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

(define/contract (update-indentation state indentation)
  (-> indentation-state? indentation? (either/c string? indentation-state?))
  (define (make-error place)
    (failure (format "Found a token at indentation ~a. Expecting a token at ~a." indentation place)))
  (match-define (indentation-state lower upper absmode relation) state)
  (define rel (cond [absmode '=]
                    [else relation]))
  (match rel
    [(cons 'const x) ; '(const . x)
     (cond
       [(= x indentation) (success state)]
       [else (make-error (~a "indentation" x #:separator " "))])]
    ['* (success state)]
    ['>
     (cond
       [(< lower indentation)
        (success (struct-copy indentation-state state [upper (min (sub1 indentation) upper)]))]
       [else (make-error (~a "an indentation greater than" lower #:separator " "))])]
    ['>=
     (cond
       [(<= lower indentation)
        (success (struct-copy indentation-state state [upper (min indentation upper)]))]
       [else (make-error (~a "an indentation greater than or equal to" lower #:separator " "))])]
    ['=
     (cond
       [(and (<= lower indentation) (<= indentation upper))
        (success (struct-copy indentation-state state [lower indentation] [upper indentation]))]
       [else (make-error (~a "indentation between" lower "and" upper #:separator " "))])]))

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

(define (make-local-indentation-state relation parent-state)
  (define (local-indentation-child-range relation parent-lower parent-upper)
    (match relation
      ['* (success (cons 0 inf-indentation))]
      ['= (success (cons parent-lower parent-upper))]
      [(cons 'const x)
       (cond
         [(= x inf-indentation)
          (failure "local-indentation: Const indentation 'infIndentation' is out of bounds")]
         [else (success (cons x x))])]
      ['>= (success (cons parent-lower inf-indentation))]
      ['> (success (cons (add1 parent-lower) inf-indentation))]))
  (do (match-define (indentation-state lower upper _ _) parent-state)
    [(cons child-lower child-upper) <- (local-indentation-child-range relation lower upper)]
    (pure (struct-copy indentation-state parent-state [lower child-lower] [upper child-upper]))))


(define (resolve-actual-indentation-state relation #:parent parent-state #:child child-state)
  (match-define (indentation-state parent-lower parent-upper _ _) parent-state)
  (match-define (indentation-state _ child-upper _ _) child-state)
  (match relation
    ['= (success child-state)]
    ['* (success (struct-copy indentation-state child-state [lower parent-lower] [upper parent-upper]))]
    [(cons 'const _) (success (struct-copy indentation-state child-state [lower parent-lower] [upper parent-upper]))]
    ['>= (success (struct-copy indentation-state child-state [lower parent-lower]))]
    ['> (do
            [resolved-upper <- (cond
                                 [(or (= child-upper inf-indentation) (< parent-upper child-upper)) (success parent-upper)]
                                 [(> child-upper 0) (success (sub1 child-upper))]
                                 [else (failure "local-indentation: assertion failed: child-upper > 0")])]
          (pure (struct-copy indentation-state child-state [lower parent-lower] [upper resolved-upper])))]))

(define (local-indentation/p relation parser)
  (do [(and parent-state (indentation-state _ _ absmode _)) <- (indent-parameter)] ; previous indentation interval
    (cond
      (absmode parser)
      [else
       (do [child-local-state <- (make-local-indentation-state relation parent-state)] ; calculate interval
         (indent-parameter child-local-state) ; set for child
         [parsed-expression <- parser] ; run child parser
         [child-state <- (indent-parameter)] ; check child interval
         [resolved-state <- (resolve-actual-indentation-state relation #:parent parent-state #:child child-state)] ; calculate indentation based on previous and this range
         (indent-parameter resolved-state)
         (pure parsed-expression))]))) ; This is the range of the expression

(define (indent/p parser)
  (do
      ; previous indentation interval
      ; calculate interval
      ; set for child
      ; run child parser
      ; check interval and calculate another indentation on previous and this range. This is the range of this expression
      [previous-state <- (indent-parameter)]
    [box <- (guard/p (syntax-box/p parser)
                     (has-valid-indentation previous-state) (~a previous-state) (make-indentation-error previous-state))]
    (define box-starting-column (syntax-box-indentation box))
    [new-state <- (update-indentation previous-state box-starting-column)]
    (indent-parameter new-state)
    (pure (syntax-box-datum box))))

;; (define (indent-token/p rel check-soucrce-loc parser)
;;   (do
;;       ; set beforehand
;;       ; look at source location; use relation in state to compare
;;       ; modifies interval
;;       ; calls the parser
;;       ; grab indentation afterwards and source location
;;       [box <- (syntax-box/p parser)]
;;     (define box-starting-column (add1 (srcloc-column (syntax-box-srcloc box))))
;;     (do [previous-state <- (indent-parameter)]
;;       [new-state <- (update-indentation previous-state box-starting-column)]
;;       (indent-parameter new-state)
;;       (pure (syntax-box-datum box)))))
;;

(define whitespace/p (many/p (satisfy/p char-whitespace?)))

(define (indent-trace/p msg) (do
                                 [state <- (indent-parameter)]
                               (pure (printf "TRACE: ~a ~a\n" msg state))
                               void/p))

(define bracket-parser
  (many/p
   (do whitespace/p
     [x <- (or/p (do (local-token-mode/p (lambda (_) '=) (indent/p (char/p #\()))
                   whitespace/p
                   [x <- (local-indentation/p '> (delay/p bracket-parser))]
                   whitespace/p
                   (local-token-mode/p (lambda (_) '=) (indent/p (char/p #\))))
                   (pure (list 'parens x)))
                 (do (local-token-mode/p (lambda (_) '>=) (indent/p (char/p #\[)))
                   whitespace/p
                   [x <- (local-indentation/p '> (delay/p bracket-parser))]
                   whitespace/p
                   (local-token-mode/p (lambda (_) '>=) (indent/p (char/p #\])))
                   (pure (list 'bracket x))))]
     whitespace/p
     (pure x))))

(define simple-parser
  (local-token-mode/p
   (lambda (_) '=)
   (do
       (indent/p (char/p #\())
     whitespace/p
     (indent/p (char/p #\)))
     (pure null))))


(module+ test
  ;; Any code in this `test` submodule runs when this file is run using DrRacket
  ;; or with `raco test`. The code here does not run when this file is
  ;; required by another module.

  ;; (check-equal? (parse-string simple-parser "()") (success null))

  (check-equal? (+ 2 2) 4))

(module+ main
  (printf "~a\n"
          (parse-result! (parse-string bracket-parser "(  [(\n    ) ]\n)"))))

