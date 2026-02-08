#lang racket/base

; File taken from https://github.com/racket/rhombus/commit/96d1c20d3a4362e472df8766461e6ecd56336159
;; Permission is hereby granted, free of charge, to any
;; person obtaining a copy of this software and associated
;; documentation files (the "Software"), to deal in the
;; Software without restriction, including without
;; limitation the rights to use, copy, modify, merge,
;; publish, distribute, sublicense, and/or sell copies of
;; the Software, and to permit persons to whom the Software
;; is furnished to do so, subject to the following
;; conditions:
;;
;; The above copyright notice and this permission notice
;; shall be included in all copies or substantial portions
;; of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
;; ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
;; TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
;; PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
;; SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
;; IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;; DEALINGS IN THE SOFTWARE.

(provide make-variant
         default-variant
         variant?
         variant-allow-operator?
         variant-indented-operator-continue?)

(struct variant (allow-operator?
                 indented-operator-continue?))

(define (make-variant #:allow-operator? [allow-operator? (lambda (str) #t)]
                      #:indented-operator-continue? [indented-operator-continue? (lambda (str) #t)])
  (define who 'make-variant)
  (unless (and (procedure? allow-operator?)
               (procedure-arity-includes? allow-operator? 1))
    (raise-argument-error who "(procedure-arity-includes/c 1)" allow-operator?))
  (unless (and (procedure? indented-operator-continue?)
               (procedure-arity-includes? indented-operator-continue? 1))
    (raise-argument-error who "(procedure-arity-includes/c 1)" indented-operator-continue?))
  (variant allow-operator?
           indented-operator-continue?))

(define default-variant (make-variant))
