#lang racket/base

(require data/monad)
(require data/applicative)
(require megaparsack)

(provide sep-by/p sep-end-by/p)

(define (sep-end-by%/p parser/p separator/p)
  (do [x <- parser/p]
    (or/p
     (do separator/p
       [xs <- (delay/p (sep-end-by/p parser/p separator/p))]
       (pure (cons x xs)))
     (pure (list x)))))
(define (sep-end-by/p parser/p separator/p)
  (or/p (sep-end-by%/p parser/p separator/p)
        (pure '())))

(define (sep-by%/p parser/p separator/p)
  (do [x <- parser/p]
    [xs <- (many/p (do separator/p parser/p))]
    (pure (cons x xs))))
(define (sep-by/p parser/p separator/p)
  (or/p (sep-by%/p parser/p separator/p)
        (pure '())))
