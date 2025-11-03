#lang racket
;;; (require rackcheck)
(require racket/runtime-path)
(require quickcheck)
;;; (require "./utils/utils.rkt")
(require "./utils/gen_helper.rkt")
(require shrubbery)
(require shrubbery/parse)
(require shrubbery/property)
(require shrubbery/write)
(require shrubbery/print)

(define-runtime-path sample_rangen_path "../sample_rangen")

;;; Output the unverified pretty print - only write back when it can be parsed by default parser
(define (raw_output_sexp s)
  (define time_stamp (current-seconds))
  (define path
    (string-append (path->string sample_rangen_path)
                   "/"
                   (number->string time_stamp)
                   "_random_unverified.rhm"))
  (define file-port
    (open-output-file path
                      #:mode 'text
                      #:exists 'replace
                      #:permissions #o666
                      #:replace-permissions? #t))
  (write-shrubbery s file-port #:pretty? #t #:armor? #f #:prefer-multiline? #t))

(define (raw_output_random_generated_vals gen-generator [n 10000])
  (with-test-count n (quickcheck (property ([ele (gen-generator)]) (raw_output_sexp ele) #t))))

;;; Output the verified pretty print
(define (pretty_output_sexp s)
  (define test-port (open-output-string))
  (write-shrubbery s test-port #:pretty? #t #:armor? #f #:prefer-multiline? #t)

  (define out-str (get-output-string test-port))
  (define in-port (open-input-string out-str))

  (define time_stamp (current-seconds))
  (define path
    (string-append (path->string sample_rangen_path) "/" (number->string time_stamp) "_random.rhm"))
  (define file-port
    (open-output-file path
                      #:mode 'text
                      #:exists 'replace
                      #:permissions #o666
                      #:replace-permissions? #t))
  
  ;;; Only string that can be parsed by the parse-all functions will be recognized
  (with-handlers ([exn:fail? (lambda (e)
                               (displayln (format "Parse failed: ~a" (exn-message e)))
                               #f)])
    (when (parse-all in-port)
      (write-shrubbery s file-port #:pretty? #t #:armor? #f #:prefer-multiline? #t)
      (newline)
      (newline))))

(define (pretty_output_random_generated_vals gen-generator [n 10000])
  (with-test-count n (quickcheck (property ([ele (gen-generator)]) (pretty_output_sexp ele) #t))))

;;; Main module that actually print the document
(module+ main
  (pretty_output_random_generated_vals gen-document))
