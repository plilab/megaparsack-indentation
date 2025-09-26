# Devlog

Changes to the system in reverse chronological order


## Fri 26 Sep 2025 02:39:34 AM +08
- Made a lexer
    - There is one part that will require a major overhaul in the parser
      implementation: `1+2` is equal to `1` plus `2`, but `1 +2` is equal to `1`
      and then `+2`
- Fixed a bug with the parser. As far as I understand, `many/p`'s `#:sep`
  portion also counts towards errors if they consume something, even if the main
  parser is wrapped in a `try/p`, so they need to be wrapped in the `try/p`
  itself.
