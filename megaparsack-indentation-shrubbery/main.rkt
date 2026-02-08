#lang racket/base

(require (except-in racket/base do))
(require racket/function)
(require racket/syntax-srcloc)
(require data/monad)
(require data/applicative)
(require megaparsack)
(require megaparsack-indentation)

(require "lex.rkt")
(require "utils.rkt")

(provide shrubbery-parser
         document/p)

(define (parse-tokens parser tokens)
  (define (token->parser-token token)
    (syntax-box token (syntax-srcloc (token-value token))))
  (parse parser (map token->parser-token tokens)))

(define (token-indentation token)
  (add1 (syntax-column (token-value token))))

(define ((token-indentation-error state) token)
  (define indentation (token-indentation token))
  (format "Token ~a at ~a" token (make-indentation-error state indentation)))


(define indent/p
  (gen-indent/p
   token-indentation
   token-indentation-error))


(define (token/p name)
  (label/p
   (symbol->string name)
   (do [token <- (indent/p (satisfy/p (lambda (x) (and (token? x) (eq? (token-name x) name)))))]
     (pure (syntax->datum (token-value token))))))

(define (token-pred/p name pred)
  (define (satisfy-pred token)
    (and (token? token)
         (eq? (token-name token) name)
         (pred (syntax->datum (token-value token)))))
  (label/p
   (symbol->string name)
   (do [token <- (indent/p (satisfy/p satisfy-pred))]
     (pure (syntax->datum (token-value token))))))

(define (token-string=/p name str)
  (token-pred/p name (lambda (x) (string=? x str))))

(define (insensitive-token/p name)
  (label/p
   (symbol->string name)
   (do [token <- (satisfy/p (lambda (x) (and (token? x) (eq? (token-name x) name))))]
     (pure (syntax->datum (token-value token))))))


(define atom/p
  (label/p
   "atom"
   (or/p (token/p 'identifier)
         (token/p 'literal)
         (token/p 'operator))))

(define (string-last str)
  (string-ref str (sub1 (string-length str))))

(define newline/p
  (label/p
   "newline"
   (insensitive-token/p 'whitespace)))

(define line-continuation/p
  (do (token/p 'continue-operator) newline/p))

(define newlines/p
  (noncommittal/p (many/p newline/p)))

(define group-line
  (do
      [atoms <- (many+/p (or/p atom/p (delay/p opener-closers/p)))]
    (pure atoms)))

;; Ask if we want to have continuations parsed with * local indentation
(define group-line-with-continuation
  (do
      [first-line <- group-line]
    [continuations <- (local-indentation/p '* (many/p (do line-continuation/p group-line)))]
    (pure (apply append first-line continuations))))

(define group-fragment
  (do
      [first-line-with-continuation <- group-line-with-continuation]
    [operator-continuations <- (local-indentation/p
                                '>
                                (many/p
                                 (try/p (do
                                            newlines/p
                                          [op <- (absolute-indentation/p (token/p 'operator))]
                                          [operator-line-with-continuations <- group-line-with-continuation]
                                          (pure (cons op operator-line-with-continuations))))))]
    (pure (apply append first-line-with-continuation operator-continuations))))

(define (group/p-generator #:is-in-alt is-in-alt)
  (define colon-with-block/p
    (do
        (token/p 'block-operator)
      (cond
        [is-in-alt (or/p block-in-alt/p (do newlines/p block/p))]
        [else (do newlines/p block/p)])))

  (or/p
   ; Group exists
   (do
       [group <- group-fragment]
     (or/p

      ; => Group with empty block and alts
      (try/p (do (token/p 'block-operator)
               newlines/p
               [alts <- alts/p]
               (pure `(group ,@group ,alts))))

      ; Group and Block exist
      (do [block <- colon-with-block/p]
        (or/p
         ; => Group, Block, and Alt
         (try/p (do
                    newlines/p
                  [alts <- alts/p]
                  (pure `(group ,@group ,block ,alts))))
         ; => Group and Block
         (pure `(group ,@group ,block))))

      ; Group exists but Block doesn't
      (or/p
       ; => Group with Alt on another line
       (try/p (do
                  newlines/p
                [alts <- alts/p]
                (pure `(group ,@group ,alts))))
       (cond
         ; => Group
         [is-in-alt (pure `(group ,@group))]
         ; => Group with Alt on the same line
         [else (or/p
                (try/p (do
                           [alts <- (local-indentation/p '> alts/p)]
                         (pure `(group ,@group ,alts))))
                (pure `(group ,@group)))]))))

   ; Group does not exist
   (do [block <- colon-with-block/p]
     (or/p
      ; => Block and Alts
      (try/p (do
                 newlines/p
               [alts <- alts/p]
               (pure `(group ,block ,alts))))
      ; => Block
      (pure `(group ,block))))))

(define group/p (group/p-generator #:is-in-alt #f))
(define group-in-alt/p (group/p-generator #:is-in-alt #t))


(define (make-opener-closer/p identifier opener closer separator/p #:newline-separated [newline-separated #f])
  (do
      (token-string=/p 'opener opener)
    [groups <- (local-indentation/p
                '>
                (sep-end-by/p (do newlines/p
                                [groups <- (absolute-indentation/p
                                            (many/p group/p #:sep (noncommittal/p separator/p)))]
                                newlines/p
                                (pure groups))
                              (cond
                                [newline-separated (or/p separator/p void/p)]
                                [else separator/p])))]
    (local-indentation/p '* (token-string=/p 'closer closer))
    (pure (cons identifier (apply append groups)))))

(define comma/p
  (label/p "," (token/p 'comma-operator)))
(define semicolon/p
  (label/p ";" (token/p 'semicolon-operator)))

(define parens/p (make-opener-closer/p 'parens "(" ")" comma/p))
(define brackets/p (make-opener-closer/p 'brackets "[" "]" comma/p))
(define braces/p (make-opener-closer/p 'braces "{" "}" comma/p))
(define quotes/p (make-opener-closer/p 'quotes "'" "'" semicolon/p))

;; I don't know enough macros to generate opener-closer/p as succinct as this
; (define associations
;   '(
;     ('parens "(" ")" 'comma-operator)
;     ('brackets "[" "]" 'comma-operator)
;     ('braces "{" "}" 'comma-operator)
;     ('quotes "'" "'" 'semicolon-operator)
;     ('quotes "'«" "»'" 'semicolon-operator)
;     ))

(define opener-closers/p
  (or/p
   parens/p
   brackets/p
   braces/p
   quotes/p))

;; The entire document. This always produces one multi constructor.
;; This does not parse a #lang line at the beggining of a file. TODO Create
;; another bigger parser.
;; TODO Ask if multi in shrubbery output and <document> from
;; https://docs.racket-lang.org/shrubbery/group-and-block.html are the same thing?
(define document/p
  (do
      newlines/p
    [groups <- (sep-end-by/p (absolute-indentation/p group/p) newlines/p)]
    eof/p
    (pure (cons 'multi groups))))

(define block/p
  (local-indentation/p '>
                       (do
                           [groups <- (many+/p (try/p (absolute-indentation/p group/p)) #:sep newlines/p)]
                         (pure `(block . ,groups)))))

(define block-in-alt/p
  (local-indentation/p '>
                       (do
                           [leading-group <- (absolute-indentation/p group-in-alt/p)]
                         newlines/p
                         [groups <- (many/p (try/p (absolute-indentation/p group/p)) #:sep newlines/p)]
                         (pure `(block ,leading-group . ,groups)))))

(define alts/p
  (do
      [alts <- (many+/p
                (absolute-indentation/p
                 (many+/p (try/p (do
                                     (token/p 'bar-operator)
                                   [block <- block-in-alt/p]
                                   newlines/p
                                   (pure block))))))]
    (pure (cons 'alts (apply append alts)))))


(define (lex str)
  (define (whitespace-or-comment-token? token)
    (and (token? token)
         (or (and (eq? (token-name token) 'whitespace) (not (eq? #\newline (string-last (token-e token)))))
             (eq? (token-name token) 'comment))))

  (define input-port (open-input-string str))
  (port-count-lines! input-port)

  (filter
   (lambda (x) (not (whitespace-or-comment-token? x)))
   (lex-all input-port (lambda (token explanation) (raise (cons token explanation))))))

(define (run-parser-on-lexed parser str)
  (parse-tokens parser (lex str)))

(define (shrubbery-parser str)
  (run-parser-on-lexed document/p str))

(module+ main
  (displayln (lex "@typeset{Write @bold{\"hello\"}}")))


(module+ test
  (require data/either)
  (require rackunit)

  (check-equal? (shrubbery-parser "let dir = match dir.to_string() | \"R\": #'right | \"L\": #'left | \"U\": #'up | \"D\": #'down") (success '(multi (group a (alts (block (group b)) (block (group c)))))) "inline alt")
  (check-equal? (shrubbery-parser "a | b | c") (success '(multi (group a (alts (block (group b)) (block (group c)))))) "inline alt")
  (check-equal? (shrubbery-parser "a\n+") (success '(multi (group a) (group (op +)))) "group starting with operator after another group")
  (check-equal? (shrubbery-parser "a b ( a, b, c,\n      d, e, f, )") (success '(multi (parens (group a) (group b) (group c)))) "parens")
  (check-equal? (shrubbery-parser "a") (success '(multi (group a))) "single identifier")
  (check-equal? (shrubbery-parser "a b:\n c") (success '(multi (group a b (block (group c))))) "group with block")
  (check-equal? (shrubbery-parser "+") (success '(multi (group (op +)))) "operator")
  (check-equal? (shrubbery-parser "a b c d") (success '(multi (group a b c d))) "A simple group")
  (check-equal? (shrubbery-parser "a b c d\ne f g h") (success '(multi (group a b c d) (group e f g h))) "Multiple simple groups")
  (check-equal? (shrubbery-parser "a b c d\n+ e f g h") (success '(multi (group a b c d) (group (op +) e f g h))) "Group starting with operator")
  (check-equal? (shrubbery-parser "a b c d\n + e f g h") (success '(multi (group a b c d (op +) e f g h))) "Group with operator continuation")
  (check-equal? (shrubbery-parser "  a b c d\\\ne f g h") (success '(multi (group a b c d e f g h))) "Group with line continuation")
  (check-equal? (shrubbery-parser "a b c d:   e f g h\n           i j k l") (success '(multi (group a b c d (block (group e f g h) (group i j k l))))) "Groups should start on same indentation")
  (check-equal? (shrubbery-parser "a\n|    b\n     c") (success '(multi (group a (alts (block (group b) (group c)))))) "Alt with two groups")
  (check-equal? (shrubbery-parser "a\n|    b: d\n|c") (success '(multi (group a (alts (block (group b (block (group d)))) (block (group c)))))) "Alt then group")
  (check-equal? (shrubbery-parser "a\n| d\n  | c") (success '(multi (group a (alts (block (group d (alts (block (group c))))))))) "Alt in alt")
  (check-equal? (shrubbery-parser "a\n| d | c") (success '(multi (group a (alts (block (group d)) (block (group c)))))) "Inline alt")
  (check-equal? (shrubbery-parser "a\n| b | c\n| d") (success '(multi (group a (alts (block (group b)) (block (group c)) (block (group d)))))) "Alt in multiple same line alt")
  ; (check-equal? (shrubbery-parser "a\n| b\nc\n| d") (success '(multi (group a (alts (block (group b)))) (group c (alts (block (group d)))))) "Multiple alts")
  ; (check-equal? (shrubbery-parser "   a\nb") (failure '(multi (group a) (group b))) "Two groups")
  ; (check-equal? (shrubbery-parser "a\n   b") (failure '(multi (group a) (group b))) "Two groups")
  ; (check-equal? (shrubbery-parser "a b c d\n\n   e f g h") (failure '(multi (group a b c d) (group e f g h))) "Groups should start on same indentation")
  ; (check-equal? (shrubbery-parser "a b: d\nc") (success '(multi (group a b (block (group d))) (group c))) "block then group")
  )
