- [ ] How do we get the indentation level of a stream character? Possible ideas
    - 3) Modify stream to have tuples of char and int
        - Similar to `indentation`
        - Downside is that we either have to resolve indentationState in the
          stream or we have to make all combinators take in a token-indentation
          tuple. Is there any other way around this?
    - 2) Make all combinators return an (indentation-state, value) tuple.
        - 1-1 with the paper, I don't know how performant this will be though
        - Will have to keep track during parsing whitespace as well
    - 1) Syntax-box might help
        - Racket builtin for languages that is a datum (any value) wrapped in a
          source location
        - We can check the source start after the parsing is done
        - Downside: we have to parse the entire branch before we can fail. Very
          bad
    - Look at megaparsack's internals
        - There's mention of megaparsack keeping track of source location, so
          maybe we can create custom combinators which introspect source
          location.
        - I don't know if this is possible yet.
- [ ] Where do I actually call updateIndentation?
    - After every parse? That sounds cumbersome. Not having the monad
      transformer is annoying.
    - I get the feeling that there's no way round custom combinators, but it
      would be nice if we can have a combinator that turned other combinators
      indentation sensitive if that were the case.
    - Maybe a macro that walks down the `do` expression? More of an enhancement.
      Would be in the backlog in that case.
- [x] Do we throw errors or do we use `Either`?
    - I suppose I don't have enough of a idea of the general structure the code
      is going to have.
    - I just realized errors are a bad idea as we'd lose all information.
      Megaparsack already uses `Either`, so I think following this is a good
      idea.
    - I think I got confused and thought that `guard/p` threw an error
