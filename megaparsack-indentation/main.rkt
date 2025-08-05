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
  racket/format)

(module+ test
  (require rackunit))

(provide
 (contract-out
  [struct indentation-state ((lower indentation?) (upper indentation?) (absmode boolean?) (relation relation?))]
  [inf-indentation indentation?]
  [inf-indentation? (-> indentation? boolean?)]
  [update-indentation (-> indentation-state? indentation? (either/c string? indentation-state?))]))

(define (indentation? a)
  (and/c (natural-number/c a) (fixnum? a)))

(define (relation? a)
  (or (eq? '> a)
      (eq? '>= a)
      (eq? '= a)
      (eq? '* a)
      (and (pair? a) (= (car a) 'const) (indentation? (cdr a)))))


(struct indentation-state (lower upper absmode relation)
  #:guard (lambda (lower upper absmode relation _name)
            (unless (lower . <= . upper)
              (error "Lower bound is greater than upper bound"))
            (values lower upper absmode relation)))

(define inf-indentation (most-positive-fixnum))
(define (inf-indentation? a) (= inf-indentation a))

(define (update-indentation state indentation)
  (define (make-error place)
    (failure (format "Found a token at indentation ~a. Expecting a tokent at ~a." indentation place)))
  (match-define (indentation-state lower upper absmode relation) state)
  (define rel (cond [absmode '=]
                    [else relation]))
  (match rel
    [(cons 'const x) ; '(const . x)
     (cond
       [(= x indentation) (success state)]
       [else (make-error (~a "indentation" x))])]
    ['* (success state)]
    ['>
     (cond
       [(< lower indentation)
        (success (struct-copy indentation-state state [upper (- indentation 1)]))]
       [else (make-error (~a "an indentation greater than" lower))])]
    ['>=
     (cond
       [(<= lower indentation)
        (success (struct-copy indentation-state state [upper indentation]))]
       [else (make-error (~a "an indentation greater than or equal to" lower))])]
    ['=
     (cond
       [(and (<= lower indentation) (<= indentation upper))
        (success (struct-copy indentation-state state [lower indentation] [upper indentation]))]
       [else (make-error (~a "indentation between" lower "and" upper))])]))

(define indent-parameter (make-parser-parameter (indentation-state 0 inf-indentation #f '>)))

(define (indent/p rel parser)
  (do
      ; previous indentation interval
      ; calculate interval
      ; set for child
      ; run child parser
      ; check interval and calculate another indentation on previous and this range. This is the range of this expression
      [box <- (syntax-box/p parser)]

    (define box-starting-column (add1 (srcloc-column (syntax-box-srcloc box))))
    (do [previous-state <- (indent-parameter)]
      [new-state <- (update-indentation previous-state box-starting-column)]
      (indent-parameter new-state)
      (pure (syntax-box-datum box)))))

(define (indent-token/p rel check-soucrce-loc parser)
  (do
    ; set beforehand
    ; look at source location; use relation in state to compare
    ; modifies interval
    ; calls the parser
    ; grab indentation afterwards and source location
      [box <- (syntax-box/p parser)]
    (define box-starting-column (add1 (srcloc-column (syntax-box-srcloc box))))
    (do [previous-state <- (indent-parameter)]
      [new-state <- (update-indentation previous-state box-starting-column)]
      (indent-parameter new-state)
      (pure (syntax-box-datum box)))))

(define whitespace/p (many/p (satisfy/p char-whitespace?)))

(define bracket-parser
  (many/p
   (do whitespace/p
     [x <- (or/p (do (char/p #\()
                   whitespace/p
                   [x <- (delay/p bracket-parser)]
                   whitespace/p
                   (char/p #\))
                   (pure (list 'parens x)))
                 (do (char/p #\[)
                   whitespace/p
                   [x <- (delay/p bracket-parser)]
                   whitespace/p
                   (char/p #\])
                   (pure (list 'bracket x))))]
     whitespace/p
     (pure x))))


(module+ test
  ;; Any code in this `test` submodule runs when this file is run using DrRacket
  ;; or with `raco test`. The code here does not run when this file is
  ;; required by another module.

  (check-equal? (+ 2 2) 4))

(module+ main
  ;; (Optional) main submodule. Put code here if you need it to be executed when
  ;; this file is run using DrRacket or the `racket` executable.  The code here
  ;; does not run when this file is required by another module. Documentation:
  ;; http://docs.racket-lang.org/guide/Module_Syntax.html#%28part._main-and-test%29

  (printf "~a"
          (parse-result! (parse-string bracket-parser "(   ( ()()()((([][][]))) )   ) [ ()  ]  "))))

