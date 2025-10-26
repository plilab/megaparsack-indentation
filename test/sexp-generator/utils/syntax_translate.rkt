#lang racket/base
(require racket/pretty
         racket/syntax-srcloc
         racket/symbol
         shrubbery/variant)
(define (syntax-raw-identifier-property stx)
  (syntax-property (syntax-raw-property stx '()) 'identifier-as-keyword #t))

(define group-tag (syntax-raw-identifier-property (datum->syntax #f 'group)))
(define top-tag (syntax-raw-identifier-property (datum->syntax #f 'multi)))
(define parens-tag (syntax-raw-identifier-property (datum->syntax #f 'parens)))
(define brackets-tag (syntax-raw-identifier-property (datum->syntax #f 'brackets)))
(define alts-tag (syntax-raw-identifier-property (datum->syntax #f 'alts)))

(define tag-mapping
  (hash 'group group-tag 'multi top-tag 'parens parens-tag 'brackets brackets-tag 'alts alts-tag))
