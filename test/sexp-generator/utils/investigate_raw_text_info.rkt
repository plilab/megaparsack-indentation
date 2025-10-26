#lang racket/base
(require racket/pretty
         racket/syntax-srcloc
         racket/symbol
         shrubbery/variant
         shrubbery/property
         shrubbery/write
         shrubbery/print
         shrubbery/parse)

(require megaparsack-indentation-shrubbery)
(require megaparsack)
(require megaparsack/text)
(require megaparsack-indentation)

(provide custom-sexp-syntax-translate)

(define (modified-shrubbery-syntax->string stx)
  (shrubbery-syntax->string stx
                            #:use-raw? #f
                            #:keep-prefix? #f
                            #:keep-suffix? #f
                            #:inner? #t
                            #:infer-starting-indentation? #f))

(define (custom-sexp-syntax-translate sexp)
  (modified-shrubbery-syntax->string (datum->syntax #f sexp)))

;;; a b: d
;;; c
(define test-sexp (list 'multi (list 'group 'a 'b (list 'block (list 'group 'd))) (list 'group 'c)))

(define test-sexp2 (list 'multi (list 'group 'a 'b 'c 'd)))

;;; a
;;; | d
;;;   | c
(define test-sexp3
  (list 'multi
        (list 'group
              'a
              (list 'alts
                    (list 'block (list 'group 'd (list 'alts (list 'block (list 'group 'c)))))))))

;;; a
;;; | b
;;; c
;;; | d
(define test-sexp4
  (list 'multi
        (list 'group 'a (list 'alts (list 'block (list 'group 'b))))
        (list 'group 'c (list 'alts (list 'block (list 'group 'd))))))

(define random_sample
  (list 'multi
        (list 'group
              'xnmu
              (list 'block
                    (list 'group
                          (list 'brackets (list 'block 'whcg) (list 'block '993))
                          (list 'parens (list 'block 'rzhg)))))))


(module+ main
  (display (modified-shrubbery-syntax->string
            (datum->syntax #f (syntax->datum (parse-all (open-input-string "a b c"))))))
  (newline)
  (display (modified-shrubbery-syntax->string (datum->syntax #f test-sexp)))
  (newline)
  (display (modified-shrubbery-syntax->string (datum->syntax #f test-sexp2)))
  (newline)
  (display (modified-shrubbery-syntax->string (datum->syntax #f test-sexp3)))
  (newline)
  (define code (modified-shrubbery-syntax->string (datum->syntax #f test-sexp4)))
  (display (datum->syntax #f (parse-result! (shrubbery-parser code))))
  (newline)
  (display (parse-all (open-input-string code)))
  (newline)
  (display (modified-shrubbery-syntax->string (datum->syntax #f random_sample))))
