#lang racket
(require quickcheck)
(require shrubbery)
(require shrubbery/parse)
(require shrubbery/property)
(require shrubbery/write)
(require shrubbery/print)

(provide pretty_print_random_generated_vals)

(define (pretty_print_sexp s)
  ;; Temporary port for verification
  (define test-port (open-output-string))
  
  ;; Write to test-port first, to check parsing
  (write-shrubbery s test-port
                   #:pretty? #t
                   #:armor? #f
                   #:prefer-multiline? #t)
  
  ;; Attempt to parse
  (define out-str (get-output-string test-port))
  (define in-port (open-input-string out-str))
  
  (with-handlers ([exn:fail? 
                   (lambda (e)
                     (displayln (format "Parse failed: ~a" (exn-message e)))
                     #f)])
    (when (parse-all in-port)
      ;; Only write to current-output-port if parse succeeds
      (write-shrubbery s (current-output-port)
                       #:pretty? #t
                       #:armor? #f
                       #:prefer-multiline? #t)
      (newline)
      (newline))))

(define (pretty_print_random_generated_vals gen-generator [n 2500])
  (with-test-count n (quickcheck (property ([ele (gen-generator)]) (pretty_print_sexp ele) #t))))
