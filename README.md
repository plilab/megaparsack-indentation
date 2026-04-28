# Megaparsack-Indentation

This library implements a set of indentation combinators on top of
[Megaparsack](https://github.com/lexi-lambda/megaparsack). The repo contains
the library implementation at `megaparsack-indentation` and an example parser
for the [Shrubbery Language](https://docs.racket-lang.org/shrubbery/index.html)
at `megaparsack-indentation-shrubbery`.

This library is based on the indentation-sensitive PEG extension defined by
[Michael D. Adams and Ömer S. Ağacan](https://dl.acm.org/doi/10.1145/2633357.2633369).

## Licensing

This repo is licensed with the dual Apache 2.0 or MIT license, other than the
following files.

- `megaparsack-indentation-shrubbery/lex.rkt`
- `megaparsack-indentation-shrubbery/private/`

These files have been vendored from
https://github.com/racket/rhombus/tree/96d1c20d3a4362e472df8766461e6ecd56336159/shrubbery-lib/shrubbery
which we have adopted by the repo's MIT license. See the contents in the files
for the license.
