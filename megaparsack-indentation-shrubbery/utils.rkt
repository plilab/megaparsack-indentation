#lang racket/base

(require racket/function)

(require data/monad)
(require data/applicative)
(require megaparsack)

(provide sep-by/p sep-end-by/p skip-many-until/p)

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

(define (skip-many-until/p found/p)
  (or/p
    found/p
    (do
      (satisfy/p (const #t))
      (skip-many-until/p found/p))))

(define (sep-by%/p parser/p separator/p)
  (do [x <- parser/p]
    [xs <- (many/p (do separator/p parser/p))]
    (pure (cons x xs))))
(define (sep-by/p parser/p separator/p)
  (or/p (sep-by%/p parser/p separator/p)
        (pure '())))
