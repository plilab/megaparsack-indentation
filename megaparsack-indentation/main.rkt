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
  indent-init
  indent/p
  absolute-indentation/p
  local-indentation/p
  local-token-mode/p)

(define inf-indentation
  (string->uninterned-symbol "megaparsack-indentation:infinite"))
(define (inf-indentation? a)
  (eq? inf-indentation a))

(define range-parameter (make-parser-parameter (cons 0 inf-indentation)))


(define (relation? a)
  (or (eq? '> a)
      (eq? '>= a)
      (eq? '= a)
      (eq? '* a)
      (and (pair? a) (eq? (car a) 'const) (not (inf-indentation? a)))))

(struct indent-state (absmode relation) #:transparent)
(define state-param (make-parser-parameter (indent-state #f '>)))
(define (effective-relation state)
  (if (indent-state-absmode state)
      '=
      (indent-state-relation state)))


(struct op (<= add1 sub1 bottom get wrap/p unwrap))
(define ((flip f) x y) (f y x))
(define (op-> op) (compose1 not (op-<= op)))
(define (op->= op) (flip (op-<= op)))
(define (op-< op) (compose1 not (flip (op-<= op))))

(define op-param
  (make-parser-parameter
    (op
      <=
      add1
      sub1
      0
      (lambda (box) (add1 (srcloc-column (syntax-box-srcloc box))))
      syntax-box/p
      syntax-box-datum)))

(define (indent-init #:<= [<= <=]
                     #:add1 [add1 add1]
                     #:sub1 [sub1 sub1]
                     #:bottom [bottom 0]
                     #:get [get (lambda (box) (add1 (srcloc-column (syntax-box-srcloc box))))]
                     #:wrap/p [wrap/p syntax-box/p]
                     #:unwrap [unwrap syntax-box-datum])
  (do
    (range-parameter (cons bottom inf-indentation))
    (op-param 
      (op
        <=
        add1
        sub1
        bottom
        get
        wrap/p
        unwrap))))


(define (valid-indentation? range rel op indent)
  (match-define (cons lower upper) range)
  (match rel
    [(cons 'const x) (= x indent)]
    ['* #t]
    ['> ((op-> op) indent lower)]
    ['>= ((op->= op) indent lower)]
    ['= (and ((op-<= op) lower indent) (or (inf-indentation? upper) ((op-<= op) indent upper)))]))

(define (make-indentation-error range rel indentation)
  (match-define (cons lower upper) range)
  (define (make-error place)
    (format "indentation ~a. Expecting ~a." indentation place))
  (match rel
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
(define (update-indentation range rel op indent)
  (define (indent-min indent upper)
    (cond
      [(or (inf-indentation? upper) ((op-<= op) indent upper)) indent]
      [else upper]))

  (match-define (cons lower upper) range)
  (match rel
    [(or (cons 'const _) '*) range]
    ['>= (cons lower (indent-min indent upper))]
    ['> (cons lower (indent-min ((op-sub1 op) indent) upper))]
    ['= (cons indent indent)]))

  
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

     [state <- (state-param)]
     (define relation (effective-relation state))

     [prev-range <- (range-parameter)]

     [op <- (op-param)]

     [box <- ((op-wrap/p op) parser)]

     (define indent ((op-get op) box))
     (cond
       [(valid-indentation? prev-range relation op indent)
        (define new-range (update-indentation prev-range relation op indent))
        (do
          (range-parameter new-range)
          (state-param (struct-copy indent-state state [absmode #f]))
          (pure ((op-unwrap op) box)))]
       [else (fail/p (message
                       (syntax-box-srcloc box)
                       (format "Token ~a at ~a" box (make-indentation-error prev-range relation indent))
                       (list (format "~a(~a . ~a)" relation (car prev-range) (cdr prev-range)))))]))))


(define/contract (local-token-mode/p relation-transformer parser)
  (-> (-> relation? relation?) parser? parser?)
  (do
    [state <- (state-param)]
    (parameterize/p
      ([state-param (struct-copy indent-state state
                                 [relation (relation-transformer (indent-state-relation state))])])
      parser)))


(define/contract (local-indentation/p cmp parser)
  (-> relation? parser? parser?)

  (define (make-local-range op outer-range)
    (match-define (cons lower upper) outer-range)
    (match cmp
          [(cons 'const x) (cons x x)]
          ['* (cons (op-bottom op) inf-indentation)]
          ['= (cons lower upper)]
          ['>= (cons lower inf-indentation)]
          ['> (cons (add1 lower) inf-indentation)]))

  (define (update-outer-range op #:outer outer-range #:local local-range)
    (match-define (cons outer-lower outer-upper) outer-range)
    (match-define (cons _local-lower local-upper) local-range)
    (match cmp
      [(or (cons 'const _) '*) outer-range]
      ['= local-range]
      ['>= (cons outer-lower local-upper)]
      ['> (define restricted-upper ; Minimum of outer's upper and (lower's upper - 1)
            (cond
              [(or (inf-indentation? local-upper) ((op-< op) outer-upper local-upper)) outer-upper]
              [((op-> op) local-upper (op-bottom op)) (sub1 local-upper)]
              [else (error "local-indentation: assertion failed: local-upper > 0")]))
          (cons outer-lower restricted-upper)]))

  (do
    [(indent-state absmode _) <- (state-param)] ; previous indentation interval
    (cond
      ;; Absmode is essentially a no-op for local indentation. This
      ;; absmode short-circuit isn't really necessary though, as it is the same
      ;; as '=, and '= does the no-op explicitly.
      ;;
      ;; TODO wonder if this is better handled by make-local-state and
      ;; update-outer-from-local-state. On the one hand, this is less code; on
      ;; the other, this is non-obvious control flow. Or maybe I move '=
      ;; outside.
      [absmode parser]
      [else
       (do
        [op <- (op-param)]

        [outer-range <- (range-parameter)]
        (range-parameter (make-local-range op outer-range))

        [parsed-expression <- parser]

        [local-range <- (range-parameter)]
        (range-parameter (update-outer-range op #:outer outer-range #:local local-range))

        (pure parsed-expression))])))

(define/contract (absolute-indentation/p parser #:local? [local? #f])
  (-> parser? parser?)
  (do
    [(and outer-state (indent-state outer-absmode _)) <- (state-param)]
    (state-param (struct-copy indent-state outer-state [absmode #t]))
    [parsed-expression <- parser]
    [(and local-state (indent-state local-absmode _)) <- (state-param)]
    (state-param (struct-copy indent-state local-state [absmode (if local?
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
