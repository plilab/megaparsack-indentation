'(multi
  (group
   import
   (block
    (group
     lib
     (parens (group "advent-of-code/main.rkt"))
     as
     aoc
     (block
      (group
       rename
       (block
        (group find-session as find_session)
        (group fetch-aoc-input as fetch_input)))))))
  (group
   export
   (block
    (group rename (block (group aoc (op |.|) find_session as find_session)))
    (group fetch_input)))
  (group
   fun
   fetch_input
   (parens (group session) (group year) (group day))
   (op :~)
   String
   (block
    (group
     let
     s
     (op ::)
     ReadableString
     (op =)
     aoc
     (op |.|)
     fetch_input
     (parens
      (group session)
      (group year)
      (group day)
      (group #:cache (block (group #t)))))
    (group s (op |.|) to_string (parens)))))
