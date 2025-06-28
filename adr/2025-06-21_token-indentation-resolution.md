# Token Indentation Resolution

# Status
Accepted

# Context

We need the integer number of the every parsed expression to determine whether the
it is in the valid range.

# Alternatives Considered

One idea was to annotate every character read from the input with their integer
number. This would work but it would need us to change every parser to take in
character-number tuples instead of just characters. All the previously defined
parsers would be unusable, and any optimizations based on string views would be
a bit more difficult to do.

Yet another idea is to embed the indentation inside megaparsack itself, and use
the column numbers found while parsing.

# Decision

Megaparsack exposes the indentation information indirectly through `syntax/p`
and `syntax-box/p`. These parser combinators add syntax location information to
the parsed expression. We have decided to go with this as it would require the
least change to megaparsack while remaining operable on every stream.

# Consequences

All combinators will need to be wrapped with `syntax/p` or `syntax-box/p`
followed by an indentation check.

As the indentation can only be check after parsing, there will be some wasted
time for every rejected parse.
