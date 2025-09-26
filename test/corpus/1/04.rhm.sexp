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
      (group "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53")
      (group "\n")
      (group "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19")
      (group "\n")
      (group "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1")
      (group "\n")
      (group "Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83")
      (group "\n")
      (group "Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36")
      (group "\n")
      (group "Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11")))))
  (group
   class
   Card
   (parens
    (group number (op ::) NonnegInt)
    (group winning (op ::) Set (op |.|) of (parens (group NonnegInt)))
    (group picks (op ::) Set (op |.|) of (parens (group NonnegInt))))
   (block
    (group
     method
     matching_picks
     (parens)
     (op ::)
     NonnegInt
     (block
      (group
       winning
       (op |.|)
       intersect
       (parens (group picks))
       (op |.|)
       length
       (parens))))
    (group
     method
     points
     (parens)
     (op ::)
     NonnegInt
     (block
      (group
       match
       matching_picks
       (parens)
       (alts
        (block (group 0 (block (group 0))))
        (block
         (group m (block (group 2 (op **) (parens (group m (op -) 1))))))))))))
  (group
   def
   integer_set_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
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
           (block (group p (op |.|) spaces) (group p (op |.|) integer)))))))
      (group
       p
       (op |.|)
       pure
       (parens (group Set (parens (group (op &) ns)))))))))
  (group
   def
   card_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group p (op |.|) string (parens (group "Card")))
      (group p (op |.|) spaces)
      (group card_number (op =) p (op |.|) integer)
      (group p (op |.|) char (parens (group #\:)))
      (group winning (op =) integer_set_p)
      (group p (op |.|) spaces)
      (group p (op |.|) char (parens (group #\|)))
      (group picks (op =) integer_set_p)
      (group
       p
       (op |.|)
       choice
       (parens
        (group p (op |.|) char (parens (group #\newline)))
        (group p (op |.|) pure (parens (group #t)))))
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         Card
         (parens (group card_number) (group winning) (group picks)))))))))
  (group
   fun
   run1
   (parens (group input))
   (block
    (group
     def
     values
     (parens
      (group cards (op ::) List (op |.|) of (parens (group Card)))
      (group (brackets)))
     (block
      (group
       p
       (op |.|)
       parse
       (parens
        (group p (op |.|) many1 (parens (group card_p)))
        (group p (op |.|) string_to_list (parens (group input)))))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each card (block (group cards)))
      (group sum (op +) card (op |.|) points (parens))))))
  (group check (block (group run1 (parens (group test_input)) #:is 13)))
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
        (group 4)))))))
  (group
   class
   CardCounts
   (parens
    (group count (op ::) PosInt)
    (group next (op ::) CardCounts (op \|\|) False))
   (block
    (group export init)
    (group
     fun
     init
     (parens)
     (block (group CardCounts (parens (group 1) (group #f)))))
    (group property first (op ::) PosInt (block (group count)))
    (group
     property
     rest
     (op ::)
     CardCounts
     (block
      (group
       if
       next
       (alts
        (block (group next))
        (block (group CardCounts (op |.|) init (parens)))))))
    (group
     method
     add_copies
     (parens (group repeat (op ::) NonnegInt) (group copies (op ::) PosInt))
     (op ::)
     CardCounts
     (block
      (group
       match
       repeat
       (alts
        (block (group 0 (block (group this))))
        (block
         (group
          1
          (block
           (group
            CardCounts
            (parens (group count (op +) copies) (group next))))))
        (block
         (group
          _
          (block
           (group
            CardCounts
            (parens
             (group count (op +) copies)
             (group
              rest
              (op |.|)
              add_copies
              (parens (group repeat (op -) 1) (group copies))))))))))))))
  (group
   fun
   run_part2
   (parens
    (group cards (op :~) List (op |.|) of (parens (group Card)))
    (group counts (op :~) CardCounts)
    (group num_processed (op :~) NonnegInt))
   (block
    (group
     if
     cards
     (op ==)
     (brackets)
     (alts
      (block (group num_processed))
      (block
       (group def copies (op =) counts (op |.|) first)
       (group
        def
        picks
        (op =)
        cards
        (op |.|)
        first
        (op |.|)
        matching_picks
        (parens))
       (group
        def
        next_counts
        (op =)
        counts
        (op |.|)
        rest
        (op |.|)
        add_copies
        (parens (group picks) (group copies)))
       (group
        run_part2
        (parens
         (group cards (op |.|) rest)
         (group next_counts)
         (group num_processed (op +) copies))))))))
  (group
   fun
   run2
   (parens (group input))
   (block
    (group
     def
     values
     (parens
      (group cards (op ::) List (op |.|) of (parens (group Card)))
      (group (brackets)))
     (block
      (group
       p
       (op |.|)
       parse
       (parens
        (group p (op |.|) many1 (parens (group card_p)))
        (group p (op |.|) string_to_list (parens (group input)))))))
    (group
     run_part2
     (parens
      (group cards)
      (group CardCounts (op |.|) init (parens))
      (group 0)))))
  (group check (block (group run2 (parens (group test_input)) #:is 30)))
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
        (group 4))))))))
