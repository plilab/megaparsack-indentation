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
  (indent/p (or/p
             identifier/p
             plainident/p
             keyword/p
             operator/p
             number/p
             boolean/p
             void/p
             string/p
             bytestring/p
             sexpression/p
             comment/p)))

(define whitespace/p
  (many/p space/p))

(define non-nl-whitespace/p
  (many/p (satisfy/p (lambda (x) (and (char-whitespace? x) (not (char=? #\newline x)))))))

(define group/p
  (do
    [delits <- (many/p atom/p #:sep non-nl-whitespace/p)]
    non-nl-whitespace/p
    (or/p)))

(define multi/p
  (do
    [groups <- (list/p (absolute-indentation/p group/p) #:sep whitespace/p)]
    (pure (cons 'multi groups))))

(define block/p
  (many/p
    (local-indentation/p '>
       (absolute-indentation/p group/p))))

(define alts/p
  (do
    [nested-alts <- (many+/p
                      (absolute-indentation/p
                        (many+/p (do
                                   (indent/p (char/p #\|))
                                   whitespace/p
                                   block/p) #:sep non-nl-whitespace/p)))]
    (pure (cons 'alts (apply append nested-alts)))))

(define shrubbery-parser multi/p)
