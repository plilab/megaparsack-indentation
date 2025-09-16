#lang racket/base

(require (except-in racket/base do))
(require data/monad)
(require data/applicative)
(require megaparsack)
(require megaparsack/text)
(require megaparsack-indentation)

(require "token.rkt")

(provide shrubbery-parser)

(define atom/p
  (label/p "atom"
    (indent/p (or/p
                identifier/p
                plainident/p
                keyword/p
                operator/p
                ;; number/p
                boolean/p
                void-literal/p))))
                ;; string/p
                ;; bytestring/p
                ;; sexpression/p
                ;; comment/p)))

(define group-line
  (many+/p (try/p atom/p) #:sep non-nl-whitespace/p))

;; Ask if we want to have continuations parsed with * local indentation
(define group-line-with-continuation
  (do
    [first-line <- group-line]
    non-nl-whitespace/p
    [continuations <- (local-indentation/p '* (many/p
                                                (do line-continuation/p non-nl-whitespace/p group-line)
                                                #:sep non-nl-whitespace/p))]
    (pure (apply append first-line continuations))))


(define group-fragment
  (do
    [first-line-with-continuation <- group-line-with-continuation]
    [operator-continuations <- (many/p
                                 (try/p (do
                                          whitespace/p
                                          [op <- (indent/p operator/p)]
                                          non-nl-whitespace/p
                                          [operator-line-with-continuations <- group-line-with-continuation]
                                          (pure (cons op operator-line-with-continuations)))))]
    (pure (apply append first-line-with-continuation operator-continuations))))

; a b c d \n

; a b c d \n
;  + e f g h \n
; + x y z

; a b c d \n
;  e f g h

; How do I remove newlines?
; - Same line operator (ad-hoc skip over newlines)
; - newline-operator (\n\s*<operator>)


(define group/p
  (do
   [group <- group-line-with-continuation]
   [block <- (or/p
               (try/p
                 (do
                   non-nl-whitespace/p
                   (char/p #\:)
                   whitespace/p
                   [block <- block/p]
                   (pure (list block))))
               (do void/p (pure '())))]
   [alts <- (or/p
              (try/p
                (do whitespace/p
                  [alts <- alts/p]
                  (pure (list alts))))
              (do void/p (pure '())))]
   (pure (cons 'group (append group block alts)))))

;; The entire document. This always produces one multi constructor.
;; This does not parse a #lang line at the beggining of a file. TODO Create
;; another bigger parser.
;; TODO Ask if multi in shrubbery output and <document> from
;; https://docs.racket-lang.org/shrubbery/group-and-block.html the same thing?
(define document/p
  (do
    whitespace/p
    [groups <- (many+/p (absolute-indentation/p group/p) #:sep whitespace/p)]
    whitespace/p
    eof/p
    (pure (cons 'multi groups))))

(define block/p
  (local-indentation/p '>
    (do
      [groups <- (many/p (absolute-indentation/p (try/p (do whitespace/p group/p))))]
      (pure (cons 'block groups)))))

(define alts/p
  (do
    [alts <- (many+/p
               (absolute-indentation/p
                 (many+/p (do
                            (indent/p (char/p #\|))
                            whitespace/p
                            block/p)
                  #:sep non-nl-whitespace/p))
               #:sep whitespace/p)]
    (pure (cons 'alts (apply append alts)))))

;; top-level
;; | a | b | c
;; | d | e | f

(define shrubbery-parser document/p)

(module+ test
  (require data/either)
  (require rackunit)

  (check-equal? (parse-string shrubbery-parser "a\nb") (success '(multi (group a) (group b))) "Two groups")
  ;; (check-equal? (parse-string shrubbery-parser "   a\nb") (failure '(multi (group a) (group b))) "Two groups")
  ;; (check-equal? (parse-string shrubbery-parser "a\n   b") (failure '(multi (group a) (group b))) "Two groups")
  (check-equal? (parse-string shrubbery-parser "a b c d") (success '(multi (group a b c d))) "A simple group")
  (check-equal? (parse-string shrubbery-parser "a b c d\ne f g h") (success '(multi (group a b c d) (group e f g h))) "Multiple simple groups")
  (check-equal? (parse-string shrubbery-parser "  a b c d\\\ne f g h") (success '(multi (group a b c d e f g h))) "Group with line continuation")
  (check-equal? (parse-string shrubbery-parser "a b c d\n+ e f g h") (success '(multi (group a b c d) (group (op +) e f g h)))) "Group with line operator continuation"
  (check-equal? (parse-string shrubbery-parser "a b c d\n\n   e f g h") (failure '(multi (group a b c d) (group e f g h))) "Groups should start on same indentation")
  (check-equal? (parse-string shrubbery-parser "a b c d:   e f g h") (success '(multi (group a b c d (block (group e f g h)))))) "Groups should start on same indentation"
  (check-equal? (parse-string shrubbery-parser "a\n|    b\n     c") (success '(multi (group a (alts (block (group b) (group c)))))) "Alt with two groups")
  (check-equal? (parse-string shrubbery-parser "a\n|    b: d\n|c") (success '(multi (group a (alts (block (group b (block (group d)))) (block (group c))))))) "Alt then group"
  (check-equal? (parse-string shrubbery-parser "a b: d\nc") (success '(multi (group a b (block (group d))) (group c)))) "Alt then group")
