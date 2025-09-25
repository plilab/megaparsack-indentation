'(multi
  (group
   import
   (block
    (group lib (parens (group "racket/base.rkt")))
    (group "util/advent_of_code.rhm" as aoc)
    (group "util/misc.rhm" as util)))
  (group
   def
   lex_pat
   (block
    (group
     base
     (op |.|)
     pregexp
     (parens (group "^\\s+|Game|\\d+|[:,]|;|red|green|blue")))))
  (group
   fun
   make_string_pred
   (parens (group f))
   (block
    (group
     fun
     (parens (group s (op ::) String))
     (block
      (group
       for
       values
       (parens (group r (op =) #t))
       (block
        (group each i (block (group 0 (op ..) s (op |.|) length (parens))))
        (group r (op &&) f (parens (group s (brackets (group i)))))))))))
  (group
   def
   is_space
   (op =)
   make_string_pred
   (parens (group Char (op |.|) is_whitespace)))
  (group
   def
   is_number
   (op =)
   make_string_pred
   (parens (group Char (op |.|) is_numeric)))
  (group
   fun
   lex
   (parens (group input (op ::) String) (group i (op ::) NonnegInt (op =) 0))
   (op ::)
   List
   (block
    (group
     def
     values
     (parens (group tok) (group tlen))
     (block
      (group
       match
       base
       (op |.|)
       regexp-match
       (parens (group lex_pat) (group input) (group i))
       (alts
        (block
         (group
          (brackets (group tok (op ::) ReadableString (op |.|) to_string))
          (block
           (group
            values
            (parens (group tok) (group tok (op |.|) length (parens)))))))
        (block
         (group v (block (group values (parens (group v) (group 0))))))))))
    (group
     fun
     next
     (parens (group v))
     (block
      (group
       List
       (op |.|)
       cons
       (parens
        (group v)
        (group lex (parens (group input) (group i (op +) tlen)))))))
    (group
     cond
     (alts
      (block (group (op !) tok (block (group (brackets)))))
      (block
       (group
        is_space
        (parens (group tok))
        (op \|\|)
        tok
        (op ==)
        "Game"
        (op \|\|)
        tok
        (op ==)
        ":"
        (op \|\|)
        tok
        (op ==)
        ","
        (block (group lex (parens (group input) (group i (op +) tlen))))))
      (block
       (group
        is_number
        (parens (group tok))
        (block
         (group
          next
          (parens (group String (op |.|) to_int (parens (group tok))))))))
      (block (group #:else (block (group next (parens (group tok))))))))))
  (group
   class
   Game
   (parens
    (group number (op ::) NonnegInt)
    (group rounds (op ::) List (op |.|) of (parens (group Map))))
   (block
    (group
     method
     max_cubes
     (parens)
     (block
      (group
       def
       values
       (parens (group r) (group g) (group b))
       (block
        (group
         for
         values
         (parens (group r (op =) 0) (group g (op =) 0) (group b (op =) 0))
         (block
          (group each a_round (block (group rounds)))
          (group
           values
           (parens
            (group
             math
             (op |.|)
             max
             (parens
              (group r)
              (group a_round (op |.|) get (parens (group "red") (group 0)))))
            (group
             math
             (op |.|)
             max
             (parens
              (group g)
              (group a_round (op |.|) get (parens (group "green") (group 0)))))
            (group
             math
             (op |.|)
             max
             (parens
              (group b)
              (group
               a_round
               (op |.|)
               get
               (parens (group "blue") (group 0)))))))))))
      (group
       (braces
        (group "red" (block (group r)))
        (group "green" (block (group g)))
        (group "blue" (block (group b)))))))
    (group
     method
     power
     (parens)
     (block
      (group
       def
       (braces
        (group "red" (block (group r)))
        (group "green" (block (group g)))
        (group "blue" (block (group b))))
       (op =)
       max_cubes
       (parens))
      (group r (op *) g (op *) b)))
    (group
     method
     is_possible
     (parens
      (group r0 (op ::) NonnegInt)
      (group g0 (op ::) NonnegInt)
      (group b0 (op ::) NonnegInt))
     (op ::)
     Boolean
     (block
      (group
       def
       (braces
        (group "red" (block (group r1)))
        (group "green" (block (group g1)))
        (group "blue" (block (group b1))))
       (op =)
       max_cubes
       (parens))
      (group r0 (op >=) r1 (op &&) g0 (op >=) g1 (op &&) b0 (op >=) b1)))))
  (group
   fun
   parse_line
   (parens (group input (op ::) String))
   (op ::)
   Game
   (block
    (group
     fun
     parse_rounds
     (parens (group tokens) (group counts (op :~) Map))
     (block
      (group
       match
       tokens
       (alts
        (block (group (brackets) (block (group (brackets (group counts))))))
        (block
         (group
          (brackets (group ";") (group (op &) rest))
          (block
           (group
            List
            (op |.|)
            cons
            (parens
             (group counts)
             (group parse_rounds (parens (group rest) (group (braces)))))))))
        (block
         (group
          (brackets (group count) (group color) (group (op &) rest))
          (block
           (group
            parse_rounds
            (parens
             (group rest)
             (group
              counts
              (op ++)
              (braces (group color (block (group count))))))))))))))
    (group
     match
     lex
     (parens (group input))
     (alts
      (block
       (group
        (brackets (group game) (group (op &) rest))
        (block
         (group
          Game
          (parens
           (group game)
           (group parse_rounds (parens (group rest) (group (braces)))))))))))))
  (group
   util
   (op |.|)
   example_input
   (parens
    (group test_input)
    (group
     (brackets
      (group "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green")
      (group "\n")
      (group
       "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue")
      (group "\n")
      (group
       "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red")
      (group "\n")
      (group
       "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red")
      (group "\n")
      (group "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green")))))
  (group
   check
   (block
    (group
     def
     input
     (block
      (group
       "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red")))
    (group parse_line (parens (group input)))
    (group
     #:is
     Game
     (parens
      (group 4)
      (group
       (brackets
        (group
         (braces
          (group "red" (block (group 3)))
          (group "green" (block (group 1)))
          (group "blue" (block (group 6)))))
        (group
         (braces
          (group "red" (block (group 6)))
          (group "green" (block (group 3)))))
        (group
         (braces
          (group "red" (block (group 14)))
          (group "green" (block (group 3)))
          (group "blue" (block (group 15)))))))))))
  (group
   check
   (block
    (group
     Game
     (parens
      (group 1)
      (group
       (brackets
        (group
         (braces
          (group "red" (block (group 12)))
          (group "green" (block (group 13)))
          (group "blue" (block (group 14))))))))
     (op |.|)
     is_possible
     (parens (group 12) (group 13) (group 14)))
    (group #:is #t)))
  (group
   fun
   run1
   (parens (group input (op ::) String))
   (block
    (group
     util
     (op |.|)
     call_with_input_string
     (parens (group input))
     (block
      (group
       fun
       (parens (group inp (op ::) Port (op |.|) Input))
       (block
        (group
         for
         values
         (parens (group sum (op =) 0))
         (block
          (group
           each
           a_line
           (block (group util (op |.|) in_lines (parens (group inp)))))
          (group def a_game (op =) parse_line (parens (group a_line)))
          (group
           keep_when
           a_game
           (op |.|)
           is_possible
           (parens (group 12) (group 13) (group 14)))
          (group sum (op +) a_game (op |.|) number)))))))))
  (group check run1 (parens (group test_input)) #:is 8)
  (group
   module
   part1
   (block
    (group
     run1
     (parens
      (group
       aoc
       (op |.|)
       fetch_input
       (parens
        (group aoc (op |.|) find_session (parens))
        (group 2023)
        (group 2)))))))
  (group
   check
   (block
    (group
     def
     input
     (block
      (group
       "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red")))
    (group def g (op =) parse_line (parens (group input)))
    (group g (op |.|) power (parens))
    (group #:is 630)))
  (group
   fun
   run2
   (parens (group input (op ::) String))
   (block
    (group
     util
     (op |.|)
     call_with_input_string
     (parens (group input))
     (block
      (group
       fun
       (parens (group inp (op ::) Port (op |.|) Input))
       (block
        (group
         for
         values
         (parens (group sum (op =) 0))
         (block
          (group
           each
           a_line
           (block (group util (op |.|) in_lines (parens (group inp)))))
          (group
           sum
           (op +)
           parse_line
           (parens (group a_line))
           (op |.|)
           power
           (parens))))))))))
  (group check (block (group run2 (parens (group test_input)) #:is 2286)))
  (group
   module
   part2
   (block
    (group
     run2
     (parens
      (group
       aoc
       (op |.|)
       fetch_input
       (parens
        (group aoc (op |.|) find_session (parens))
        (group 2023)
        (group 2))))))))
