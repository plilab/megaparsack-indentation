#lang racket/base

(require racket/string)
(require parser-tools/lex)
(require (prefix-in : parser-tools/lex-sre))

(provide
  shrubbery-lexer
  lex-shrubbery)

(define-tokens basic-tokens (bytestring string plainident identifier keyword number operator boolean void))
(define-empty-tokens punct-tokens (line-continuation comment colon newline bar))

(define-lex-abbrevs
  [plainident (:: (:or alphabetic #\_) (:* (:or alphabetic numeric #\_)))]

  [opchar (:or symbolic punctuation #\: #\|)]
  [tailopchar (:& opchar (:~ #\:))] ; "not / followed by / or *" covered by `operator` abbreviation

  ;; Defined similarly to https://github.com/racket/rhombus/blob/18ceb067256191783890bbbeb6b65393b2fb43bd/shrubbery-lib/shrubbery/lex.rkt#L139
  [operator (:- (:: opchar (:* tailopchar))
                (:or "|" ":" "~")
                (:: (:* any-char) (:or "//" "/*") (:* any-char)))]

  [decimal (:/ #\0 #\9)]
  [usdecimal (:or decimal #\_)]
  [hex (:or decimal (:/ #\a #\f) (:/ #\A #\F))]
  [ushex (:or hex #\_)]
  [octal (:/ #\0 #\7)]
  [usoctal (:or octal #\_)]
  [bit (:or #\0 #\1)]
  [usbit (:or bit #\_)]

  [nonneg (:: decimal (:* usdecimal))]

  [sign (:or #\+ #\-)]
  [exponent (:: (:or #\e #\E) (:? sign) nonneg)]

  [float (:or (:: (:? sign) nonneg #\. (:? nonneg) (:? exponent))
              (:: (:? sign) #\. nonneg (:? exponent))
              (:: (:? sign) nonneg exponent)
              "#inf"
              "#neginf"
              "#nan")]
  [integer (:: (:? sign) nonneg)]
  [hexinteger (:: (:? sign) "0x" hex (:* ushex))]
  [octalinteger (:: (:? sign) "0o" octal (:* usoctal))]
  [binaryinteger (:: (:? sign) "0b" bit (:* usbit))]
  [fraction (:: integer "/" (:& nonneg (complement "0")))]

  [unicode-escape
    ;; FIXME Some unicode ranges are invalid if we lex them like this.
    (:or (:: "\\u" (:** 1 4 hex))
         (:: "\\U" (:** 1 6 hex)))]
  [escape
   (:or "\\a"
        "\\b"
        "\\t"
        "\\n"
        "\\v"
        "\\f"
        "\\r"
        "\\e"
        "\\\""
        "\\\'"
        "\\\\"
        (:: "\\" (:** 1 3 octal))
        (:: "\\x" (:** 1 2 hex)))]
  [strelem (:or (:~ "\"" "\\" #\newline) escape unicode-escape)]
  ;; Idea to run range from \x00 to \xFF taken from https://github.com/racket/syntax-color/blob/e1c5ac5115ed3e6c52430390e6bf9b39c8c7e3df/syntax-color-lib/syntax-color/racket-lexer.rkt#L93
  [bytestrelem (:or (:- (:/ "\x00" "\xff") "\\" "\"") escape)]


  [line-continuation (:: #\\ #\newline)])

(define get-next-comment
  (lexer
    ["*/" -1]
    ["/*" 1]
    [(eof) eof]
    ;; TODO Why can't we just put any-char here?
    [(:or #\/ #\* (:* (:~ #\/ #\*))) (get-next-comment input-port)]
    ;; Operators can have */ embedded in them. Lexer picks the longest match, with the earlier match as tiebreaker.
    [operator (get-next-comment input-port)]))

(define (read-nested-comment num-opens input)
  (let ([diff (get-next-comment input)])
    (cond
      [(eq? eof diff) (error "encountered eof")]
      [else (let ([next-num-opens (+ diff num-opens)])
              (cond
                [(= 0 next-num-opens) (token-comment)]
                [else (read-nested-comment next-num-opens input)]))])))

(define (remove-underscores str)
  (string-replace str "_" ""))


(define shrubbery-lexer
  (lexer-src-pos
    ;;; Syntax-level grouping operators
    [":"
     (token-colon)]
    ["|"
     (token-bar)]

    ;;; Eof
    [(eof)
     eof]

    ;;; Identifiers
    [(:or plainident (:: "#%" plainident))
     (token-identifier (string->symbol lexeme))]
    [(:: "~" plainident)
     (token-keyword (string->symbol lexeme))]

    ;;; Line based parsing primitives
    [line-continuation
     (token-line-continuation)]
    [#\newline
     (token-newline)]

    ;;; Booleans
    ["#true"
     (token-boolean #t)]
    ["#false"
     (token-boolean #f)]

    ;;; Numbers
    [(:or float integer fraction)
     (token-number (string->number (remove-underscores lexeme)))]
    [hexinteger
     (token-number (string->number (remove-underscores (string-replace lexeme "0x" "" #:all? #f)) 16))]
    [octalinteger
     (token-number (string->number (remove-underscores (string-replace lexeme "0o" "" #:all? #f)) 8))]
    [binaryinteger
     (token-number (string->number (remove-underscores (string-replace lexeme "0b" "" #:all? #f)) 2))]

    ;;; Strings
    ;; Rhombus says that string can contiain the same characters as racket strings exlcluding whitespace
    ;; Racket strings referred to from https://docs.racket-lang.org/reference/reader.html#%28part._parse-string%29
    [(:: #\# #\" (:* bytestrelem) #\")
     (token-bytestring (read (open-input-string lexeme)))]
    [(:: #\" (:* strelem) #\")
     (token-string (read (open-input-string lexeme)))]

    ;;; Operator
    [operator
     (token-operator (string->symbol lexeme))]

    ;;; Void
    ["#void"
     (token-void (void))]

    ;;; Comments
    [(:: "//" (:* (:~ #\newline)))
      ;; Call the lexer to ignore the current lexeme
     (return-without-pos (shrubbery-lexer input-port))]
    [(:: "#!" (:* (:~ #\newline)) (:* (:: line-continuation (:~ #\newline))))
     (return-without-pos (shrubbery-lexer input-port))]
    ["/*"
     (return-without-pos
       (begin
        ;; Idea taken from https://github.com/racket/syntax-color/blob/e1c5ac5115ed3e6c52430390e6bf9b39c8c7e3df/syntax-color-lib/syntax-color/racket-lexer.rkt#L262
        (read-nested-comment 1 input-port)
        ;; Instead of returning a comment token, we discard it like in the canonical parser
        ;; TODO(mashfi) Do we need to know where a multi-line comment is at for any reason?
        (shrubbery-lexer input-port)))]
    [(:- whitespace #\newline)
     (return-without-pos (shrubbery-lexer input-port))]))

(define (lex-shrubbery str)
  (define in (open-input-string str))
  (port-count-lines! in)
  (let loop ([v (shrubbery-lexer in)])
    (cond [(void? (position-token-token v)) (loop (shrubbery-lexer in))]
          [(eof-object? (position-token-token v)) '()]
          [else (cons v (loop (shrubbery-lexer in)))])))

(module+ main
  (require racket/pretty)

  (pretty-print (lex-shrubbery "=")))
