#lang racket
(require racket/contract)
(require rackunit)
(require racket/runtime-path)
(require "./file_utils.rkt")
(require "./parse_utils.rkt")
(require megaparsack-indentation-shrubbery)
(require megaparsack)
(require megaparsack/text)
(require megaparsack-indentation)

;;; Small test case
;;; (define s1 (read-file-into-string local_file))

;;; (test-begin
;;;   (let ([sexp1 (syntax->datum (parse-string s1))])
;;;     (check-sexps-equal? sexp1 sexp1)
;;;     (check-sexps-equal? sexp1 (cdr sexp1))
;;;     (check-sexps-equal? sexp1 (car (cdr sexp1)))))

;;; Main loop
(define-runtime-path corpus_path "corpus")
(define all_paths (read-corpus corpus_path))
(define code_xs (map read-file-into-string all_paths))

;;; (display (car code_xs))
(define (call_self_defined_parser code)
  (parse-result! (parse-string shrubbery-parser code)))

(test-begin
  (let ([code_xs (map read-file-into-string all_paths)])
    (for-each (lambda (code)
                (check-sexps-equal? (call_self_defined_parser code)
                                    (syntax->datum (parse-string-self-defined code))))
              code_xs)))
