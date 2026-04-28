#lang racket/base

(require data/applicative)
(require data/either)
(require data/monad)
(require megaparsack)
(require racket/contract)
(require racket/match)
(require racket/format)
(require racket/function)

(module+ test
  (require rackunit))

(provide
 indent/p
 absolute-indentation/p
 local-indentation/p
 local-token-mode/p)

(define inf-indentation
  (string->uninterned-symbol "megaparsack-indentation:infinite"))

(define (inf-indentation? a)
  (eq? inf-indentation a))


(define (relation? a)
  (or (eq? '> a)
      (eq? '>= a)
      (eq? '= a)
      (eq? '* a)
      (and (pair? a) (eq? (car a) 'const) (not (inf-indentation? a)))))


; TODO Implement a gen:custom-write interface on this to make the errors look nicer
(struct indent-state (lower upper absmode relation)
  #:transparent
  #:guard (lambda (lower upper absmode relation _name)
            (unless (or (inf-indentation? upper) (lower . <= . upper))
              (error "Lower bound is greater than upper bound"))
            (values lower upper absmode relation)))

(define (effective-relation state)
  (if (indent-state-absmode state)
      '=
      (indent-state-relation state)))

;; The central indentation store. As it is a parser parameter, it is local to every parser invocation.
(define indent-parameter (make-parser-parameter (indent-state 0 inf-indentation #f '>)))

(define (valid-indentation? state indent)
  (match-define (indent-state lower upper _ _) state)
  (match (effective-relation state)
    [(cons 'const x) (= x indent)]
    ['* #t]
    ['> (> indent lower)]
    ['>= (>= indent lower)]
    ['= (and (<= lower indent) (or (inf-indentation? upper) (<= indent upper)))]))

(define (make-indentation-error state indentation)
  (match-define (indent-state lower upper _ _) state)
  (define (make-error place)
    (format "indentation ~a. Expecting ~a." indentation place))
  (match (effective-relation state)
    [(cons 'const x) (make-error (~a "indentation" x #:separator " "))]
    ['* (error "* relation in indentation state should not fail")]
    ['> (make-error (~a "indentation greater than" lower #:separator " "))]
    ['>= (make-error (~a "indentation greater than or equal to" lower #:separator " "))]
    ['= (make-error (~a "indentation between" lower "and" upper #:separator " "))]))

;; Updates the indentation state's range to a sub-range based on the
;; indentation and the interal relation.
;;
;; This function assumes that the indentation is already validated by
;; `valid-indentation?` and *does not* check it again.
(define (update-indentation state indent)
  ;; Finds the minimum between the indentation and the potentially infinite upper indent
  (define (upper-update new-upper-bound upper)
    (cond
      [(or (inf-indentation? upper) (<= new-upper-bound upper)) new-upper-bound]
      [else upper]))

  (match-define (indent-state _ upper _ _) state)

  (define updated
    (match (effective-relation state)
      [(cons 'const _) state]
      ['* state]
      ['> (struct-copy indent-state state [upper (upper-update (sub1 indent) upper)])]
      ['>= (struct-copy indent-state state [upper (upper-update indent upper)])]
      ['= (struct-copy indent-state state [lower indent] [upper indent])]))

  (struct-copy indent-state updated [absmode #f]))

(define (syntax-box-indentation box)
  (add1 (srcloc-column (syntax-box-srcloc box))))
  
;; indent/p takes a parser that parses a token and returns a parser that
;; parses the token only if it has a valid indentation.
;;
;; indent/p can only take token parsers because this library does not interact
;; with the internals of megaparsack. indent/p has to consume *some* output to
;; work. This means that if indent/p sent a consuming error on indentation
;; failure, there's no way to actually recover without try. Instead, this
;; implementation assumes that any parser given always fails with an empty
;; error, which is usually satisfied by token parsers.
(define (indent/p parser)
  (try/p
    (do
     [previous-state <- (indent-parameter)]
     [box <- (syntax-box/p parser)]
     (define box-indentation (syntax-box-indentation box))
     (cond
       [(valid-indentation? previous-state box-indentation)
        (define new-state (update-indentation previous-state box-indentation))
        (do
          (indent-parameter new-state)
          (pure (syntax-box-datum box)))]
       [else (fail/p (message
                       (syntax-box-srcloc box)
                       (format "Token ~a at ~a" box (make-indentation-error previous-state box-indentation))
                       (list (format "~a" previous-state))))]))))


(define/contract (local-token-mode/p relation-transformer parser)
  (-> (-> relation? relation?) parser? parser?)
  (do
    [old-state <- (indent-parameter)]
    (parameterize/p
      ([indent-parameter (struct-copy indent-state
                                      old-state
                                      [relation (relation-transformer (indent-state-relation old-state))])])
      parser)))

(define (make-local-state relation outer-state)
  (define (compute-local-range relation outer-lower outer-upper)
    (match relation
      ['* (values 0 inf-indentation)]
      ['= (values outer-lower outer-upper)]
      [(cons 'const x) (values x x)]
      ['>= (values outer-lower inf-indentation)]
      ['> (values (add1 outer-lower) inf-indentation)]))

  (match-define (indent-state lower upper _ _ ) outer-state)
  (define-values (local-lower local-upper) (compute-local-range relation lower upper))
  (struct-copy indent-state outer-state [lower local-lower] [upper local-upper]))


(define (update-outer-from-local-state relation #:outer outer-state #:local local-state)
  (match-define (indent-state outer-lower outer-upper _ _) outer-state)
  (match-define (indent-state _ local-upper _ _) local-state)
  (match relation
    ['= local-state]
    ['* (struct-copy indent-state local-state [lower outer-lower] [upper outer-upper])]
    [(cons 'const _) (struct-copy indent-state local-state [lower outer-lower] [upper outer-upper])]
    ['>= (struct-copy indent-state local-state [lower outer-lower])]
    ['> (define restricted-upper
          (cond
            [(or (inf-indentation? local-upper) (< outer-upper local-upper)) outer-upper]
            [(> local-upper 0) (sub1 local-upper)]
            [else (error "local-indentation: assertion failed: local-upper > 0")]))
        (struct-copy indent-state local-state [lower outer-lower] [upper restricted-upper])]))

(define/contract (local-indentation/p relation parser)
  (-> relation? parser? parser?)
  (do
    [(and outer-state (indent-state _ _ absmode _)) <- (indent-parameter)] ; previous indentation interval
    (cond
      ;; Absmode is essentially a no-op for local indentation. This
      ;; absmode short-circuit isn't really necessary though, as it is the same
      ;; as '=, and '= similarly does the no-op explicitly.
      ;;
      ;; TODO wonder if this is better handled by make-local-state and
      ;; update-outer-from-local-state. On the one hand, this is less code; on
      ;; the other, this is non-obvious control flow. Or maybe I move '=
      ;; outside.
      [absmode parser]
      [else
       (do
         (indent-parameter (make-local-state relation outer-state)) ; set local interval
         [parsed-expression <- parser] ; run local parser
         [local-state <- (indent-parameter)] ; get the local interval after parser's execution
         (indent-parameter (update-outer-from-local-state relation #:outer outer-state #:local local-state)) ; Calculate the indentation range of subsequent parsers from local indentation range
         (pure parsed-expression))])))

(define/contract (absolute-indentation/p parser #:local? [local? #f])
  (-> parser? parser?)
  (do
    [(and outer-state (indent-state _ _ outer-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indent-state outer-state [absmode #t]))
    [parsed-expression <- parser]
    [(and local-state (indent-state _ _ local-absmode _)) <- (indent-parameter)]
    (indent-parameter (struct-copy indent-state local-state [absmode (if local?
                                                                         outer-absmode
                                                                         (and outer-absmode local-absmode))]))
    (pure parsed-expression)))


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
