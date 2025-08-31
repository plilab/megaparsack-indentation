#lang racket/base

(require (except-in racket/base do))
(require data/monad)
(require data/applicative)
(require megaparsack)
(require megaparsack/text)
(require megaparsack-indentation)

(provide
  identifier/p
  plainident/p
  keyword/p
  operator/p
  number/p
  boolean
  void/p
  string/p
  bytestring/p
  sexpression/p
  comment/p
  at-comment/p)

(define identifier/p
  (do
    [ident <- (or/p
               plainident/p
               (do
                 (string/p "#%")
                 [ident <- plainident/p]
                 (pure (format "#%~a" ident))))]
    (pure (list 'identifier ident))))

(define plainident/p
  (do
    [starting-char <- (or/p letter/p (char/p #\=))]
    [rest-chars <- (many/p (or/p letter/p (char/p #\=) digit/p))]
    (pure (list->string (cons starting-char rest-chars)))))

(define keyword/p
  (do
    (char/p #\~)
    [identifier <- plainident/p]
    (pure (list 'keyword identifier))))

(define operator/p
  (error 'operator "not implemented"))

(define sign/p
  (or/p
    (char/p #\+)
    (char/p #\-)
    (void/p)))

(define decimal/p
  (char-between/p #\0 #\9))
(define hex/p
  (or/p (char-between/p #\0 #\9) (char-between/p #\a #\f) (char-between/p #\A #\F)))
(define octal/p
  (char-between/p #\0 #\7))
(define binary/p
  (one-of/p '(#\0 #\1)))

(define (digit-string/p digit/p)
  (do
    [digit-chunks <- (many+/p
                       (do
                         [digits <- (many+/p digit/p)]
                         (pure (list->string digits)))
                       #:sep (char/p #\_))]
    (pure (apply string-append digit-chunks))))

(define exponent/p
  (do
    (one-of/p #\e #\E)
    (digit-string/p decimal/p)))

;; The number from rhombus is massaged into a form that can be read by string->number
(define number/p
  (do
    [sign <- (do
               [sign-parse <- sign/p]
               (pure (cond
                      [(void? sign-parse) #\+]
                      [else sign-parse])))]
    [number-string <-
      (or/p
        ;;; Hexadecimal integer
        (do
          (string/p "0x")
          [digits <- (digit-string/p hex/p)]
          (pure (format "#x~a~a" sign digits)))
        ;;; Octal integer
        (do
          (string/p "0o")
          [digits <- (digit-string/p octal/p)]
          (pure (format "#o~a~a" sign digits)))
        ;;; Binary integer
        (do
          (string/p "0b")
          [digits <- (digit-string/p binary/p)]
          (pure (format "#b~a~a" sign digits)))
        ;;; Float with no digits before the "."
        (do
          (char/p #\.)
          [digits <- (digit-string/p decimal/p)]
          [exponent <- (or/p (exponent/p) (pure "0"))]
          (pure (format ".~ae~a" digits exponent)))
        (do
          ;; This can either be the integer part or the numerator, but I don't know a succint name for both
          [integer-part <- (digit-string/p decimal/p)]
          (or/p
            ;;; Floating point with only an exponent (no "." or fractional part)
            (do
              [exponent <- exponent/p]
              (pure (format "~ae~a" integer-part exponent)))
            ;;; Floating point with a "." with an optional fractional part and an optional exponent
            (do
              (char/p #\.)
              [fractional-part <- (or/p
                                    (digit-string/p decimal/p)
                                    (pure "0"))]
              [exponent <- (or/p
                            (exponent/p)
                            (pure "0"))]
              (pure (format "~a.~ae~a" integer-part fractional-part exponent)))
            ;;; Fraction
            ;; Shrubbery syntax defines that the denominator cannot be zero.
            ;; Canonical parser parses 1/0 as (group 1 (op /) 0). So we need to only try to parse.
            ;; Only parsing numbers might give weird errors because of this,
            ;; but it should not be a problem while parsing an entire program.
            (try/p (do
                    (char/p #\/)
                    [denominator-part <- (guard/p (digit-string/p decimal/p) (lambda (x) (string=? x "0")) "A positive decimal number")]
                    (pure (format "~a~a/~a" sign integer-part denominator-part))))
            ;;; Integer
            (pure integer-part))))]
    (pure (string->number number-string))))

(define boolean
  (or/p
    (chain (string/p "#true") (pure #t))
    (chain (string/p "#false") (pure #f))))

;; `void/p` is already a function in megaparsack
(define void-literal/p
  (chain (string/p "#void") (pure (void))))

;; string/p is already a function in megaparsack
(define string-literal/p
  (error 'string-literal/p "not implemented"))

(define bytestring/p
  (error 'bytestring/p "not implemented"))

(define sexpression/p
  (error 'sexpression/p "not implemented"))

(define comment/p
  (error 'comment/p "not implemented"))

;; Only within at-text
(define at-comment/p
  (error 'at-comment/p "not implemented"))
