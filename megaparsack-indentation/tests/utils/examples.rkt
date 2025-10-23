#lang racket
(provide prog1 prog1_2 prog2)

(define prog1
  (string-append
   "~fun add(x, y):\n"
   "  x + y\n"
   "~fun twice(f, v):\n"
   "  f(f(v))"))


(define prog1_2
  (string-append
   "fun add(x, y):\n"
   "  x + y\n"
   "fun twp(f, v):\n"
   "  f(f(v))"))


(define prog2
  (string-append
   "fun sum(n):\n"
   "  total = 0\n"
   "  for i in range(n):\n"
   "    total = total + i\n"
   "  total\n"))
