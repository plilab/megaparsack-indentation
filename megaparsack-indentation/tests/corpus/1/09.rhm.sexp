'(multi
  (group
   import
   (block
    (group "util/advent_of_code.rhm" as aoc)
    (group "util/misc.rhm" as util)
    (group "util/parsec.rhm" as p)))
  (group
   util
   (op |.|)
   example_input
   (parens
    (group test_input)
    (group
     (brackets
      (group "0 3 6 9 12 15")
      (group "\n")
      (group "1 3 6 10 15 21")
      (group "\n")
      (group "10 13 16 21 30 45")
      (group (parens (group "\n")))))))
  (group
   def
   spaces_p
   (block
    (group
     p
     (op |.|)
     many1
     (parens
      (group
       p
       (op |.|)
       try
       (parens (group p (op |.|) char (parens (group #\space)))))))))
  (group
   def
   line_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group n (op =) p (op |.|) integer)
      (group
       ns
       (op =)
       p
       (op |.|)
       many1
       (parens
        (group
         p
         (op |.|)
         try
         (parens
          (group
           p
           (op |.|)
           parse_sequence
           (block (group spaces_p) (group p (op |.|) integer)))))))
      (group p (op |.|) char (parens (group #\newline)))
      (group
       p
       (op |.|)
       pure
       (parens (group List (op |.|) cons (parens (group n) (group ns)))))))))
  (group def input_p (block (group p (op |.|) many1 (parens (group line_p)))))
  (group
   check
   (block
    (group
     p
     (op |.|)
     parse_string
     (parens (group line_p) (group "0 3 6 9\n"))
     #:is
     values
     (parens
      (group (brackets (group 0) (group 3) (group 6) (group 9)))
      (group (brackets))))
    (group
     p
     (op |.|)
     parse_string
     (parens (group input_p) (group "0 1 2\n0 2 4\n"))
     #:is
     (block
      (group
       values
       (parens
        (group
         (brackets
          (group (brackets (group 0) (group 1) (group 2)))
          (group (brackets (group 0) (group 2) (group 4)))))
        (group (brackets))))))))
  (group
   fun
   all_zero
   (parens (group nums (op ::) List (op |.|) of (parens (group Int))))
   (op ::)
   Boolean
   (block
    (group
     match
     nums
     (alts
      (block
       (group (brackets) (block (group error (parens (group "empty list"))))))
      (block (group (brackets (group 0)) (block (group #t))))
      (block
       (group
        (brackets (group 0) (group (op &) rest))
        (block (group all_zero (parens (group rest))))))
      (block (group _ (block (group #f))))))))
  (group
   fun
   delta
   (parens (group nums (op ::) List (op |.|) of (parens (group Int))))
   (op :~)
   values
   (parens (group List (op |.|) of (parens (group Int))) (group Int))
   (block
    (group
     match
     nums
     (alts
      (block
       (group
        (brackets (group a))
        (block (group values (parens (group (brackets)) (group a))))))
      (block
       (group
        Pair
        (parens
         (group a)
         (group Pair (parens (group b) (group _)) (op &&) rest))
        (block
         (group
          let
          values
          (parens (group rest) (group last))
          (op =)
          delta
          (parens (group rest)))
         (group
          values
          (parens
           (group (brackets (group b (op -) a) (group (op &) rest)))
           (group last))))))))))
  (group
   fun
   next_number
   (parens (group nums (op ::) List (op |.|) of (parens (group Int))))
   (block
    (group
     let
     values
     (parens (group nums) (group last))
     (op =)
     delta
     (parens (group nums)))
    (group
     if
     all_zero
     (parens (group nums))
     (alts
      (block (group last))
      (block (group next_number (parens (group nums)) (op +) last))))))
  (group
   check
   (block
    (group next_number (parens (group (brackets (group 1) (group 1)))) #:is 1)
    (group
     next_number
     (parens
      (group
       (brackets
        (group 0)
        (group 3)
        (group 6)
        (group 9)
        (group 12)
        (group 15))))
     #:is
     18)
    (group
     next_number
     (parens
      (group
       (brackets
        (group 1)
        (group 3)
        (group 6)
        (group 10)
        (group 15)
        (group 21))))
     #:is
     28)
    (group
     next_number
     (parens
      (group
       (brackets
        (group 10)
        (group 13)
        (group 16)
        (group 21)
        (group 30)
        (group 45))))
     #:is
     68)
    (group
     next_number
     (parens
      (group
       (brackets
        (group -1)
        (group 0)
        (group 2)
        (group -6)
        (group 27)
        (group 94)
        (group 10))))
     #:is
     -708)))
  (group
   fun
   run1
   (parens (group input))
   (block
    (group
     def
     values
     (parens
      (group
       lines
       (op ::)
       List
       (op |.|)
       of
       (parens (group List (op |.|) of (parens (group Int)))))
      (group (brackets)))
     (block
      (group p (op |.|) parse_string (parens (group input_p) (group input)))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each line (block (group lines)))
      (group sum (op +) next_number (parens (group line)))))))
  (group check (block (group run1 (parens (group test_input)) #:is 114)))
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
        (group 9)))))))
  (group
   fun
   prev_number
   (parens (group nums (op ::) List (op |.|) of (parens (group Int))))
   (block
    (group def first (op =) nums (brackets (group 0)))
    (group
     let
     values
     (parens (group nums) (group _last))
     (op =)
     delta
     (parens (group nums)))
    (group
     if
     all_zero
     (parens (group nums))
     (alts
      (block (group first))
      (block (group first (op -) prev_number (parens (group nums))))))))
  (group
   check
   (block
    (group prev_number (parens (group (brackets (group 1) (group 1)))) #:is 1)
    (group
     prev_number
     (parens
      (group
       (brackets
        (group 0)
        (group 3)
        (group 6)
        (group 9)
        (group 12)
        (group 15))))
     #:is
     -3)
    (group
     prev_number
     (parens
      (group
       (brackets
        (group 1)
        (group 3)
        (group 6)
        (group 10)
        (group 15)
        (group 21))))
     #:is
     0)
    (group
     prev_number
     (parens
      (group
       (brackets
        (group 10)
        (group 13)
        (group 16)
        (group 21)
        (group 30)
        (group 45))))
     #:is
     5)))
  (group
   fun
   run2
   (parens (group input))
   (block
    (group
     def
     values
     (parens
      (group
       lines
       (op ::)
       List
       (op |.|)
       of
       (parens (group List (op |.|) of (parens (group Int)))))
      (group (brackets)))
     (block
      (group p (op |.|) parse_string (parens (group input_p) (group input)))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each line (block (group lines)))
      (group sum (op +) prev_number (parens (group line)))))))
  (group check (block (group run2 (parens (group test_input)) #:is 2)))
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
        (group 9))))))))
