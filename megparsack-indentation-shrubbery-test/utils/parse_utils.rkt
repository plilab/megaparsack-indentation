#lang racket
(require shrubbery/parse)
(require rackunit)
(require racket/contract)

(provide parse-string-self-defined
         parse-info
         compare-sexps
         extract-sexp-diff
         check-sexps-equal?)

;;; Racket shrubbery API to parse the program
(define/contract (parse-string-self-defined s)
  (-> string? syntax?)
  (with-handlers ([exn:fail? (lambda (exn) (printf "Parse error: ~a\n" (exn-message exn)))])
    (define in (open-input-string s))
    (parse-all in)))

;;; Self-defined error message
(define success 'success)
(define failure 'failure)
(define success_msg "S-exp are equal")
(define failure_msg_format "Difference: ~a vs ~a")
(struct parse-info (symbol message location) #:transparent)

;;; Define contracts for for sexps and failure info
(define (status? x)
  (or (equal? x success) (equal? x failure)))

(define parse-info/c (struct/c parse-info status? string? list?))

(define (sexp? x)
  (or (symbol? x) (number? x) (string? x) (null? x) (pair? x)))

;;; Self-defined S-exps comparison
(define/contract (compare-sexps a b path)
  (-> sexp? sexp? list? parse-info/c)
  (cond
    [(equal? a b) (parse-info success success_msg '())]
    [(and (pair? a) (pair? b))
     (if (not (equal? (car a) (car b)))
         (parse-info failure (format failure_msg_format (car a) (car b)) (append path '(car)))
         (compare-sexps (cdr a) (cdr b) (append path '(cdr))))]
    [else (parse-info failure (format failure_msg_format a b) path)]))

;;; Return the different element
(define/contract (extract-sexp-diff s path)
  (-> sexp? list? sexp?)
  (cond
    [(null? path) s]
    [(eq? (car path) 'car) (extract-sexp-diff (car s) (cdr path))]
    [(eq? (car path) 'cdr) (extract-sexp-diff (cdr s) (cdr path))]
    [else (error "Invalid path element" (car path))]))

;;; RackUnit methods for parse-info
(define/contract (check-sexps-equal? a b)
  (-> sexp? sexp? void?)
  (define info (compare-sexps a b '()))
  (check-equal? (parse-info-symbol info)
                success
                (format "S-exp comparision failed: ~a \n Path to get to element: ~a"
                        (parse-info-message info)
                        (parse-info-location info))))

;;; Debugging
(module+ main
  (define sexp1 '(a b c d e f (g h)))
  (define sexp2 '(a b c d e f g h))
  (define info (compare-sexps sexp1 sexp2 '()))
  (extract-sexp-diff sexp1 (parse-info-location info)))
