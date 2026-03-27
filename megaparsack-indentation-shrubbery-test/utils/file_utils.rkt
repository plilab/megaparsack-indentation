#lang racket

(provide skip-lang-prefix!
         read-corpus)

(define/contract (read-corpus dir)
  (-> path? (listof path?))
  (for/list ([f (in-directory dir)]
             #:when (regexp-match? #rx"\\.rhm$" f))
    f))

(define (skip-lang-prefix! port)
  ;; This pattern skips:
  ;; 1. An optional shebang line
  ;; 2. Any combination of whitespace, line comments (;), and block comments (#|...|#)
  ;; 3. The #lang line itself
  (define pattern 
    #px"^(?:#![^\r\n]*\r?\n)?(?:\\s+|;[^\r\n]*\r?\n|(?s:#\\|.*?\\|#))*#lang[^\r\n]*\r?\n?")
  
  (regexp-match pattern port)
  (void))
