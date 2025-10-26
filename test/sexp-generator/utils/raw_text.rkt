#lang racket
(require shrubbery)
(require shrubbery/parse)
(require shrubbery/property)
(require shrubbery/print)
(require racket/match)
(provide print_custom_sexp)
;;; This aim to convert a parsed sexp back into raw string
;;; Unfortunately, this implementation is errorneous
(define (custom-sexp->string sexp [indent 0])
  (define (indent-str n)
    (make-string n #\space))

  (define (join-lines xs)
    (string-join xs "\n"))

  (define (join-eles xs)
    (string-join xs " "))

  (define (join-alt-eles xs indent)
    (string-join (map (lambda (x) (string-append "\n" x)) xs) " "))

  (define (compile-alt-blocks xs indent)
    (map (lambda (item) (compile-alt-block item indent)) xs))

  (define (insert-pipe s)
    (define n (string-length s))
    (define (count-leading i)
      (if (or (>= i n) (not (char-whitespace? (string-ref s i))))
          i
          (count-leading (+ i 1))))
    (let ([i (count-leading 0)])
      (if (< i n)
          (string-append (substring s 0 i) "| " (substring s i))
          s)))

  (define (compile-alt-block item indent)
    (match item
      [(cons 'block rest)
       (join-eles (map (lambda (item) (insert-pipe (custom-sexp->string item indent))) rest))]
      [else (error "Unrecognized alt block")]))

  (cond
    [(list? sexp)
     (match sexp
       [(list 'op opcode) (symbol->string opcode)]
       [(cons 'parens rest) (string-append "(" (custom-sexp->string rest) ")")]
       [(cons 'brackets rest) (string-append "[" (custom-sexp->string rest) "]")]
       [(cons 'braces rest) (string-append "{" (custom-sexp->string rest) "}")]
       [(cons 'quotes rest) (string-append "'(" (custom-sexp->string rest) ")")]
       [(cons 'group rest)
        (string-append (indent-str indent)
                       (join-eles (map (lambda (item) (custom-sexp->string item indent)) rest)))]
       [(cons 'block rest)
        (string-append ":\n"
                       (join-lines (map (lambda (item) (custom-sexp->string item (+ indent 4)))
                                        rest)))]
       [(cons 'alts rest) (join-alt-eles (compile-alt-blocks rest indent) indent)]
       [(cons 'top rest) (join-eles (map (lambda (item) (custom-sexp->string item indent)) rest))]
       [else
        (string-append (indent-str indent)
                       (string-join (map (lambda (item) (custom-sexp->string item 0)) sexp) " "))])]
    [else (format "~a" sexp)]))

(define (print_custom_sexp sexp)
  (displayln (custom-sexp->string sexp)))

;;; Small test cases
(print_custom_sexp (list 'group
                         "let"
                         "m"
                         (list 'op '=)
                         "m"
                         (list 'op '*)
                         (list 'parens (list 'group "n" (list 'op '+) "a"))))

(define grp-test
  (list 'group
        "fun"
        "fourth"
        (list 'parens (list 'group "n" (list 'op '::) "Int"))
        (list 'block
              (list 'group "let" "m" (list 'op '=) "n" (list 'op '*) "n")
              (list 'group "let" "v" (list 'op '=) "m" (list 'op '*) "m")
              (list 'group
                    "println"
                    (list 'parens (list 'group "n" (list 'op '+&) "^4 = " (list 'op '+&) "v")))
              (list 'group "v"))))

(define alt-test
  (list 'group
        "if"
        "x"
        (list 'op '==)
        "y"
        (list 'alts
              (list 'block (list 'group (list 'op '@) "same"))
              (list 'block (list 'group (list 'op '@) "different")))))
  
(define complex-test
  (list 'group
        "fun"
        "fib"
        (list 'parens (list 'group "n"))
        (list 'block
              (list 'group
                    "match"
                    "n"
                    (list 'alts
                          (list 'block (list 'group 0 (list 'block (list 'group 0))))
                          (list 'block (list 'group 1 (list 'block (list 'group 1))))
                          (list 'block
                                (list 'group
                                      "n"
                                      (list 'block
                                            (list 'group
                                                  "fib"
                                                  (list 'parens (list 'group "n" (list 'op '-) 1))
                                                  (list 'op '+)
                                                  "fib"
                                                  (list 'parens
                                                        (list 'group "n" (list 'op '-) 2)))))))))))

(define (main)
  (print_custom_sexp complex-test)
  (displayln "")
  (print_custom_sexp alt-test)
  (newline)
  (print_custom_sexp grp-test)
  (newline)
  (print_custom_sexp (list 'group "let" "m" (list 'op '=) "m" (list 'op '*) "n")))

(module+ main (main))