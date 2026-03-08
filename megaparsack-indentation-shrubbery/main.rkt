#lang racket/base

(require (except-in racket/base do))
(require racket/string)
(require racket/match)
(require racket/list)
(require racket/syntax-srcloc)
(require data/monad)
(require data/applicative)
(require megaparsack)
(require megaparsack-indentation)
(require scribble/srcdoc
         (for-doc racket/base scribble/manual))

(require "lex.rkt")
(require "utils.rkt")

(provide shrubbery-parser
         document/p)

;;;; -------------------------
;;;; Indentation library setup
;;;; -------------------------

(define (parse-tokens parser tokens)
  (define (token->parser-token token)
    (syntax-box token (syntax-srcloc (token-value token))))
  (parse parser (map token->parser-token tokens)))

(define (token-indentation token)
  (add1 (syntax-column (token-value token))))

(define ((token-indentation-error state) token)
  (define indentation (token-indentation token))
  (format "Token ~a at ~a" token (make-indentation-error state indentation)))


(define indent/p
  (gen-indent/p
   token-indentation
   token-indentation-error))

;;;; ------------------------
;;;; Token and lexeme parsers
;;;; ------------------------

;;; Shrubbery is whitespace sensitive. The lexer handles every
;;; whitespace-senstive ambiguity _except_ for at-notation commands (search
;;; "command" in https://docs.racket-lang.org/shrubbery/token-parsing.html to
;;; see its form), which is handled by the parser.
;;;
;;; We have token/p and lexeme/p for parsing tokens with whitespace sensitivity
;;; and insensitivity respectively.

;; token/p: string? -> parser?
;;
;; Parameters:
;;  name - The required token name
;;
;; Returns:
;;  A parser that parses a token if the following are satisfied
;;  - The token's name is equal to the parameter `name`
;;  - The token is at a valid indentation
(define (token/p name)
  (label/p
   (symbol->string name)
   (do
     [token <- (indent/p (satisfy/p (lambda (x) (and (token? x) (eq? (token-name x) name)))))]
     (pure (syntax->datum (token-value token))))))

;; lexeme/p: string? -> parser?
;;
;; Acts the same as token/p, but the parser discards any non-newline whitespace
;; token after the parsed token.
(define (lexeme/p name)
  (do
    [token <- (token/p name)]
    (or/p non-newline-whitespace/p void/p)
    (pure token)))

;; token-pred/p: string? predicate/c -> boolean?
;;
;; Parameters:
;;  name - The required token name
;;  pred - The function to test the token value against
;;
;; Returns:
;;  A parser that parses a token if the following are satisfied
;;  - The token's name is equal to the parameter `name`
;;  - The token's value passes `pred`
;;  - The token is at a valid indentation
(define (token-pred/p name pred)
  (define (satisfy-pred token)
    (and (token? token)
         (eq? (token-name token) name)
         (pred (syntax->datum (token-value token)))))
  (label/p
   (symbol->string name)
   (do
     [token <- (indent/p (satisfy/p satisfy-pred))]
     (pure (syntax->datum (token-value token))))))

;; lexeme/p: string? -> parser?
;;
;; Acts the same as token-pred/p, but the parser discards any non-newline
;; whitespace token after the parsed token.
(define (lexeme-pred/p name pred)
  (do
    [token <- (token-pred/p name pred)]
    (or/p non-newline-whitespace/p void/p)
    (pure token)))

(define (lexeme-string=/p name str)
  (lexeme-pred/p name (lambda (x) (string=? x str))))
(define (token-string=/p name str)
  (token-pred/p name (lambda (x) (string=? x str))))

;;;; -------------------------
;;;; Atomic and literal values
;;;; -------------------------

(define identifier/p
  (lexeme/p 'identifier))
(define literal/p
  (lexeme/p 'literal))
(define operator/p
  (lexeme/p 'operator))

(define comma/p
  (label/p "," (lexeme/p 'comma-operator)))
(define semicolon/p
  (label/p ";" (lexeme/p 'semicolon-operator)))

;;; The lexer gives whitespace tokens that with contiguous whitespace
;;; sequences. The sequenes are broken up into separate tokens after every
;;; newline.
;;;
;;; For example, if we notate spaces with _ and newlines with \n, then parsing
;;;
;;; ```
;;; a_b___\n
;;; \n
;;; _a_\n
;;; ```
;;;
;;; gives us the tokens "a" "_" "b" "___\n" "\n" "_" "a" "_\n".
;;;
;;; We can disambiguate between the two types by checking if there
;;; is a newline at the end of the whitespace token.

(define (string-last str)
  (string-ref str (sub1 (string-length str))))

(define newline/p
  (label/p
   "newline"
   (local-indentation/p '* (lexeme-pred/p 'whitespace (lambda (value) (eq? #\newline (string-last value)))))))

(define newlines/p
  (noncommittal/p (many/p newline/p)))

(define non-newline-whitespace/p
  (hidden/p
   (local-indentation/p '* (lexeme-pred/p 'whitespace (lambda (value) (not (eq? #\newline (string-last value))))))))

(define line-continuation/p
  (do
    (lexeme/p 'continue-operator) newline/p))

;;;; -------------------
;;;; Opener-closer pairs
;;;; -------------------

;; separated-groups/p: (->* (parser?) (#:newline-separated? boolean?) parser?)
;;
;; This parser parses a trailing separator if one exists.
;;
;; Parameters
;;  separator/p - Parser used to separate groups
;;  #:newline-separated? - Whether newlines can be used as separators instead of separator/p (default #f)
;;
;; Returns
;;  A parser that parses groups separated by separator/p (or a newline if
;;  #:newline-separated? is true). There can be multiple groups on the same
;;  line, with the lines of the groups being aligned at the first group of each
;;  line.
(define (separated-groups/p separator/p #:newline-separated? [is-newline-separated #f])
 (define line-separator
   (cond
     [is-newline-separated (or/p (do newlines/p separator/p newlines/p) (do newline/p newlines/p))]
     [else (do newlines/p separator/p newlines/p)]))

 (do
   [groups <- (local-indentation/p
               '*
               (sep-end-by/p (do
                               [groups <- (absolute-indentation/p
                                           (many/p group/p #:sep (noncommittal/p separator/p)))]
                               (pure groups))
                             line-separator))]
   (pure (apply append groups))))


(define (opener/p str)
  (lexeme-string=/p 'opener str))

(define (closer/p str)
  (lexeme-string=/p 'closer str))

;; make-opener-closer/p: (->* (string? string? parser?) (#:newline-separated boolean?) parser?)
;; 
;; Parses a group of parsers separated by separator/p between an opener and a
;; closer token. The handling of separator/p and optional newline separation is
;; done using separated-groups/p.
;;
;; Parameters
;;  identifier - Used to disambiguate output between different opener-closer pairs.
;;  opener - Parser to parse the opener
;;  closer - Parser to parse the closer
;;  separator - Parser used to separate groups
;;  #:newline-separated? - Whether newlines can be used as separators instead of separator/p (default #f)
;;
;; Returns:
;;  Parser that parses an opener, a list of groups separated by separator/p (or
;;  newlines if #:newline-separated? is true) and then a closer, and then
;;  returns a list of groups prefixed by the identifier.
;;
;;  For example, parsing `(a, b, c)` with (make-opener-closer/p 'paren "(" ")" comma/p) gives us (parens (group a) (group b) (group c))
(define (make-opener-closer/p identifier opener closer separator #:newline-separated? [is-newline-separated #f])

  (do
    opener
    newlines/p
    [groups <- (separated-groups/p separator #:newline-separated? is-newline-separated)]
    newlines/p
    (local-indentation/p '* closer)
    (pure `(,identifier . ,groups))))


(define parens/p (make-opener-closer/p 'parens (opener/p "(") (closer/p ")") comma/p))
(define brackets/p (make-opener-closer/p 'brackets (opener/p "[") (closer/p "]") comma/p))
(define braces/p (make-opener-closer/p 'braces (opener/p "{") (closer/p "}") comma/p))
(define quotes/p (make-opener-closer/p 'quotes (opener/p "'") (closer/p "'") semicolon/p #:newline-separated? #t))
(define quotes-alternate/p (make-opener-closer/p
                             'quotes
                             (do (token-string=/p 'opener "'") (opener/p "«"))
                             (do (token-string=/p 'closer "»") (closer/p "'"))
                             semicolon/p
                             #:newline-separated? #t))

(define opener-closers/p
  (or/p
   parens/p
   brackets/p
   braces/p
   quotes/p
   quotes-alternate/p))


;;;; At-notation

;;; This implementation parses at-notation separately and then splices them in
;;; a second pass in the group parser.

;;; XXX: Everything using opener/p and closer/p in this section (parens,
;;; brackets, at-arguments) uses lexeme-string=/p and assumes the braces text
;;; is immediately after without any whitespace. This works only because the
;;; lexer emits at's braces texts with separate 'at-opener 'at-closer tags. If
;;; the lexer changes in such a way that at's braces texts are ambiguous with
;;; other syntaxes, this **WILL** fail. It would make more sense for the
;;; closers in this section to work with the token instead of using
;;; lexeme-string=/p.

(define (process-at-text xs)
  xs)
    

;; XXX: This adopts the lexer's assumption that keywords are identifiers. This
;; is different from whatever the shrubbery specification asks, but it's how the
;; shrubbery parser is parsing commands.
(define command/p
  (or/p
    (do
      [leading-identifier <- (token/p 'identifier)]
      [rest-of-command <- (many/p (do
                                    [operator <- (noncommittal/p (token/p 'operator))]
                                    [identifier <- (token/p 'identifier)]
                                    (pure `(,operator ,identifier))))]
      (pure `(,leading-identifier . ,(apply append rest-of-command))))
    (token/p 'literal)
    parens/p
    brackets/p))
(define at-arguments (make-opener-closer/p 'parens (opener/p "(") (closer/p ")") comma/p #:newline-separated? #t))

(define (flip-at-bracket ch)
  (case ch
    [(#\<) #\>]
    [(#\>) #\<]
    [(#\[) #\]]
    [(#\]) #\[]
    [(#\() #\)]
    [(#\)) #\(]
    [(#\{) #\}]
    [(#\}) #\{]
    [else ch]))
(define (corresponding-at-closer at-opener)
  (list->string (map flip-at-bracket (string->list at-opener))))
(define at-comment
  (do
    (token/p 'at-comment)
    [opener <- (token/p 'at-opener)]
    (skip-many-until/p (token-string=/p 'at-closer (corresponding-at-closer opener)))))

(define at-text
  (do
    (token/p 'at-opener)
    [contents-or-ats <- (many/p (do (or/p at-comment void/p) (or/p (token/p 'at-content) (delay/p at/p))))]
    (token/p 'at-closer)
    (pure `(group (brackets . ,(process-at-text contents-or-ats))))))
 

(define at/p
  (do
    (token/p 'at)
    [ans <- (local-indentation/p '* (or/p
                                     ; Command exists
                                     (do
                                       [command <- command/p]
                                       (or/p
                                         (do
                                           ; => @ command ( argument , ... ) braced_text ...
                                           [arguments <- at-arguments]
                                           [texts <- (many/p at-text)]
                                           (pure `(at ,@command ,arguments . ,texts)))
                                           ; => @ command braced_text braced_text ...
                                           ; => @ command
                                         (do
                                           [texts <- (many/p at-text)]
                                           (pure `(at ,@command . ,texts)))))
          
                                     ; @ braced_text braced_text ...
                                     (do
                                       [texts <- (many+/p at-text)]
                                       (pure `(at . ,texts)))))]
    (or/p non-newline-whitespace/p void/p)
    (pure ans)))
      
(define (splice-at-notation line)
  (let loop ([xs line] [acc '()])
    (if (null? xs)
        (reverse acc)
        (match (first xs)
          [(cons 'at contents) (loop (rest xs) (append (reverse contents) acc))]
          [x (loop (rest xs) (cons x acc))]))))
    



;;;; Groups

(define group-line
  (do
    [atoms <- (many+/p (or/p identifier/p literal/p operator/p (delay/p opener-closers/p) at/p))]
    (pure (splice-at-notation atoms))))

; TODO: Ask if we want to have continuations parsed with * local indentation
(define group-line-with-continuation
  (do
    [first-line <- group-line]
    [continuations <- (local-indentation/p '* (many/p (do line-continuation/p group-line)))]
    (pure (apply append first-line continuations))))

;; This is a group with no block and no alts. It is not named anything specific
;; but is used in multiple places.
(define group-top-level
  (do
    [first-line-with-continuation <- group-line-with-continuation]
    [operator-continuations <- (local-indentation/p
                                '>
                                (many/p
                                 (try/p (do
                                          newlines/p
                                          [op <- (absolute-indentation/p (lexeme/p 'operator))]
                                          [operator-line-with-continuations <- group-line-with-continuation]
                                          (pure (cons op operator-line-with-continuations))))))]
    (pure (apply append first-line-with-continuation operator-continuations))))

(define (group/p-generator #:in-alt? is-in-alt)
  (define colon-with-block/p
    (do
      (lexeme/p 'block-operator)
      (cond
        [is-in-alt (or/p block-in-alt/p (do newlines/p block/p))]
        [else (do newlines/p block/p)])))

  (or/p
   ; Group exists
   (do
     [group <- group-top-level]
     (or/p

      ; => Group with empty block and alts
      (try/p (do
               (lexeme/p 'block-operator)
               newlines/p
               [alts <- alts/p]
               (pure `(group ,@group ,alts))))

      ; Group and Block exist
      (do
        [block <- colon-with-block/p]
        (or/p
         ; => Group, Block, and Alt
         (try/p (do
                  newlines/p
                  [alts <- alts/p]
                  (pure `(group ,@group ,block ,alts))))
         ; => Group and Block
         (pure `(group ,@group ,block))))

      ; Group exists but Block doesn't
      (or/p
       ; => Group with Alt on another line
       (try/p (do
                newlines/p
                [alts <- alts/p]
                (pure `(group ,@group ,alts))))
       (cond
         ; => Group
         [is-in-alt (pure `(group ,@group))]
         ; => Group with Alt on the same line
         [else (or/p
                (try/p (do
                         [alts <- (local-indentation/p '> alts/p)]
                         (pure `(group ,@group ,alts))))
                (pure `(group ,@group)))]))))

   ; Group does not exist
   (do
     [block <- colon-with-block/p]
     (or/p
      ; => Block and Alts
      (try/p (do
               newlines/p
               [alts <- alts/p]
               (pure `(group ,block ,alts))))
      ; => Block
      (pure `(group ,block))))))

(define group/p (group/p-generator #:in-alt? #f))
(define group-in-alt/p (group/p-generator #:in-alt? #t))

(define block/p
  (local-indentation/p '>
                       (do
                         [groups <- (many+/p (try/p (absolute-indentation/p group/p)) #:sep newlines/p)]
                         (pure `(block . ,groups)))))

(define block-in-alt/p
  (local-indentation/p '>
                       (do
                         [leading-group <- (absolute-indentation/p group-in-alt/p)]
                         newlines/p
                         [groups <- (many/p (try/p (absolute-indentation/p group/p)) #:sep newlines/p)]
                         (pure `(block ,leading-group . ,groups)))))

(define alts/p
  (do
    [alts <- (many+/p
              (absolute-indentation/p
               (many+/p (try/p (do
                                 (lexeme/p 'bar-operator)
                                 [block <- block-in-alt/p]
                                 newlines/p
                                 (pure block))))))]
    (pure (cons 'alts (apply append alts)))))


(define (group-comment #:in-alt? [is-in-alt #f])
  (define valid-comment-value
    (or/p
      semicolon/p
      (group/p-generator #:in-alt? is-in-alt)))
  (do
    (absolute-indentation/p (lexeme/p 'group-comment))
    (or/p valid-comment-value
          (do newlines/p (absolute-indentation/p valid-comment-value)))))
    

;; (define (many-groups/p #:in-alt? [is-in-alt #f])
;;   (define comment (group-comment #:in-alt? is-in-alt))
;;   (define separator (noncommittal/p (many+/p semicolon/p)))
;;   (do
;;     [group-lines <- (many/p
;;                      (do
;;                       [start <- (absolute-indentation/p (or/p
;;                                                           (do
;;                                                             (or/p semicolon/p comment)
;;                                                             (pure '()))
;;                                                           (do
;;                                                             [group <- group/p]
;;                                                             (pure `(,group)))))]
;;                       (or/p
;;                         (do separator
;;                           [remaining-groups <- (sep-end-by/p (local-indentation/p '> (or/p comment (group/p-generator #:in-alt? is-in-alt))) separator)]
;;                           (pure `(,@start . ,(filter void? remaining-groups))))
;;                         (pure `(,@start))))
;;                      #:sep newlines/p)]
;;     (pure (apply append group-lines))))


;;;; Document

;; The entire document. This always produces one multi constructor.
;; This does not parse a #lang line at the beginning of a file. TODO Create
;; another bigger parser.
;; TODO Ask if multi in shrubbery output and <document> from
;; https://docs.racket-lang.org/shrubbery/group-and-block.html are the same thing?
(define document/p
  (do
    newlines/p
    (or/p non-newline-whitespace/p void/p)
    [groups <- (sep-end-by/p (absolute-indentation/p group/p) newlines/p)]
    eof/p
    (pure (cons 'multi groups))))

;;;; Parsing strings

(define (lex str)
  (define (comment-token? token)
    (and (token? token)
         (eq? (token-name token) 'comment)))

  (define input-port (open-input-string str))
  (port-count-lines! input-port)

  (filter
   (lambda (x) (not (comment-token? x)))
   (lex-all input-port (lambda (token explanation) (raise (cons token explanation))))))

(define (shrubbery-parser str)
  (parse-tokens document/p (lex str)))

(module+ main
  (displayln (lex "#//a")))


(module+ test
  (require data/either)
  (require rackunit)

  (check-equal? (shrubbery-parser "let dir = match dir.to_string() | \"R\": #'right | \"L\": #'left | \"U\": #'up | \"D\": #'down") (success '(multi (group a (alts (block (group b)) (block (group c)))))) "inline alt")
  (check-equal? (shrubbery-parser "a | b | c") (success '(multi (group a (alts (block (group b)) (block (group c)))))) "inline alt")
  (check-equal? (shrubbery-parser "a\n+") (success '(multi (group a) (group (op +)))) "group starting with operator after another group")
  (check-equal? (shrubbery-parser "a b ( a, b, c,\n      d, e, f, )") (success '(multi (parens (group a) (group b) (group c)))) "parens")
  (check-equal? (shrubbery-parser "a") (success '(multi (group a))) "single identifier")
  (check-equal? (shrubbery-parser "a b:\n c") (success '(multi (group a b (block (group c))))) "group with block")
  (check-equal? (shrubbery-parser "+") (success '(multi (group (op +)))) "operator")
  (check-equal? (shrubbery-parser "a b c d") (success '(multi (group a b c d))) "A simple group")
  (check-equal? (shrubbery-parser "a b c d\ne f g h") (success '(multi (group a b c d) (group e f g h))) "Multiple simple groups")
  (check-equal? (shrubbery-parser "a b c d\n+ e f g h") (success '(multi (group a b c d) (group (op +) e f g h))) "Group starting with operator")
  (check-equal? (shrubbery-parser "a b c d\n + e f g h") (success '(multi (group a b c d (op +) e f g h))) "Group with operator continuation")
  (check-equal? (shrubbery-parser "  a b c d\\\ne f g h") (success '(multi (group a b c d e f g h))) "Group with line continuation")
  (check-equal? (shrubbery-parser "a b c d:   e f g h\n           i j k l") (success '(multi (group a b c d (block (group e f g h) (group i j k l))))) "Groups should start on same indentation")
  (check-equal? (shrubbery-parser "a\n|    b\n     c") (success '(multi (group a (alts (block (group b) (group c)))))) "Alt with two groups")
  (check-equal? (shrubbery-parser "a\n|    b: d\n|c") (success '(multi (group a (alts (block (group b (block (group d)))) (block (group c)))))) "Alt then group")
  (check-equal? (shrubbery-parser "a\n| d\n  | c") (success '(multi (group a (alts (block (group d (alts (block (group c))))))))) "Alt in alt")
  (check-equal? (shrubbery-parser "a\n| d | c") (success '(multi (group a (alts (block (group d)) (block (group c)))))) "Inline alt")
  (check-equal? (shrubbery-parser "a\n| b | c\n| d") (success '(multi (group a (alts (block (group b)) (block (group c)) (block (group d)))))) "Alt in multiple same line alt"))
  ; (check-equal? (shrubbery-parser "a\n| b\nc\n| d") (success '(multi (group a (alts (block (group b)))) (group c (alts (block (group d)))))) "Multiple alts")
  ; (check-equal? (shrubbery-parser "   a\nb") (failure '(multi (group a) (group b))) "Two groups")
  ; (check-equal? (shrubbery-parser "a\n   b") (failure '(multi (group a) (group b))) "Two groups")
  ; (check-equal? (shrubbery-parser "a b c d\n\n   e f g h") (failure '(multi (group a b c d) (group e f g h))) "Groups should start on same indentation")
  ; (check-equal? (shrubbery-parser "a b: d\nc") (success '(multi (group a b (block (group d))) (group c))) "block then group")
  
