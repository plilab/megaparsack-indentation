# Plan

- [ ] Set Up Environment
  - Ensure Racket and necessary packages (shrubbery-lib, rhombus) are installed and working.

- [ ] Collect Example Rhombus Programs
  - Write or gather several sample Rhombus programs that demonstrate indentation-sensitive features.
Parse Examples Using Shrubbery
  - Use the shrubbery/parse API to parse each example program.

- [ ] Capture the resulting syntax tree in S-exp.
  - Write a function to transform the parsed syntax tree into an S-exp AST for easier comparison.

- [ ] Parse Examples Using Your Megaparsack
  - Use your parser to parse the same set of example programs.
  - Generate S-exp ASTs from your parser's output.

- [ ] Compare Results
  - Write tests to compare the ASTs produced by Shrubbery and your parser.
  - Highlight differences and similarities.
  - Automate Testing

## Functions to implement

1. Corpus loaders `read-corpus`
2. Wrapper parse function `parse-with-shrubbery`
3. Comparator `compare-ast`
4. Exception handler

## Quick check for Rhombus

1. subsets of genrator
  Atoms
  Arithmic expression
  Conditional
  Bindings Program

2. use `write-shrubbery` to reconstruct the Shrubbery notation string from s-expression back to string
