#lang racket/base

(require racket/runtime-path)
(require "./main.rkt")

(provide corpus-path)

(define-runtime-path corpus-path "corpus")

(module+ test
  (run-rhombus-compatibility-tests (list corpus-path)))
