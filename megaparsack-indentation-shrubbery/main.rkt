#lang racket/base

(require (except-in racket/base do))
(require racket/match)
(require racket/list)
(require racket/string)
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
    (?/p non-newline-whitespace/p)
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
    (?/p non-newline-whitespace/p)
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

(define (string-last str)
  (string-ref str (sub1 (string-length str))))

;; The lexer gives whitespace tokens that with contiguous whitespace
;; sequences. The sequenes are broken up into separate tokens after every
;; newline.
;;
;; For example, if we notate spaces with _ and newlines with \n, then parsing
;;
;; ```
;; a_b___\n
;; \n
;; _a_\n
;; ```
;;
;; gives us the tokens "a" "_" "b" "___\n" "\n" "_" "a" "_\n".
;;
;; We can disambiguate between the two types by checking if there
;; is a newline at the end of the whitespace token.
(define (newline-whitespace? value)
  (eq? #\newline (string-last value)))

(define newline/p
  (label/p
   "newline"
   (local-indentation/p '* (lexeme-pred/p 'whitespace newline-whitespace?))))

(define newlines/p
  (noncommittal/p (many/p newline/p)))

(define non-newline-whitespace/p
  (hidden/p
   (local-indentation/p '* (lexeme-pred/p 'whitespace (compose1 not newline-whitespace?)))))

(define line-continuation/p
  (do
    (lexeme/p 'continue-operator) newline/p))

;;;; ----------
;;;; Sequencing
;;;; ----------

(define (sequence-rest parser/p separator/p acc)
  (or/p
    (do
      (local-indentation/p '* separator/p)
      (or/p
        (sequence-inline parser/p separator/p sequence-rest acc)
        (do
          newlines/p
          (sequence-aligned parser/p separator/p sequence-rest acc))
        (pure acc)))
    (pure acc)))

(define (sequence-rest-optional-separator parser/p separator/p acc)
  (define aligned
    (do
      newlines/p
      (sequence-aligned parser/p separator/p sequence-rest-optional-separator acc)))
  (or/p
    (do
      (local-indentation/p '* separator/p)
      (or/p
        (sequence-inline parser/p separator/p sequence-rest-optional-separator acc)
        aligned
        (pure acc)))
    aligned
    (pure acc)))

(define (sequence-inline parser/p separator/p rest/p acc)
  (define (rest acc) (rest/p parser/p separator/p acc))
  (or/p
    (do
      (local-indentation/p
        '*
        (do
          (absolute-indentation/p (lexeme/p 'group-comment))
          (or/p
            (do newlines/p (absolute-indentation/p parser/p))
            parser/p)))
      (rest acc))
    (do
      [x <- (local-indentation/p '* parser/p)]
      (rest (cons x acc)))))

(define (sequence-aligned parser/p separator/p rest/p acc)
  (define (rest acc) (rest/p parser/p separator/p acc))
  (or/p
    (do
      (or/p
        (do
          (noncommittal/p (absolute-indentation/p (lexeme/p 'group-comment)))
          parser/p)
        (try/p (do
                (local-indentation/p '* (lexeme/p 'group-comment))
                newlines/p
                (absolute-indentation/p parser/p))))
      (rest acc))
    (do
      [x <- (absolute-indentation/p parser/p)]
      (rest (cons x acc)))))

(define (rev/p parser)
  (do
    [xs <- parser]
    (pure (reverse xs))))

(define (sequence+/p parser/p separator/p)
  (rev/p (sequence-aligned parser/p separator/p sequence-rest '())))

(define (sequence/p parser/p separator/p)
  (or/p (sequence+/p parser/p separator/p)
        (pure '())))

(define (sequence-optional-separator+/p parser/p separator/p)
  (rev/p (sequence-aligned parser/p separator/p sequence-rest-optional-separator '())))

(define (sequence-optional-separator/p parser/p separator/p)
  (or/p (sequence-optional-separator+/p parser/p separator/p)
        (pure '())))

;;;; -------------------
;;;; Opener-closer pairs
;;;; -------------------


(define (opener/p str)
  (label/p str
    (lexeme-string=/p 'opener str)))

(define (closer/p str)
  (label/p str
    (lexeme-string=/p 'closer str)))

(define (between/p opener closer inside)
  (do
    opener
    newlines/p
    [in <- (local-indentation/p '* inside)]
    newlines/p
    (local-indentation/p '* closer)
    (pure in)))

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
(define (make-opener-closer/p identifier opener closer separator)
  (do
    [groups <- (between/p opener closer (sequence/p (delay/p (group/p #:in-alt? #f)) separator))]
    (pure `(,identifier . ,groups))))


(define parens/p (make-opener-closer/p 'parens (opener/p "(") (closer/p ")") comma/p))
(define brackets/p (make-opener-closer/p 'brackets (opener/p "[") (closer/p "]") comma/p))
(define braces/p (make-opener-closer/p 'braces (opener/p "{") (closer/p "}") comma/p))

(define alts-or-group*/p
  (or/p
    (do [alts <- (delay/p alts/p)] (pure `((group ,alts))))
    (delay/p (group*/p))))

(define quotes/p
  (do
    [groups <- (or/p
                 (do
                   (label/p "'«" (do (noncommittal/p (token-string=/p 'opener "'")) (opener/p "«")))
                   newlines/p
                   [groups <- (local-indentation/p '* alts-or-group*/p)]
                   newlines/p
                   (local-indentation/p '* (label/p "'»" (do (token-string=/p 'closer "»") (closer/p "'"))))
                   (pure groups))
                 (do
                   (opener/p "'")
                   newlines/p
                   [groups <- (local-indentation/p '* alts-or-group*/p)]
                   newlines/p
                   (local-indentation/p '* (closer/p "'"))
                   (pure groups)))]
    (pure `(quotes . ,groups))))

                 

(define opener-closers/p
  (or/p
   parens/p
   brackets/p
   braces/p
   quotes/p))


;;;; At-notation

;;; This implementation parses at-notation separately and then splices them in
;;; a second pass in the group parser.

;;; XXX(Mashfi): Everything using opener/p and closer/p in this section (at paren form,
;;; at bracket form, at-arguments) uses lexeme-string=/p and assumes the braces text
;;; is immediately after without any whitespace. This works only because the
;;; lexer emits at's braces texts with separate 'at-opener 'at-closer tags. If
;;; the lexer changes in such a way that at's braces texts are ambiguous with
;;; other syntaxes, this **WILL** fail. It would make more sense for the
;;; closers in this section to work with the token directly instead of using
;;; lexeme-string=/p, but I'm lazy right now.

(define (process-at-text xs)
  (define (group-by-newlines xs)
    (let loop ([xs xs] [current '()] [acc '()])
      (match xs
        [(or (list (syntax-box "\n" _)) (list (syntax-box "\n" _) (syntax-box (pregexp #px"^[ \t]+$") _)))
         (if (null? current)
             (reverse acc)
             (reverse (cons (reverse current) acc)))]
        [(list) (reverse (cons (reverse current) acc))]
        [(list-rest (syntax-box "\n" _) remaining)
         (loop remaining '() (cons (reverse current) acc))]
        [(list-rest x remaining)
         (loop remaining (cons x current) acc)])))

  (define (first-non-whitespace-index str)
    (or (for/first ([c (in-string str)]
                    [i (in-naturals)]
                    #:when (not (char-whitespace? c)))
         i) 0))

  (define (find-lowest-indentation xs)
    (define (line-indentation boxes)
      (if (null? boxes)
          0
          (match (first boxes)
            [(syntax-box (? string? s) (srcloc _ _ column _ _))
             (+ column (first-non-whitespace-index s))]
            [_ 0])))
    (apply
      min
      9999
      (map line-indentation xs)))

  (define (line->groups boxes)
    (let loop ([xs boxes] [acc '()])
      (match xs
        [(list)
         (reverse acc)]
        [(list (syntax-box (? string? s) _))
         (let ([trimmed (string-trim s #:left? #f)])
           (if (equal? trimmed "")
               (reverse acc)
               (reverse `((group ,trimmed) . ,acc))))]
        [(cons (syntax-box (? string? s) _) xs)
         (loop xs `((group ,s) . ,acc))]
        [(cons (syntax-box `(at . ,at) _) xs)
         (loop xs `((group . ,at) . ,acc))])))

  (define (process-line-first-element str column min-indentation)
    (match-define (list _ leading-whitespace actual-string) (regexp-match #px"^(\\s*)(.*)" str))
    (define actual-group (if (equal? "" actual-string) '() `((group ,actual-string))))
    (cond
      [(< min-indentation column) `(,@(if (equal? "" leading-whitespace) '() `((group ,leading-whitespace))) ,@actual-group)]
      [else
       (define relative-min-indentation (- min-indentation column))
       (define indentation (string-length leading-whitespace))
       (cond
         [(>= relative-min-indentation indentation)
          actual-group]
         [else
           `((group ,(make-string (- indentation relative-min-indentation) #\space)) ,@actual-group)])]))

  (define (process-line boxes min-indentation)
    (match boxes
      [(list (syntax-box (? string? s) (srcloc _ _ column _ _)))
       (process-line-first-element (string-trim s #:left? #f) column min-indentation)]
      [(list-rest (syntax-box (? string? s) (srcloc _ _ column _ _)) boxes)
       `(,@(process-line-first-element s column min-indentation)
          ,@(line->groups boxes))]
      [_ (line->groups boxes)]))

  (define (process xs)
    (define lines (group-by-newlines xs))
    (define min-indentation (find-lowest-indentation lines))
    (apply append (add-between
                    (map (lambda (line) (process-line line min-indentation)) lines)
                    '((group "\n")))))

  (match xs
    [(list) '()]
    [(list (syntax-box (? string? a) _))
     `((group ,a))]
    [(list (syntax-box "\n" _) (syntax-box (pregexp #px"[ \t]+") _))
     '((group "\n"))]
    [(list-rest (syntax-box "\n" _) left-trimmed)
     (process left-trimmed)]
    [_
     (process xs)]))
    

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
    (do
      [val <- (or/p (token/p 'literal)
                parens/p
                brackets/p)]
      (pure (list val)))))
(define at-arguments 
  (do
    [groups <- (between/p
                 (opener/p "(")
                 (closer/p ")")
                 (sequence-optional-separator/p (delay/p (group/p #:in-alt? #t)) comma/p))]
    (pure groups)))

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
    [contents-or-ats <- (many/p (syntax-box/p (do (?/p at-comment) (or/p (token/p 'at-content) (delay/p at/p)))))]
    (token/p 'at-closer)
    (pure `(group (brackets . ,(process-at-text contents-or-ats))))))
 

(define at/p
  (do
    (noncommittal/p (token/p 'at))
    [at <- (local-indentation/p
             '*
             (or/p
              (try/p (do
                      (label/p
                        "(«"
                        (do
                         (noncommittal/p (token-string=/p 'opener "("))
                         (opener/p "«")))
                      newlines/p
                      [top <- (local-indentation/p '* group-top-level)]
                      newlines/p
                      (label/p
                        "»)"
                        (do
                          (token-string=/p 'closer "»")
                          (closer/p ")")))
                      (pure `(at . ,top))))
              ; Command exists
              (do
                [command <- command/p]
                (or/p
                  (do
                    ; => @ command ( argument , ... ) braced_text braced_text...
                    [arguments <- at-arguments]
                    [texts <- (many/p at-text)]
                    (pure `(at ,@command (parens ,@arguments ,@texts))))
                  ; => @ command braced_text braced_text ...
                  (do
                    [texts <- (many+/p at-text)]
                    (pure `(at ,@command (parens ,@texts))))
                  ; => @ command
                  (do
                    (pure `(at ,@command)))))

              ; @ braced_text braced_text ...
              (do
                [texts <- (many+/p at-text)]
                (pure `(at (parens ,@texts))))))]
    (?/p non-newline-whitespace/p)
    (pure at)))
      
(define (splice-at-notation line)
  (let loop ([xs line] [acc '()])
    (if (null? xs)
        (reverse acc)
        (match (first xs)
          [(cons 'at contents) (loop (rest xs) (append (reverse contents) acc))]
          [x (loop (rest xs) (cons x acc))]))))

(define at-end/p
  (do
    (label/p
      "(«"
      (do
       (token-string=/p 'opener "(")
       (opener/p "«")))
    newlines/p
    [group <- (local-indentation/p '* (group/p #:in-alt? #f))]
    newlines/p
    (label/p
      "»)"
      (do
        (token-string=/p 'closer "»")
        (closer/p ")")))
    (pure `(at . ,(cdr group)))))
    



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
                                 (do
                                    newlines/p
                                    [op <- (absolute-indentation/p (lexeme/p 'operator))]
                                    [operator-line-with-continuations <- group-line-with-continuation]
                                    (pure (cons op operator-line-with-continuations)))))]
    (pure (apply append first-line-with-continuation operator-continuations))))

(define guillemet/p
  (do
    (opener/p "«")
    (closer/p "»")
    (pure '(block))))

(define (group/p #:in-alt? in-alt?)
  (define inlinable-alts
    (cond
      [in-alt? (do newlines/p alts/p)]
      [else (or/p (local-indentation/p '> alts/p) (do newlines/p alts/p))]))
  (define rest/p
    (or/p
      at-end/p
      (do
        (lexeme/p 'block-operator)
        [rest <- (or/p
                   (do
                     [block <- guillemet/p]
                     [alts <- (?/p inlinable-alts)]
                     (pure (cons block alts)))
                   (do
                     [block <- (cond [in-alt? block-in-alt/p] [else (do newlines/p block/p)])]
                     [alts <- (?/p (do newlines/p alts/p))]
                     (pure (cons block alts)))
                   (do
                     [alts <- (do newlines/p alts/p)]
                     (pure (cons (void) alts))))]
        (pure (match rest
                [(cons (? void?) (? void?)) (error "alts and block should not be void at the same time")]
                [(cons block (? void?)) (list block)]
                [(cons (? void?) alts) (list alts)]
                [(cons block alts) (list block alts)])))))

  (label/p
    "group"
    (local-indentation/p
      '*
      (or/p
       (do
         [top <- (absolute-indentation/p group-top-level)]
         (or/p
           (do
             [rest <- rest/p]
             (pure `(group ,@top . ,rest)))
           (do
             [alts <- inlinable-alts]
             (pure `(group ,@top ,alts)))
           (pure `(group . ,top))))
       (do
         [rest <- rest/p]
         (pure `(group . ,rest)))))))

(define block/p
  (local-indentation/p '>
                       (do
                         [groups <- (delay/p (group+/p))]
                         (pure `(block . ,groups)))))

(define block-in-alt/p
  (local-indentation/p '>
                       (do
                         [groups <- (delay/p (group+/p #:in-alt? #t))]
                         (pure `(block . ,groups)))))


(define alts/p
  (let ([alt-branch (do
                      (lexeme/p 'bar-operator)
                      (or/p guillemet/p block-in-alt/p (do newlines/p block/p)))])
    (do
      [alts <- (sequence+/p alt-branch void/p)]
      (pure `(alts . ,alts)))))

  
(define (group-sequence #:in-alt? [in-alt? #f])
  (define separator/p (many+/p semicolon/p))
  (define parser/p (group/p #:in-alt? in-alt?))
  (sequence-optional-separator+/p parser/p separator/p))

(define (group*/p #:in-alt? [in-alt? #f])
  (or/p
    (group-sequence #:in-alt? in-alt?)
    (pure '())))


(define (group+/p #:in-alt? [is-in-alt #f])
  (define (group-comment #:in-alt? [is-in-alt #f])
    (define group (group/p #:in-alt? is-in-alt))
    (do
      (absolute-indentation/p (lexeme/p 'group-comment))
      (or/p group
            (do newlines/p (absolute-indentation/p group)))))

  (define comment (group-comment #:in-alt? is-in-alt))
  (define separator (noncommittal/p (many+/p semicolon/p)))
  (define remaining-groups/p (do
                               [groups-with-voids <- (sep-end-by/p (or/p (local-indentation/p '> comment) (group/p #:in-alt? is-in-alt)) separator)]
                               (pure (filter (lambda (x) (not (void? x))) groups-with-voids))))
  (define trim/p (many/p (or/p semicolon/p comment)))

  (or/p
    (do
      (noncommittal/p (absolute-indentation/p trim/p))
      newline/p
      newlines/p
      (group+/p #:in-alt? #f))
    (absolute-indentation/p
      (do
       trim/p
       [first-group <- (group/p #:in-alt? is-in-alt)]
       [remaining-groups <- (or/p
                             (do
                               separator
                               remaining-groups/p)
                             (pure '()))]
       (or/p
         (do
          newlines/p
          [rest-lines <- (group-sequence #:in-alt? #f)]
          (pure `(,first-group ,@remaining-groups ., rest-lines)))
         (pure `(,first-group . ,remaining-groups)))))))

;;;; Document

(define document/p
  (do
    (?/p non-newline-whitespace/p)
    newlines/p
    [groups <- (group*/p)]
    newlines/p
    eof/p
    (pure (cons 'multi groups))))

;;;; Parsing strings

(define (lex in)
  (define (comment-token? token)
    (and (token? token)
         (eq? (token-name token) 'comment)))

  ;; port-count-lines! assumes that a tab is 8 columns wide
  (port-count-lines! in)

  (filter-map
   (lambda (token) (and (not (comment-token? token)) (syntax-box token (syntax-srcloc (token-value token)))))
   (lex-all in (lambda (token explanation) (raise (error (cons token explanation)))))))

(define (shrubbery-parser str)
  (parse document/p (lex str)))


;;;; Testing

(module+ main
  (require racket/file)

  (define (lex filename)
    (lex (file->string filename)))

  (define (parse filename)
    (shrubbery-parser (file->string filename)))

  (define args (current-command-line-arguments))

  (if (< (vector-length args) 2)
      (begin
        (eprintf "Usage: program <lex|parse> <filename>\n")
        (exit 1))
      (let ([subcommand (vector-ref args 0)]
            [filename   (vector-ref args 1)])
        (cond
          [(equal? subcommand "lex")   (lex filename)]
          [(equal? subcommand "parse") (parse filename)]
          [else
           (eprintf "Unknown subcommand: ~a\n" subcommand)
           (exit 1)]))))


(module+ test
  (require data/either)
  (require rackunit)

  (define (p str)
    (define in (open-input-string str))
    (shrubbery-parser in))

  (check-equal? (p "let dir = match dir.to_string() | \"R\": #'right | \"L\": #'left | \"U\": #'up | \"D\": #'down") (success '(multi (group a (alts (block (group b)) (block (group c)))))) "inline alt")
  (check-equal? (p "a | b | c") (success '(multi (group a (alts (block (group b)) (block (group c)))))) "inline alt")
  (check-equal? (p "a\n+") (success '(multi (group a) (group (op +)))) "group starting with operator after another group")
  (check-equal? (p "a b ( a, b, c,\n      d, e, f, )") (success '(multi (parens (group a) (group b) (group c)))) "parens")
  (check-equal? (p "a") (success '(multi (group a))) "single identifier")
  (check-equal? (p "a b:\n c") (success '(multi (group a b (block (group c))))) "group with block")
  (check-equal? (p "+") (success '(multi (group (op +)))) "operator")
  (check-equal? (p "a b c d") (success '(multi (group a b c d))) "A simple group")
  (check-equal? (p "a b c d\ne f g h") (success '(multi (group a b c d) (group e f g h))) "Multiple simple groups")
  (check-equal? (p "a b c d\n+ e f g h") (success '(multi (group a b c d) (group (op +) e f g h))) "Group starting with operator")
  (check-equal? (p "a b c d\n + e f g h") (success '(multi (group a b c d (op +) e f g h))) "Group with operator continuation")
  (check-equal? (p "  a b c d\\\ne f g h") (success '(multi (group a b c d e f g h))) "Group with line continuation")
  (check-equal? (p "a b c d:   e f g h\n           i j k l") (success '(multi (group a b c d (block (group e f g h) (group i j k l))))) "Groups should start on same indentation")
  (check-equal? (p "a\n|    b\n     c") (success '(multi (group a (alts (block (group b) (group c)))))) "Alt with two groups")
  (check-equal? (p "a\n|    b: d\n|c") (success '(multi (group a (alts (block (group b (block (group d)))) (block (group c)))))) "Alt then group")
  (check-equal? (p "a\n| d\n  | c") (success '(multi (group a (alts (block (group d (alts (block (group c))))))))) "Alt in alt")
  (check-equal? (p "a\n| d | c") (success '(multi (group a (alts (block (group d)) (block (group c)))))) "Inline alt")
  (check-equal? (p "a\n| b | c\n| d") (success '(multi (group a (alts (block (group b)) (block (group c)) (block (group d)))))) "Alt in multiple same line alt"))
  ; (check-equal? (p "a\n| b\nc\n| d") (success '(multi (group a (alts (block (group b)))) (group c (alts (block (group d)))))) "Multiple alts")
  ; (check-equal? (p "   a\nb") (failure '(multi (group a) (group b))) "Two groups")
  ; (check-equal? (p "a\n   b") (failure '(multi (group a) (group b))) "Two groups")
  ; (check-equal? (p "a b c d\n\n   e f g h") (failure '(multi (group a b c d) (group e f g h))) "Groups should start on same indentation")
  ; (check-equal? (p "a b: d\nc") (success '(multi (group a b (block (group d))) (group c))) "block then group")
  
