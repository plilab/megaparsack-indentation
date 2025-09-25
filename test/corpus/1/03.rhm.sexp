'(multi
  (group
   import
   (block
    (group "util/advent_of_code.rhm" as aoc)
    (group "util/misc.rhm" as util)))
  (group
   util
   (op |.|)
   example_input
   (parens
    (group test_input)
    (group
     (brackets
      (group "467..114..")
      (group "\n")
      (group "...*......")
      (group "\n")
      (group "..35..633.")
      (group "\n")
      (group "......#...")
      (group "\n")
      (group "617*......")
      (group "\n")
      (group ".....+.58.")
      (group "\n")
      (group "..592.....")
      (group "\n")
      (group "......755.")
      (group "\n")
      (group "...$.*....")
      (group "\n")
      (group ".664.598..")))))
  (group
   class
   Posn
   (parens (group x (op ::) Int) (group y (op ::) Int))
   (block
    (group
     method
     neighbors_8
     (parens)
     (op :~)
     List
     (op |.|)
     of
     (parens (group Posn))
     (block
      (group
       for
       List
       (block
        (group each dx (block (group -1 (op ..) 2)))
        (group each dy (block (group -1 (op ..) 2)))
        (group skip_when dx (op ==) 0 (op &&) dy (op ==) 0)
        (group Posn (parens (group dx (op +) x) (group dy (op +) y)))))))
    (group
     method
     neighbors_we
     (parens)
     (op :~)
     List
     (op |.|)
     of
     (parens (group Posn))
     (block
      (group
       for
       List
       (block
        (group each dx (block (group -1 (op ..) 2)))
        (group Posn (parens (group dx (op +) x) (group y)))))))))
  (group def ZERO (op =) Char (op |.|) to_int (parens (group #\0)))
  (group
   class
   Span
   (parens
    (group row (op ::) Int)
    (group start (op ::) Int)
    (group end (op ::) Int))
   (block
    (group
     constructor
     (parens (group schematic (op ::) Schematic) (group posn (op ::) Posn))
     (block
      (group let row (op =) posn (op |.|) y)
      (group
       fun
       grow
       (parens (group start (op ::) Int) (group end (op ::) Int))
       (block
        (group
         let
         l
         (op =)
         Char
         (op |.|)
         is_numeric
         (parens
          (group
           schematic
           (op |.|)
           ref
           (parens (group Posn (parens (group start (op -) 1) (group row)))))))
        (group
         let
         r
         (op =)
         Char
         (op |.|)
         is_numeric
         (parens
          (group
           schematic
           (op |.|)
           ref
           (parens (group Posn (parens (group end (op +) 1) (group row)))))))
        (group
         cond
         (alts
          (block
           (group
            l
            (op &&)
            r
            (block
             (group
              grow
              (parens (group start (op -) 1) (group end (op +) 1))))))
          (block
           (group
            l
            (block (group grow (parens (group start (op -) 1) (group end))))))
          (block
           (group
            r
            (block (group grow (parens (group start) (group end (op +) 1))))))
          (block
           (group
            #:else
            (block (group values (parens (group start) (group end))))))))))
      (group
       let
       values
       (parens (group start) (group end))
       (op =)
       grow
       (parens (group posn (op |.|) x) (group posn (op |.|) x)))
      (group super (parens (group row) (group start) (group end)))))
    (group
     method
     to_number
     (parens (group schematic (op ::) Schematic))
     (op ::)
     NonnegInt
     (block
      (group
       for
       values
       (parens (group n (op =) 0))
       (block
        (group each i (block (group start (op ..) end (op +) 1)))
        (group
         n
         (op *)
         10
         (op +)
         Char
         (op |.|)
         to_int
         (parens
          (group
           schematic
           (op |.|)
           ref
           (parens (group Posn (parens (group i) (group row))))))
         (op -)
         ZERO)))))))
  (group def NEWLINE (op =) #\newline)
  (group
   class
   Schematic
   (parens
    (group grid (op ::) Map (op |.|) of (parens (group Posn) (group Char)))
    (group parts (op ::) Set (op |.|) of (parens (group Posn))))
   (block
    (group export from_string)
    (group
     fun
     from_string
     (parens (group schematic_desc (op ::) String))
     (block
      (group
       let
       values
       (parens (group _col) (group _row) (group grid) (group parts))
       (block
        (group
         for
         values
         (parens
          (group col (op =) 0)
          (group row (op =) 0)
          (group grid (op =) (braces))
          (group parts (op =) Set (parens)))
         (block
          (group
           each
           ch
           (block
            (group util (op |.|) in_string (parens (group schematic_desc)))))
          (group
           let
           values
           (parens (group c) (group r))
           (block
            (group
             if
             ch
             (op ==)
             NEWLINE
             (alts
              (block (group values (parens (group 0) (group row (op +) 1))))
              (block
               (group values (parens (group col (op +) 1) (group row))))))))
          (group
           let
           values
           (parens (group grid) (group parts))
           (block
            (group
             if
             ch
             (op ==)
             NEWLINE
             (op \|\|)
             ch
             (op ==)
             #\.
             (alts
              (block (group values (parens (group grid) (group parts))))
              (block
               (group let p (op =) Posn (parens (group col) (group row)))
               (group
                let
                grid
                (op =)
                grid
                (op ++)
                (braces (group p (block (group ch)))))
               (group
                if
                Char
                (op |.|)
                is_numeric
                (parens (group ch))
                (alts
                 (block (group values (parens (group grid) (group parts))))
                 (block
                  (group
                   values
                   (parens
                    (group grid)
                    (group parts (op ++) (braces (group p)))))))))))))
          (group
           values
           (parens (group c) (group r) (group grid) (group parts)))))))
      (group Schematic (parens (group grid) (group parts)))))
    (group
     method
     ref
     (parens (group p (op ::) Posn))
     (op ::)
     Char
     (block (group grid (op |.|) get (parens (group p) (group #\.)))))
    (group
     method
     find_seeds
     (parens)
     (op :~)
     Set
     (op |.|)
     of
     (parens (group Posn))
     (block
      (group
       for
       Set
       (block
        (group each posn (block (group parts)))
        (group each n (block (group posn (op |.|) neighbors_8 (parens))))
        (group def c (block (group ref (parens (group n)))))
        (group keep_when Char (op |.|) is_numeric (parens (group c)))
        (group n)))))
    (group
     method
     find_part_numbers
     (parens)
     (op :~)
     List
     (op |.|)
     of
     (parens (group NonnegInt))
     (block
      (group
       let
       spans
       (block
        (group
         for
         Set
         (block
          (group each p (block (group find_seeds (parens))))
          (group Span (parens (group this) (group p)))))))
      (group
       for
       List
       (block
        (group each s (op :~) Span (block (group spans)))
        (group s (op |.|) to_number (parens (group this)))))))))
  (group
   check
   (block
    (group
     (parens
      (group
       Schematic
       (op |.|)
       from_string
       (parens (group test_input))
       (op :~)
       Schematic))
     (op |.|)
     ref
     (parens (group Posn (parens (group 0) (group 0))))
     #:is
     #\4)
    (group
     (parens
      (group
       Schematic
       (op |.|)
       from_string
       (parens (group test_input))
       (op :~)
       Schematic))
     (op |.|)
     ref
     (parens (group Posn (parens (group 1) (group 0))))
     #:is
     #\6)
    (group
     (parens
      (group
       Schematic
       (op |.|)
       from_string
       (parens (group test_input))
       (op :~)
       Schematic))
     (op |.|)
     ref
     (parens (group Posn (parens (group 7) (group 0))))
     #:is
     #\4)
    (group
     (parens
      (group
       Schematic
       (op |.|)
       from_string
       (parens (group test_input))
       (op :~)
       Schematic))
     (op |.|)
     ref
     (parens (group Posn (parens (group 9) (group 0))))
     #:is
     #\.)
    (group
     (parens
      (group
       Schematic
       (op |.|)
       from_string
       (parens (group test_input))
       (op :~)
       Schematic))
     (op |.|)
     ref
     (parens (group Posn (parens (group 0) (group 1))))
     #:is
     #\.)
    (group
     (parens
      (group
       Schematic
       (op |.|)
       from_string
       (parens (group test_input))
       (op :~)
       Schematic))
     (op |.|)
     ref
     (parens (group Posn (parens (group 3) (group 1))))
     #:is
     #\*)
    (group
     (parens
      (group
       Schematic
       (op |.|)
       from_string
       (parens (group test_input))
       (op :~)
       Schematic))
     (op |.|)
     ref
     (parens (group Posn (parens (group 0) (group 4))))
     #:is
     #\6)))
  (group
   check
   (block
    (group
     def
     schematic
     (op ::)
     Schematic
     (op =)
     Schematic
     (op |.|)
     from_string
     (parens (group test_input)))
    (group
     def
     s
     (op =)
     Span
     (parens (group schematic) (group Posn (parens (group 2) (group 0)))))
    (group
     (brackets
      (group s (op |.|) row)
      (group s (op |.|) start)
      (group s (op |.|) end)))
    (group #:is (block (group (brackets (group 0) (group 0) (group 2)))))))
  (group
   check
   (block
    (group
     def
     schematic
     (op ::)
     Schematic
     (op =)
     Schematic
     (op |.|)
     from_string
     (parens (group test_input)))
    (group
     def
     s
     (op =)
     Span
     (parens (group schematic) (group Posn (parens (group 5) (group 0)))))
    (group
     (brackets
      (group s (op |.|) row)
      (group s (op |.|) start)
      (group s (op |.|) end)))
    (group #:is (block (group (brackets (group 0) (group 5) (group 7)))))))
  (group
   check
   (block
    (group
     def
     s
     (op =)
     Schematic
     (op |.|)
     from_string
     (parens (group test_input)))
    (group
     Span
     (parens (group s) (group Posn (parens (group 0) (group 0))))
     (op |.|)
     to_number
     (parens (group s)))
    (group #:is 467)))
  (group
   fun
   run1
   (parens (group input (op ::) String))
   (op ::)
   NonnegInt
   (block
    (group
     def
     schematic
     (op ::)
     Schematic
     (op =)
     Schematic
     (op |.|)
     from_string
     (parens (group input)))
    (group
     for
     values
     (parens (group s (op =) 0))
     (block
      (group
       each
       p
       (block (group schematic (op |.|) find_part_numbers (parens))))
      (group s (op +) p)))))
  (group check (block (group run1 (parens (group test_input)) #:is 4361)))
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
        (group 3)))))))
  (group
   fun
   run2
   (parens (group input (op ::) String))
   (block
    (group
     def
     s
     (op ::)
     Schematic
     (op =)
     Schematic
     (op |.|)
     from_string
     (parens (group input)))
    (group
     def
     gears
     (op :~)
     Set
     (op |.|)
     of
     (parens (group Posn))
     (block
      (group
       for
       Set
       (block
        (group each p (block (group s (op |.|) parts)))
        (group keep_when s (op |.|) ref (parens (group p)) (op ==) #\*)
        (group p)))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each gear_p (block (group gears)))
      (group
       def
       parts
       (op :~)
       Set
       (op |.|)
       of
       (parens (group Span))
       (block
        (group
         for
         Set
         (block
          (group each n (block (group gear_p (op |.|) neighbors_8 (parens))))
          (group
           keep_when
           Char
           (op |.|)
           is_numeric
           (parens (group s (op |.|) ref (parens (group n)))))
          (group Span (parens (group s) (group n)))))))
      (group keep_when parts (op |.|) length (parens) (op ==) 2)
      (group
       def
       (brackets (group part0) (group part1))
       (block
        (group
         for
         List
         (block
          (group each p (block (group parts)))
          (group p (op |.|) to_number (parens (group s)))))))
      (group part0 (op *) part1 (op +) sum)))))
  (group check (block (group run2 (parens (group test_input)) #:is 467835)))
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
        (group 3))))))))
