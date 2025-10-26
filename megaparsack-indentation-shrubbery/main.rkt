#lang racket/base

(require (except-in racket/base do))
(require data/monad)
(require data/applicative)
(require megaparsack)
(require megaparsack/parser-tools/lex)
(require megaparsack-indentation)

(require "token.rkt")

(provide shrubbery-parser
         document/p)

(define operator/p
  (indent/p (do [operator <- (token/p 'operator)] (pure (list 'op operator)))))

(define atom/p
  (label/p "atom"
    (indent/p
      (or/p
        (token/p 'identifier)
        (token/p 'keyword)
        (token/p 'number)
        (token/p 'string)
        (token/p 'boolean)
        (token/p 'void)
        operator/p))))

(define line-continuation/p
  (token/p 'line-continuation))

(define group-line
  (many+/p (try/p atom/p)))

(define newlines/p
  (many/p (token/p 'newline)))

;; Ask if we want to have continuations parsed with * local indentation
(define group-line-with-continuation
  (do
    [first-line <- group-line]
    [continuations <- (local-indentation/p '* (many/p (do line-continuation/p group-line)))]
    (pure (apply append first-line continuations))))


(define group-fragment
  (do
    [first-line-with-continuation <- group-line-with-continuation]
    [operator-continuations <- (many/p
                                 (try/p (do
                                          [op <- (indent/p operator/p)]
                                          [operator-line-with-continuations <- group-line-with-continuation]
                                          (pure (cons op operator-line-with-continuations)))))]
    (pure (apply append first-line-with-continuation operator-continuations))))

(define group/p
  (do
   [group <- group-fragment]
   [block <- (or/p
               (try/p
                 (do
                   (token/p 'colon)
                   newlines/p
                   [block <- block/p]
                   (pure (list block))))
               (do void/p (pure '())))]
   [alts <- (or/p
              (try/p
                (do newlines/p
                  [alts <- alts/p]
                  (pure (list alts))))
              (do void/p (pure '())))]
   (pure (cons 'group (append group block alts)))))

;; The entire document. This always produces one multi constructor.
;; This does not parse a #lang line at the beggining of a file. TODO Create
;; another bigger parser.
;; TODO Ask if multi in shrubbery output and <document> from
;; https://docs.racket-lang.org/shrubbery/group-and-block.html are the same thing?
(define document/p
  (do
    newlines/p
    [groups <- (many+/p (absolute-indentation/p group/p) #:sep newlines/p)]
    newlines/p
    eof/p
    (pure (cons 'multi groups))))

(define block/p
  (local-indentation/p '>
    (do
      [groups <- (many/p (absolute-indentation/p (try/p (do newlines/p group/p))))]
      (pure (cons 'block groups)))))

(define alts/p
  (do
    [alts <- (many+/p
               (absolute-indentation/p
                 (many+/p (try/p (do
                                  (indent/p (token/p 'bar))
                                  [block <- block/p]
                                  newlines/p
                                  (pure block))))))]
    (pure (cons 'alts (apply append alts)))))

;; top-level
;; | a | b | c
;; | d | e | f

(define (shrubbery-parser str)
  (let ([in (open-input-string str)])
    (parse-tokens document/p (lex-shrubbery in))))

(module+ test
  (require data/either)
  (require rackunit)

  (check-equal? (shrubbery-parser "a\n| b\nc") (success '(multi (group a (alts (block (group b)))) (group c))) "Alt then group")
  ;; (check-equal? (parse-string shrubbery-parser "   a\nb") (failure '(multi (group a) (group b))) "Two groups")
  ;; (check-equal? (parse-string shrubbery-parser "a\n   b") (failure '(multi (group a) (group b))) "Two groups")
  (check-equal? (shrubbery-parser "a b c d") (success '(multi (group a b c d))) "A simple group")
  (check-equal? (shrubbery-parser "a b c d\ne f g h") (success '(multi (group a b c d) (group e f g h))) "Multiple simple groups")
  (check-equal? (shrubbery-parser "  a b c d\\\ne f g h") (success '(multi (group a b c d e f g h))) "Group with line continuation")
  (check-equal? (shrubbery-parser "a b c d\n+ e f g h") (success '(multi (group a b c d) (group (op +) e f g h)))) "Group with line operator continuation"
  ;; (check-equal? (shrubbery-parser "a b c d\n\n   e f g h") (failure '(multi (group a b c d) (group e f g h))) "Groups should start on same indentation")
  (check-equal? (shrubbery-parser "a b c d:   e f g h") (success '(multi (group a b c d (block (group e f g h)))))) "Groups should start on same indentation"
  (check-equal? (shrubbery-parser "a\n|    b\n     c") (success '(multi (group a (alts (block (group b) (group c)))))) "Alt with two groups")
  (check-equal? (shrubbery-parser "a\n|    b: d\n|c") (success '(multi (group a (alts (block (group b (block (group d)))) (block (group c))))))) "Alt then group"
  (check-equal? (shrubbery-parser "a b: d\nc") (success '(multi (group a b (block (group d))) (group c)))) "Alt then group"
  (check-equal? (shrubbery-parser "a\n| d\n  | c") (success '(multi (group a (alts (block (group d (alts (block (group c)))))))))) "Alt in alt"
  (check-equal? (shrubbery-parser "a\n| b\nc\n| d") (success '(multi (group a (alts (block (group b)))) (group c (alts (block (group d))))))) "Multiple alts"
  (check-equal? (shrubbery-parser "a\n| b | c\n| d") (success '(multi (group a (alts (block (group b)) (block (group c)) (block (group d))))))) "Alt in multiple same line alt")
