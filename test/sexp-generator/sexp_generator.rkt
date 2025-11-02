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

;;; (define (rangen_shrubbery size)
;;;   (define time_stamp (current-seconds))
;;;   (define path
;;;     (string-append (path->string sample_rangen_path) "/" (number->string time_stamp) "_random.rhm"))
;;;   (define file-port
;;;     (open-output-file path
;;;                       #:mode 'text
;;;                       #:exists 'replace
;;;                       #:permissions #o666
;;;                       #:replace-permissions? #t))
;;;   (when (positive? size)
;;;     (begin
;;;       (pretty_print_random_generated_vals gen-document 1500 file-port)
;;;       (rangen_shrubbery (sub1 size)))))

(define (pretty_output_sexp s)
  ;;; Attempt to write shrubbery to string first
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

  (with-handlers ([exn:fail? (lambda (e)
                               (displayln (format "Parse failed: ~a" (exn-message e)))
                               #f)])
    (when (parse-all in-port)
      (write-shrubbery s file-port #:pretty? #t #:armor? #f #:prefer-multiline? #t)
      (newline)
      (newline))))

(define (pretty_output_random_generated_vals gen-generator [n 10000])
  (with-test-count n (quickcheck (property ([ele (gen-generator)]) (pretty_output_sexp ele) #t))))

(module+ main
  (pretty_output_random_generated_vals gen-document))
