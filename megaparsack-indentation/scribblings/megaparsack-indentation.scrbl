#lang scribble/manual
@require[@for-label[megaparsack-indentation
                    megaparsack
                    racket/base]]

@title{megaparsack-indentation}
@author{Mashfi Ishtiaque Ahmad}

@defmodule[megaparsack-indentation]

Megaparsack-indentation is an extension of @racketmodname{megaparsack} for
constraint-based indentation-sensitive parsing by
@hyperlink["https://doi.org/10.1145/2775050.2633369"]{Michael D. Adams and Ömer
S. Ağacan}.

@section{Quick Start}

@section{Design}

@section{API Reference}

@defproc[(gen-indent/p
           [accessor (-> _a integer?)]
           [fail (-> indentation-state? any/c)])
         (-> (parser/c a b) (parser/c a b))]

@section{Limitations}
