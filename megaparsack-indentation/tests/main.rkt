#lang racket
(require racket/contract)
(require rackunit)
(require racket/runtime-path)
(require "./utils/file_utils.rkt")
(require "./utils/parse_utils.rkt")
(require megaparsack-indentation-shrubbery)
(require megaparsack)
(require megaparsack/text)
(require megaparsack-indentation)

;;; Main loop
(define-runtime-path corpus_path "corpus")
(define all_paths (read-corpus corpus_path))
(define code_xs (map read-file-into-string all_paths))

;;; (display (car code_xs))
(define (call_self_defined_parser code)
  (parse-result! (shrubbery-parser code)))

(test-begin
 (let ([code_xs (map read-file-into-string all_paths)])
   (for-each (lambda (code)
               (display code)
               (let* ((reference-parse
                       (begin
                         (display "Parsing with reference parser")
                         (syntax->datum (parse-string-self-defined code))
                         (display "Parsing with reference parser done")))
                      (our-parse
                       (begin
                         (display "Parsing with our parser")
                         (syntax->datum (call_self_defined_parser code))
                         (display "Parsing with our parser done"))))
                 (check-sexps-equal? reference-parse our-parse)))
             code_xs)))

