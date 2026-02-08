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



(provide syntax-raw-property
         syntax-raw-prefix-property
         syntax-raw-inner-prefix-property
         syntax-raw-inner-suffix-property
         syntax-raw-suffix-property
         syntax-raw-tail-property
         syntax-opaque-raw-property
         syntax-raw-opaque-content-property
         syntax-raw-srcloc-property)

(define syntax-raw-property
  (case-lambda
    [(stx) (syntax-property stx 'raw)]
    [(stx val) (syntax-property stx 'raw val #t)]))

(define syntax-raw-prefix-property
  (case-lambda
    [(stx) (syntax-property stx 'raw-prefix)]
    [(stx val) (syntax-property stx 'raw-prefix val #t)]))

;; Just after a prefix, but sticks to a term instead of an
;; enclosing group, and counts as part of an enclosing group's
;; non-prefix content
(define syntax-raw-inner-prefix-property
  (case-lambda
    [(stx) (syntax-property stx 'raw-inner-prefix)]
    [(stx val) (syntax-property stx 'raw-inner-prefix val #t)]))

;; Just before a prefix, sticks to a term, etc.
(define syntax-raw-inner-suffix-property
  (case-lambda
    [(stx) (syntax-property stx 'raw-inner-suffix)]
    [(stx val) (syntax-property stx 'raw-inner-suffix val #t)]))

;; When attached to the head of a container encodings, applies
;; after the "tail"
(define syntax-raw-suffix-property
  (case-lambda
    [(stx) (syntax-property stx 'raw-suffix)]
    [(stx val) (syntax-property stx 'raw-suffix val #t)]))

;; "tail" is attached to the head term of a list, and it
;; applies after the last item in the list, but counts as
;; the representation of the list itself
(define syntax-raw-tail-property
  (case-lambda
    [(stx) (syntax-property stx 'raw-tail)]
    [(stx val) (syntax-property stx 'raw-tail val #t)]))

;; Hides any nested syntax and ignores an immediate 'raw property when
;; present and not #f; this is an emphemeral property and is attached
;; to the "parentheses" of a group or compound term
(define syntax-opaque-raw-property
  (case-lambda
    [(stx) (syntax-property stx 'opaque-raw)]
    [(stx val) (syntax-property stx 'opaque-raw val)]))

;; Similar to `syntax-opaque-raw-property`, but attached to the
;; head element of a compound value, and is not ephemeral
(define syntax-raw-opaque-content-property
  (case-lambda
    [(stx) (syntax-property stx 'raw-opaque-content)]
    [(stx val) (syntax-property stx 'raw-opaque-content val #t)]))

;; For associating a srcloc to a compound tag like `group`, which
;; otherwise gets a derived srcloc based on its content
(define syntax-raw-srcloc-property
  (case-lambda
    [(stx) (syntax-property stx 'raw-srcloc)]
    [(stx val) (syntax-property stx 'raw-srcloc val #t)]))
