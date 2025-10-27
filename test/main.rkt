#lang racket
(require racket/contract)
(require rackunit)
(require rackunit/text-ui)
(require racket/runtime-path)
(require "./utils/file_utils.rkt")
(require "./utils/parse_utils.rkt")
(require megaparsack-indentation-shrubbery)
(require megaparsack)
(require megaparsack/text)
(require megaparsack-indentation)

;;; Define paths for success files
(define-runtime-path corpus_path "minicorpus")
(define all_paths (read-corpus corpus_path))

;;; Define parts for failed files
(define-runtime-path failed_corpus_path "fail_corpus")
(define failed_paths (read-corpus failed_corpus_path))

;;; Define parts for large files
(define-runtime-path large_corpus_path "large_corpus")
(define large_paths (read-corpus large_corpus_path))

;;; Define parts on external files
(define-runtime-path external_corpus_path "corpus")
(define external_paths (read-corpus external_corpus_path))

;;; Wrap the shrubbery parser from the
(define (call_self_defined_parser code)
  (with-handlers ([exn:fail? (lambda (exn)
                               (printf "Parse error: ~a\n" (exn-message exn))
                               (syntax->datum (syntax '())))])
    (parse-result! (shrubbery-parser code))))

;;; Main test framework
(module+ test
  (define my-test
    (test-suite "Test harness for parser"
      #:before (lambda () (displayln "Start testing"))
      #:after (lambda () (displayln "Finish testing"))
      ;;; Test cases for small succesful test cases
      (test-begin
        (let ([code_xs (map read-file-into-string all_paths)])
          (for-each (lambda (code)
                      (display code)
                      (newline)
                      (check-sexps-equal? (call_self_defined_parser code)
                                          (syntax->datum (parse-string-self-defined code))))
                    code_xs)))

      ;;; Test cases for failed test cases
      (test-begin
        (let ([code_xs (map read-file-into-string failed_paths)])
          (for-each (lambda (code)
                      (display code)
                      (newline)
                      (check-sexps-equal? (call_self_defined_parser code)
                                          (syntax->datum (parse-string-self-defined code))))
                    code_xs)))

      ;;; Test cases for large test cases
      (test-case "Large test cases"
        (let ([code_xs (map read-file-into-string large_paths)])
          (for-each (lambda (code)
                      (newline)
                      (check-sexps-equal? (call_self_defined_parser code)
                                          (syntax->datum (parse-string-self-defined code))
                                          #f))
                    code_xs)))
      
      ;;; Test cases for external corpus
      (test-case "External test case"
        (let ([code_xs (map read-file-into-string external_paths)])
          (for-each (lambda (code)
                      (newline)
                      (check-sexps-equal? (call_self_defined_parser code)
                                          (syntax->datum (parse-string-self-defined code))
                                          #f))
                    code_xs)))))
  (run-tests my-test))
