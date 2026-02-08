'(multi
  (group
   import
   (block
    (group "util/advent_of_code.rhm" as aoc)
    (group "util/misc.rhm" as util)))
  (group
   fun
   find_num
   (parens
    (group s (op ::) String)
    (group i (op ::) NonnegInt)
    (group step (op ::) Int))
   (block
    (group let ch (op =) s (brackets (group i)))
    (group
     if
     Char
     (op |.|)
     is_numeric
     (parens (group ch))
     (alts
      (block (group ch))
      (block
       (group
        find_num
        (parens (group s) (group i (op +) step) (group step))))))))
  (group
   check
   (block
    (group find_num (parens (group "123") (group 0) (group 1)) #:is #\1)
    (group find_num (parens (group "123") (group 2) (group -1)) #:is #\3)
    (group find_num (parens (group "abc123def") (group 0) (group 1)) #:is #\1)
    (group
     find_num
     (parens (group "abc123def") (group 8) (group -1))
     #:is
     #\3)))
  (group def ZERO (op =) Char (op |.|) to_int (parens (group #\0)))
  (group
   fun
   char_to_value
   (parens (group ch (op ::) Char))
   (block (group Char (op |.|) to_int (parens (group ch)) (op -) ZERO)))
  (group
   check
   (block
    (group char_to_value (parens (group #\0)) #:is 0)
    (group char_to_value (parens (group #\9)) #:is 9)))
  (group
   util
   (op |.|)
   example_input
   (parens
    (group test_input1)
    (group
     (brackets
      (group "1abc2")
      (group "\n")
      (group "pqr3stu8vwx")
      (group "\n")
      (group "a1b2c3d4e5f")
      (group "\n")
      (group "treb7uchet")))))
  (group
   fun
   run1
   (parens (group input))
   (block
    (group
     util
     (op |.|)
     call_with_input_string
     input
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
           (op :~)
           String
           (block (group util (op |.|) in_lines (parens (group inp)))))
          (group
           let
           first
           (op =)
           find_num
           (parens (group a_line) (group 0) (group 1)))
          (group
           let
           last
           (op =)
           find_num
           (parens
            (group a_line)
            (group a_line (op |.|) length (parens) (op -) 1)
            (group -1)))
          (group
           char_to_value
           (parens (group first))
           (op *)
           10
           (op +)
           char_to_value
           (parens (group last))
           (op +)
           sum)))))))))
  (group check (block (group run1 (parens (group test_input1)) #:is 142)))
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
        (group 1)))))))
  (group
   class
   Pattern
   (parens (group string (op ::) String) (group value (op ::) NonnegInt))
   (block
    (group
     method
     derivative
     (parens (group ch (op ::) Char))
     (op ::)
     Pattern
     (op \|\|)
     False
     (block
      (group
       if
       this
       (op |.|)
       string
       (brackets (group 0))
       (op ==)
       ch
       (alts
        (block
         (group
          this
          with
          (parens
           (group
            string
            (op =)
            this
            (op |.|)
            string
            (op |.|)
            substring
            (parens (group 1))))))
        (block (group #f))))))
    (group
     method
     tail_derivative
     (parens (group ch (op ::) Char))
     (op ::)
     Pattern
     (op \|\|)
     False
     (block
      (group
       def
       z
       (op =)
       this
       (op |.|)
       string
       (op |.|)
       length
       (parens)
       (op -)
       1)
      (group
       if
       this
       (op |.|)
       string
       (brackets (group z))
       (op ==)
       ch
       (alts
        (block
         (group
          this
          with
          (parens
           (group
            string
            (op =)
            this
            (op |.|)
            string
            (op |.|)
            substring
            (parens (group 0) (group z))))))
        (block (group #f))))))))
  (group
   check
   (block
    (group
     Pattern
     (parens (group "abc") (group 0))
     (op |.|)
     derivative
     (parens (group #\a))
     #:is
     Pattern
     (parens (group "bc") (group 0)))
    (group
     Pattern
     (parens (group "abc") (group 0))
     (op |.|)
     derivative
     (parens (group #\b))
     #:is
     #f)))
  (group
   fun
   pat_list_derivative
   (parens
    (group f (op ::) Function)
    (group pats (op ::) List (op |.|) of (parens (group Pattern)))
    (group ch (op ::) Char))
   (block
    (group
     for
     List
     (block
      (group each p (block (group pats)))
      (group def dp (op =) f (parens (group p) (group ch)))
      (group keep_when dp)
      (group dp)))))
  (group
   fun
   head_derivative
   (parens (group p (op :~) Pattern) (group ch (op :~) Char))
   (block (group p (op |.|) derivative (parens (group ch)))))
  (group
   fun
   tail_derivative
   (parens (group p (op :~) Pattern) (group ch (op :~) Char))
   (block (group p (op |.|) tail_derivative (parens (group ch)))))
  (group
   check
   (block
    (group
     pat_list_derivative
     (parens
      (group head_derivative)
      (group
       (brackets
        (group Pattern (parens (group "abc") (group 0)))
        (group Pattern (parens (group "abd") (group 1)))
        (group Pattern (parens (group "xyz") (group 3)))))
      (group #\a)))
    (group
     #:is
     (brackets
      (group Pattern (parens (group "bc") (group 0)))
      (group Pattern (parens (group "bd") (group 1)))))))
  (group
   util
   (op |.|)
   example_input
   (parens
    (group test_input2)
    (group
     (brackets
      (group "two1nine")
      (group "\n")
      (group "eightwothree")
      (group "\n")
      (group "abcone2threexyz")
      (group "\n")
      (group "xtwone3four")
      (group "\n")
      (group "4nineeightseven2")
      (group "\n")
      (group "zoneight234")
      (group "\n")
      (group "7pqrstsixteen")))))
  (group
   def
   num_pats
   (op ::)
   List
   (op |.|)
   of
   (parens (group Pattern))
   (block
    (group
     Function
     (op |.|)
     map
     (parens
      (group Pattern)
      (group
       (brackets
        (group "0")
        (group "1")
        (group "2")
        (group "3")
        (group "4")
        (group "5")
        (group "6")
        (group "7")
        (group "8")
        (group "9")))
      (group List (op |.|) iota (parens (group 10))))
     (op ++)
     Function
     (op |.|)
     map
     (parens
      (group Pattern)
      (group
       (brackets
        (group "zero")
        (group "one")
        (group "two")
        (group "three")
        (group "four")
        (group "five")
        (group "six")
        (group "seven")
        (group "eight")
        (group "nine")))
      (group List (op |.|) iota (parens (group 10)))))))
  (group
   fun
   find_first_num
   (parens (group s (op ::) String))
   (op ::)
   NonnegInt
   (block
    (group
     fun
     match1
     (parens
      (group pats (op ::) List (op |.|) of (parens (group Pattern)))
      (group i (op ::) NonnegInt)
      (group j (op ::) NonnegInt))
     (block
      (group
       match
       pat_list_derivative
       (parens
        (group head_derivative)
        (group pats)
        (group s (brackets (group j))))
       (alts
        (block
         (group
          (brackets)
          (block
           (group
            match1
            (parens (group num_pats) (group i (op +) 1) (group i (op +) 1))))))
        (block
         (group
          (brackets (group Pattern (parens (group "") (group v))))
          (block (group v))))
        (block
         (group
          ps
          (block
           (group
            match1
            (parens (group ps) (group i) (group j (op +) 1))))))))))
    (group match1 (parens (group num_pats) (group 0) (group 0)))))
  (group
   fun
   find_last_num
   (parens (group s (op ::) String))
   (op ::)
   NonnegInt
   (block
    (group
     fun
     match1
     (parens
      (group pats (op ::) List (op |.|) of (parens (group Pattern)))
      (group i (op ::) NonnegInt)
      (group j (op ::) NonnegInt))
     (block
      (group
       match
       pat_list_derivative
       (parens
        (group tail_derivative)
        (group pats)
        (group s (brackets (group j))))
       (alts
        (block
         (group
          (brackets)
          (block
           (group
            match1
            (parens (group num_pats) (group i (op -) 1) (group i (op -) 1))))))
        (block
         (group
          (brackets (group Pattern (parens (group "") (group v))))
          (block (group v))))
        (block
         (group
          ps
          (block
           (group
            match1
            (parens (group ps) (group i) (group j (op -) 1))))))))))
    (group def z (op =) s (op |.|) length (parens) (op -) 1)
    (group match1 (parens (group num_pats) (group z) (group z)))))
  (group
   fun
   run2
   (parens (group input))
   (block
    (group
     util
     (op |.|)
     call_with_input_string
     input
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
           (op :~)
           String
           (block (group util (op |.|) in_lines (parens (group inp)))))
          (group let first (op =) find_first_num (parens (group a_line)))
          (group let last (op =) find_last_num (parens (group a_line)))
          (group first (op *) 10 (op +) last (op +) sum)))))))))
  (group check run2 (parens (group test_input2)) #:is 281)
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
        (group 1))))))))
