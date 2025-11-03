#lang racket
(require racket/syntax)
(require racket/gui)
(require syntax/parse)
(require shrubbery)
(require shrubbery/parse)
(require shrubbery/property)
(require shrubbery/print)
(require rackunit)
(require rhombus/parse)
(require racket/contract)
(require "./examples.rkt")
(require megaparsack-indentation-shrubbery)
(require megaparsack)
(require megaparsack/text)
(require megaparsack-indentation)


(provide parse-string-self-defined
         parse-info
         compare-sexps
         extract-sexp-diff
         check-sexps-equal?
         call_self_defined_parser
)

;;; Wraps the self defined parser from the megaparsack library
(define (call_self_defined_parser code)
  (with-handlers ([exn:fail? (lambda (exn)
                               (printf "Parse error: ~a\n" (exn-message exn))
                               (syntax->datum (syntax '())))])
    (parse-result! (shrubbery-parser code))))

;;; Racket shrubbery API to parse the program
(define/contract (parse-string-self-defined s)
  (-> string? syntax?)
  (with-handlers ([exn:fail? (lambda (exn)
                               (printf "Parse error: ~a\n" (exn-message exn))
                               (syntax '()))])
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
(define/contract (compare-sexps a b path [print? #t])
  (->* (sexp? sexp? list?) (boolean?) parse-info/c)
  (if print?
      (begin
        (display "actual: ")
        (displayln a)
        (display "expected: ")
        (displayln b)
        (newline))
      (display "finished comparison"))
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
(define/contract (check-sexps-equal? a b [print? #t])
  (->* (sexp? sexp?) (boolean?) void?)
  (define info (compare-sexps a b '() print?))
  (check-equal? (parse-info-symbol info)
                success
                (format "S-exp comparision failed: ~a \n Path to get to element: ~a"
                        (parse-info-message info)
                        (parse-info-location info))))

;;; Small example for debugging
(define sexp1 (syntax->datum (parse-string-self-defined prog1)))
(define sexp2 (syntax->datum (parse-string-self-defined prog1_2)))
(module+ main
  (define info (compare-sexps sexp1 sexp2 '()))
  (extract-sexp-diff sexp1 (parse-info-location info)))
