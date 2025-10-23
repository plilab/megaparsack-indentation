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



(provide call-with-peeking-port)

(struct peek-port (in [pos #:mutable]))

(define current-peek-port-key (gensym 'current-peek-port))
(define (current-peek-port) (continuation-mark-set-first #f current-peek-port-key))

;; make the port once, to minimize overhead:
(define peek-input-port
  (make-input-port
   'peeker
   (lambda (bstr)
     (define pp (current-peek-port))
     (define pos (peek-port-pos pp))
     (define n (peek-bytes! bstr pos (peek-port-in pp)))
     (cond
       [(eof-object? n) eof]
       [else
        (set-peek-port-pos! pp (+ pos n))
        n]))
   (lambda (bstr offset evt)
     (define pp (current-peek-port))
     (peek-bytes! bstr (+ offset (peek-port-pos pp)) (peek-port-in pp)))
   void))

(define (call-with-peeking-port in proc)
  (with-continuation-mark
   current-peek-port-key
   (peek-port in 0)
   (proc peek-input-port)))
