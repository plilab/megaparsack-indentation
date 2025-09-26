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
  (parse-result! (shrubbery-parser code)))

;;; Small tests to make sure api works
(define one_piece_example (
  read-file-into-string 
  (string->path "E:\\School-Work-5-Y3S1\\CP3106\\megaparsack-indentation\\test\\corpus\\demo_mini.rhm")
))
(display one_piece_example)
(newline)
(display (call_self_defined_parser one_piece_example))


(test-begin
  (let ([code_xs (map read-file-into-string all_paths)])
    (for-each (lambda (code)
                (check-sexps-equal? (call_self_defined_parser code)
                                    (syntax->datum (parse-string-self-defined code))))
              code_xs)))

