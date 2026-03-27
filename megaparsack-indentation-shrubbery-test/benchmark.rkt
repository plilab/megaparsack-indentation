#lang errortrace racket/base

(require benchmark)
(require megaparsack)
(require megaparsack-indentation-shrubbery)
(require shrubbery/parse)
(require racket/function)
(require racket/match)
(require racket/file)
(require data/either)
(require "./corpus.rkt")
(require "./utils/file_utils.rkt")
(require "./utils/parse_utils.rkt")

(define (parseable-with-both? filename)
  (define-values (a b) (parse-with-both filename))
  (and (success? a) (success? b)))
  ;; (match/values (parse-with-both filename)
  ;;   [((? failure?) (? failure?))
  ;;    (begin
  ;;      (eprintf "Skipping ~a, both parsers failed\n" filename)
  ;;      #f)]
  ;;   [((? failure?) _)
  ;;    (begin
  ;;      (eprintf "Skipping ~a, our parser failed\n" filename)
  ;;      #f)]
  ;;   [(_ (? failure?))
  ;;    (begin
  ;;      (eprintf "Skipping ~a, reference parser failed\n" filename)
  ;;      #f)]
  ;;   [(_x _x) #t]
  ;;   [(_ _) (begin (eprintf "Skipping ~a, parsed results do not match\n" filename) #f)]))

(define (bench-file paths)
  (run-benchmarks
    paths
    (list (list 'our 'reference))
    (lambda (file which)
      (define parser
        (case which
         ['our (lambda (in) (shrubbery-parser in))]
         ['reference (lambda (in) (parse-all in))]
         [else (error "unknown parser")]))
      (define in (open-input-string (file->string file)))
      (port-count-lines! in)
      (skip-lang-prefix! in)
      (define code-start (file-position in))
      (time (for ([_ 100])
             (parser in)
             (file-position in code-start))))
    #:make-name path->string
    #:num-trials 1
    #:results-file "wow"
    #:skip (lambda (file _) (not (parseable-with-both? file)))))

(module+ main
  (bench-file (read-corpus corpus-path)))
    
  
