#lang info

(define collection "megaparsack-indentation-shrubbery-test")
(define deps '())
(define build-deps
  '(
    "base"
    "megaparsack"
    "megaparsack-indentation"
    "megaparsack-indentation-shrubbery"
    "scribble-lib"
    "racket-doc"
    "rackunit-lib"
    "parser-tools"
    "sexp-diff"))
(define scribblings '(("scribblings/megaparsack-indentation.scrbl" ())))
(define pkg-desc "Description Here")
(define version "0.1")
(define pkg-authors '(Mashfi Ishtiaque Ahmad))
(define license '(Apache-2.0 OR MIT))
