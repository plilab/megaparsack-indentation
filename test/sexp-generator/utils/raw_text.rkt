#lang racket
(require shrubbery)
(require shrubbery/parse)
(require shrubbery/property)
(require shrubbery/print)
(require racket/match)
(provide print_custom_sexp)
;;; This aim to convert a parsed sexp back into raw string

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

  (define (compile-alt-block item indent)
    (match item
      [(cons 'block rest) (join-eles (map (lambda (item) (custom-sexp->string item indent)) rest))]
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
       [(cons 'alts rest) (join-alt-eles (compile-alt-blocks rest (+ indent 4)) indent)]
       [(cons 'top rest) (join-eles (map (lambda (item) (custom-sexp->string item indent)) rest))]
       [else
        (string-append (indent-str indent)
                       (string-join (map (lambda (item) (custom-sexp->string item 0)) sexp) " "))])]
    [else (format "~a" sexp)]))

(define (print_custom_sexp sexp)
  (displayln (custom-sexp->string sexp)))

;;; Small tests
(print_custom_sexp (list 'group "let" "m" (list 'op '=) "m" (list 'op '*) "n"))
(displayln "")

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

(print_custom_sexp grp-test)
(displayln "")

(define alt-test
  (list 'group
        "if"
        "x"
        (list 'op '==)
        "y"
        (list 'alts
              (list 'block (list 'group (list 'op '@) "same"))
              (list 'block (list 'group (list 'op '@) "different")))))

(print_custom_sexp alt-test)
(displayln "")

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
(print_custom_sexp complex-test)