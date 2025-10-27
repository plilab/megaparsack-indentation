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

(define (modified-shrubbery-syntax->string stx)
  (shrubbery-syntax->string stx
                            #:use-raw? #f
                            #:keep-prefix? #f
                            #:keep-suffix? #f
                            #:inner? #f
                            #:infer-starting-indentation? #f))

;;; Experiment to build some syntax objects to be parsed by shrubbery parser

;;; Experiment 1
(define base
  (syntax-raw-suffix-property (datum->syntax #f 'a (make-srcloc "" 1 1 #f #f))
                              (string->symbol "( )")))

(define paren (syntax-raw-tail-property (syntax-raw-property (datum->syntax #f 'parens) "(") ")"))

(define self-defined-sexp (datum->syntax #f (list paren base)))

(displayln (modified-shrubbery-syntax->string self-defined-sexp))

;;; Experiment 2
(define base_srcloc (make-srcloc "" 1 1 #f #f))

(define base2 (datum->syntax #f 'b (make-srcloc "" 3 1 #f #f)))

(define base3 (datum->syntax #f 'd))

(define block_tab
  (syntax-property (syntax-raw-property (datum->syntax #f 'block) ':) 'identifier-as-keyword #t))

(define grp_tab
  (syntax-property (syntax-raw-property (syntax-raw-inner-prefix-property
                                         (syntax-raw-suffix-property (datum->syntax #f 'group)
                                                                     (string->symbol "("))
                                         (string->symbol ")"))
                                        '())
                   'identifier-as-keyword
                   #t))

(define multi_tab
  (syntax-property (syntax-raw-property (datum->syntax #f 'multi) '()) 'identifier-as-keyword #t))

;;; Attempt to rebuild "a b: d"
(define self-defined-sexp2
  (datum->syntax
   #f
   (list multi_tab
         (datum->syntax
          #f
          (list grp_tab
                base
                base2
                (datum->syntax #f (list block_tab (datum->syntax #f (list grp_tab base3)))))))))

(define self-defined-sexp3 (datum->syntax #f '(multi (group a b (block (group c))))))
(displayln (modified-shrubbery-syntax->string self-defined-sexp3))
(write-shrubbery self-defined-sexp3
                 (current-output-port)
                 #:pretty? #t
                 #:armor? #f
                 #:prefer-multiline? #t)

(displayln self-defined-sexp2)
(displayln (modified-shrubbery-syntax->string self-defined-sexp2))

;;; Use test-str as an sample to get the meta info attached to each tag
(define test-str "a b: d")
(module+ main
  (newline)
  (define stx (parse-all (open-input-string test-str)))
  (displayln stx)
  (displayln (syntax-raw-property stx))
  (displayln (syntax-raw-prefix-property stx))
  (displayln (syntax-raw-inner-prefix-property stx))
  (displayln (modified-shrubbery-syntax->string stx))
  (displayln (syntax-srcloc stx))
  ;;; Decompose the initial list
  (define xs (syntax-e stx))
  (displayln xs)
  (newline)

  ;;; Investigate information stored in syntax multi
  (define head_ele (car xs))
  (displayln head_ele)
  (displayln (syntax-raw-prefix-property head_ele))
  (displayln (syntax-raw-suffix-property head_ele))
  (displayln (syntax-raw-inner-prefix-property head_ele))
  (displayln (syntax-raw-inner-suffix-property head_ele))
  (displayln (syntax-raw-opaque-content-property head_ele))
  (displayln (syntax-opaque-raw-property head_ele))
  (displayln (syntax-raw-property head_ele))
  (displayln (syntax-line head_ele))
  (syntax-line head_ele)
  (syntax-column head_ele)
  (syntax-position head_ele)
  (syntax-span head_ele)
  (syntax-srcloc head_ele)
  (newline)

  (define xs2 (syntax-e (car (cdr xs))))
  (displayln xs2)
  ;;; Investigate the info stored in a and b
  (define ae (car (cdr xs2)))
  (define be (car (cdr (cdr xs2))))
  (displayln ae)
  (displayln (syntax-raw-prefix-property ae))
  (displayln (syntax-raw-suffix-property ae))
  (displayln (syntax-raw-inner-prefix-property ae))
  (displayln (syntax-raw-inner-suffix-property ae))
  (displayln (syntax-raw-opaque-content-property ae))
  (displayln (syntax-opaque-raw-property ae))
  (displayln (syntax-raw-property ae))
  (displayln (syntax-srcloc ae))
  (displayln be)
  (displayln (syntax-raw-prefix-property be))
  (displayln (syntax-raw-suffix-property be))
  (displayln (syntax-raw-inner-prefix-property be))
  (displayln (syntax-raw-inner-suffix-property be))
  (displayln (syntax-raw-opaque-content-property be))
  (displayln (syntax-opaque-raw-property be))
  (displayln (syntax-raw-property be))
  (displayln (syntax-line be))
  (displayln (syntax-srcloc be))

  ;;; Investigate the info stored in syntax group
  (define block_ele (car xs2))
  (displayln block_ele)
  (displayln (syntax-raw-prefix-property block_ele))
  (displayln (syntax-raw-suffix-property block_ele))
  (displayln (syntax-raw-inner-prefix-property block_ele))
  (displayln (syntax-raw-inner-suffix-property block_ele))
  (displayln (syntax-raw-opaque-content-property block_ele))
  (displayln (syntax-opaque-raw-property block_ele))
  (displayln (syntax-raw-property block_ele))
  (displayln (syntax-line block_ele))

  ;;; See how the element a is used
  (define ele_1 (car (cdr xs)))
  (display ele_1)
  (displayln (syntax-raw-prefix-property ele_1))
  (displayln (syntax-raw-suffix-property ele_1))
  (displayln (syntax-raw-inner-prefix-property ele_1))
  (displayln (syntax-raw-inner-suffix-property ele_1))
  (displayln (syntax-raw-opaque-content-property ele_1))
  (displayln (syntax-opaque-raw-property ele_1))
  (displayln (syntax-raw-property ele_1))
  (displayln (syntax-line ele_1))

  ;;; Investigate block raw text
  (define blk0 (car (cdr (cdr (cdr xs2)))))
  (define blk (car (syntax-e blk0)))
  (displayln blk)
  (displayln (syntax-raw-prefix-property blk))
  (displayln (syntax-raw-suffix-property blk))
  (displayln (syntax-raw-inner-prefix-property blk))
  (displayln (syntax-raw-inner-suffix-property blk))
  (displayln (syntax-raw-opaque-content-property blk))
  (displayln (syntax-opaque-raw-property blk))
  (displayln (syntax-raw-property blk))
  (displayln (syntax-line blk))
  ;;;
  ;; (display (syntax-raw-property (car (cdr (cdr xs)))))
  )
