#lang scribble/manual
@require[@for-label[megaparsack-indentation
                    megaparsack
                    racket/base
                    racket/contract
                    data/either]]

@title{megaparsack-indentation}
@author{Mashfi Ishtiaque Ahmad}

@defmodule[megaparsack-indentation]

Megaparsack-indentation is an extension of @racketmodname{megaparsack} for
constraint-based indentation-sensitive parsing based on the research of Michael
D. Adams and Ömer S. Ağacan.

This documentation explains the mechanical usage of the library. For a
conceptual understanding of the theory this library is based on, see
@hyperlink["https://doi.org/10.1145/2775050.2633369"]{this paper}.

@section[#:tag "design"]{Overview}

This library is built around a parser local @tech{indentation state}. The resolution
is handled at the token level. Every token parser wrapped in @racket[indent/p]
verfies whether the parser's result has a valid indentation. If the indentation
is valid and there is a successful parse, then the state is updated for the
next token and the parser returns the parsed value in a @racket[success], else
the parser returns a @racket[failure] with the parse error or indentation
error.

The @deftech{indentation state} contains a @tech{relation} and a contiguous
range of possible @tech{indentation}s for the next token. A @deftech{relation}
can be any of @racket['>], @racket['>=], @racket['=], @racket['*] or
@racket[(const . n)] where @racket[n] is any non-negative number. Each relation
has different requirements for the token's indentation to be valid:

@itemlist[

@item{@racket['>], @racket['>=] and @racket['=] require the indentation to be
greater than, greater than or equal, and equal to any value in the range
respectively}

@item{@racket['*] can have any indentation}

@item{@racket[(const . n)] requires the indentation to be equal to n}

]

The @deftech{indentation} of a token is its 1-indexed column in the input string. The
indentation is acquired from the individual @racket[boxes] provided to
@racketmodname{megaparsack}'s @racket[parse]. The range of possible
indentations is 0 to infinity. 0 is a valid indentation despite indentation
being 1-indexed to simplify scenarios involving @racket['>]. Some parsers might
have structures that are parsed with the @racket['>] relation in
subexpressions, but can also appear in the top level. It is more convenient to
have a lower bound below the feasible indentations to accommodate for both
scenarios.


Initially, the @tech{relation} is set to @racket['>], and the range of possible
indentations is from 0 to infinity. 

The @tech{indentation state} and indentation parsing behaviour can be modified
outside of @racket[indent/p] with the following functions:

@itemlist[

@item{@racket[local-indentation/p] enforces the indentation on an entire
subexpression: it requires each of the inner @racket[indent/p] to transatively
be valid for the supplied relation for the current range}

@item{@racket[local-token-mode/p] can override the relation locally and
@racket[absolute-indentation/p] can align a subexpression to its parent
expression}

]

@section{Example}


TODO: Write a small example using the paren matcher


For a bigger example of how to use this library, you can refer to @racketmodname{megaparsack-indentation-shrubbery}.


@section{API Reference}

@defproc[(relation? [v any/c]) flat-contract?]{
Returns @racket[#t] if @racket[v] is a valid relation, otherwise returns
@racket[#f].

See @tech{relation} for the specific relations and their behavior. See
@racket[local-indentation/p] and @racket[local-token-mode/p] for their usage.

}

@defproc[(indent/p
           [parser (parser/c a b)])
         (parser/c a b)]{

Produces a parser that succeeds when the token parser @racket[parser] parses
successfully at a valid indentation according to the current @tech{indentation
state}. After parsing, the range of possible indentations is constricted to the
values that only satisfy the relation with the token's indentation.

}

@defproc[(local-indentation/p [relation relation?] [parser (parser/c a b)]) (parser/c a b)]{

Produces a parser that succeeds when all the @racket[indent/p] in the parser
@racket[parser] transitively satisfy the @racket[relation] with the current
valid range of indentations. This function essentially creates a new
expression, and any subexpression created by @racket[parser] has to satisfy
@racket[relation] to be a valid parser under it.

}

@defproc[(local-token-mode/p [relation-transformer (-> relation? relation?)] [parser (parser/c a b)]) (parser/c a b)]{

Produces a parser that overrides the indentation state's relation for the given
@racket[parser]. The relation is set to the result from applying
@racket[relation-transformer] during @racket[parser]'s run, and the relation is
reset back to the previous relation afterwards.

}

@defproc[(absolute-indentation/p [parser parser?] [#:local? local? boolean? #f]) (parser?)]{

Produces a parser that runs @racket[parser] but forces the first
@racket[indent/p] to parse with the @racket['=] relation. This effectively
means that the parsed expression is aligned at the same indentation as its
parent expression.

Absolute indentation is by default non-local: multiple nested
@racket[absolute-indentation/p] can be satisfied with a single
@racket[indent/p]. This effectively aligns the parsed expression to every outer
expression which called @racket[absolute-indentation/p].

This non-local behaviour is what is expected most of the time, but it can be
disabled by setting @racket[local?] to @racket[#t]. This makes the first
encountered @racket[indent/p] only affect up until the current
@racket[absolute-indentation/p]. Outer @racket[absolute-indentation/p] will
affect the subsequent @racket[indent/p].

}
