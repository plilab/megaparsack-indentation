#lang racket/base

(require racket/contract)
(require racket/fixnum)
(require racket/match)
(require data/either)

(module+ test
  (require rackunit))

(provide
 (contract-out
  [struct indentation-state ((lower indentation?) (upper indentation?) (absmode boolean?) (relation relation?))]
  [inf-indentation (indentation?)]
  [inf-indentation? (-> indentation? boolean?)]
  [update-indentation (-> indentation-state? indentation? (either/c string? indentation-state?))]))

(define (indentation? a)
  (and/c (natural-number/c a) (fixnum? a)))

(define (relation? a)
  (or (eq? '> a)
      (eq? '>= a)
      (eq? '= a)
      (eq? '* a)
      (and (pair? a) (= (car a) 'const) (indentation? (cdr a)))))


(struct indentation-state (lower upper absmode relation)
  #:guard (lambda (lower upper absmode relation _name)
            (unless (lower . <= . upper)
              (error "Lower bound is greater than upper bound"))
            (values lower upper absmode relation)))

(define (inf-indentation? a) (= (most-positive-fixnum) a))
(define inf-indentation (most-positive-fixnum))

(define (update-indentation state indentation)
  (match-define (indentation-state lower upper absmode relation) state)
  (define rel (cond [absmode '=]
                    [#t relation]))
  (match rel
    [(cons 'const x)
     (cond
       [(= x indentation) (success state)]
       [else (failure "const")])]
    ['* (success state)]
    ['>
     (cond
       [(< lower indentation)
        (success (struct-copy indentation-state state [lower (- indentation 1)]))]
       [else (failure ">")])]
    ['>=
     (cond
       [(<= lower indentation)
        (success (struct-copy indentation-state state [upper indentation]))]
       [else (failure ">=")])]
    ['=
     (cond
       [(and (<= lower indentation) (<= indentation upper))
        (success (struct-copy indentation-state state [lower indentation] [upper indentation]))]
       [else (failure "=")])]))


(module+ test
  ;; Any code in this `test` submodule runs when this file is run using DrRacket
  ;; or with `raco test`. The code here does not run when this file is
  ;; required by another module.

  (check-equal? (+ 2 2) 4))

(module+ main
  ;; (Optional) main submodule. Put code here if you need it to be executed when
  ;; this file is run using DrRacket or the `racket` executable.  The code here
  ;; does not run when this file is required by another module. Documentation:
  ;; http://docs.racket-lang.org/guide/Module_Syntax.html#%28part._main-and-test%29

  (require racket/cmdline)
  (define who (box "world"))
  (command-line
   #:program "my-program"
   #:once-each
   [("-n" "--name") name "Who to say hello to" (set-box! who name)]
   #:args ()
   (printf "hello ~a~n" (unbox who))))
