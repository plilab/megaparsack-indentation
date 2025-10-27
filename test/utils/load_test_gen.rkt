#lang racket
(require racket/runtime-path)
(require "./file_utils.rkt")

(define-runtime-path corpus_path "../minicorpus")
(define-runtime-path out_dir "../large_corpus")
(define M 10000)

(define (repeat_str code cnt [res ""])
  (cond
    [(> cnt 0) (repeat_str code (sub1 cnt) (string-append res code "\n"))]
    [else res]))

(define cnt 0)

(define (gen_load_test_cases)
  (define all_paths (read-corpus corpus_path))
  (for-each (lambda (app_path)
              (define code (read-file-into-string app_path))
              (define new_code (repeat_str code M))
              (define out-path (string-append (path->string out_dir) "/large" (number->string cnt)  ".rhm"))
              (displayln out-path)
              (set! cnt (+ 1 cnt))
              (call-with-output-file out-path (lambda (out) (display new_code out)) #:exists 'replace))
            all_paths))

(gen_load_test_cases)
