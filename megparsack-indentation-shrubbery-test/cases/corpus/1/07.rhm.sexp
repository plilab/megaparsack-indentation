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
      (group "32T3K 765")
      (group "\n")
      (group "T55J5 684")
      (group "\n")
      (group "KK677 28")
      (group "\n")
      (group "KTJJT 220")
      (group "\n")
      (group "QQQJA 483")
      (group (parens (group "\n")))))))
  (group
   annot
   (op |.|)
   macro
   (quotes (group CompareResult))
   (block
    (group
     (quotes
      (group
       matching
       (parens
        (group
         (op |#'|)
         lesser
         (op \|\|)
         (op |#'|)
         equal
         (op \|\|)
         (op |#'|)
         greater)))))))
  (group
   interface
   Comparable
   (block
    (group method compare (parens (group other)) (op ::) CompareResult)
    (group
     method
     less
     (parens (group other))
     (op ::)
     Boolean
     (block (group compare (parens (group other)) (op ==) (op |#'|) lesser)))))
  (group
   fun
   compare
   (op ::)
   CompareResult
   (alts
    (block
     (group
      compare
      (parens (group a (op ::) Number) (group b (op ::) Number))
      (block
       (group
        cond
        (alts
         (block (group a (op <) b (block (group (op |#'|) lesser))))
         (block (group a (op .=) b (block (group (op |#'|) equal))))
         (block (group a (op >) b (block (group (op |#'|) greater)))))))))
    (block
     (group
      compare
      (parens (group a (op ::) Comparable) (group b (op ::) Comparable))
      (block (group a (op |.|) compare (parens (group b))))))))
  (group namespace C (block (group export compare)))
  (group
   expr
   (op |.|)
   macro
   (alts
    (block
     (group
      (quotes
       (group refine_compare (alts (block (group (op $) compare_expr)))))
      (block (group (quotes (group (op $) compare_expr))))))
    (block
     (group
      (quotes
       (group
        refine_compare
        (alts
         (block (group (op $) compare_expr))
         (block (group (op $) compare_rest))
         (block (group (op ...))))))
      (block
       (group
        (quotes
         (group
          block
          (block
           (group def res (block (group (op $) compare_expr)))
           (group
            if
            res
            (op ==)
            (op |#'|)
            equal
            (alts
             (block
              (group
               refine_compare
               (alts
                (block (group (op $) compare_rest))
                (block (group (op ...))))))
             (block (group res)))))))))))))
  (group
   expr
   (op |.|)
   macro
   (quotes
    (group
     compare_enum
     (parens (group (op $) a) (group (op $) b))
     (block (group (op $) (parens (group vals (op ::) Block))))))
   (block
    (group
     let
     (brackets (group _) (group (op &) vals))
     (op =)
     vals
     (op |.|)
     unwrap
     (parens))
    (group
     def
     (brackets (group vals_n) (group (op ...)))
     (op =)
     List
     (op |.|)
     iota
     (parens (group vals (op |.|) length (parens))))
    (group let (brackets (group vals) (group (op ...))) (op =) vals)
    (group
     (quotes
      (group
       block
       (block
        (group
         fun
         to_val
         (parens (group v))
         (block
          (group
           match
           v
           (alts
            (block (group (op $) vals (block (group (op $) vals_n))))
            (block (group (op ...)))))))
        (group
         compare
         (parens
          (group to_val (parens (group (op $) a)))
          (group to_val (parens (group (op $) b)))))))))))
  (group
   expr
   (op |.|)
   macro
   (quotes
    (group
     compare_case
     (op $)
     compare_expr
     (alts
      (block (group (op $) (parens (group lesser_case))))
      (block (group (op $) (parens (group equal_case))))
      (block (group (op $) (parens (group greater_case)))))))
   (block
    (group
     (quotes
      (group
       match
       (op $)
       compare_expr
       (alts
        (block (group (op |#'|) lesser (block (group (op $) lesser_case))))
        (block (group (op |#'|) equal (block (group (op $) equal_case))))
        (block
         (group (op |#'|) greater (block (group (op $) greater_case))))))))))
  (group
   class
   Hand
   (parens
    (group cards (op ::) List (op |.|) of (parens (group PosInt)))
    (group bid (op ::) PosInt)
    (group hand_type (op ::) List (op |.|) of (parens (group PosInt))))
   (block
    (group implements Comparable)
    (group
     constructor
     (parens
      (group cards (op ::) List (op |.|) of (parens (group PosInt)))
      (group bid (op ::) PosInt))
     (block
      (group
       def
       counts
       (op :~)
       Map
       (block
        (group
         for
         values
         (parens (group counts (op =) (braces (group 1 (block (group 0))))))
         (block
          (group each c (block (group cards)))
          (group
           counts
           (op ++)
           (braces
            (group
             c
             (block
              (group
               counts
               (op |.|)
               get
               (parens (group c) (group 0))
               (op +)
               1)))))))))
      (group
       let
       Map
       (braces (group 1 (block (group num_jokers))) (group (op &) counts))
       (block (group counts)))
      (group
       def
       hand_type
       (block
        (group
         match
         counts
         (op |.|)
         values
         (parens)
         (op |.|)
         sort
         (parens (group math (op |.|) greater))
         (alts
          (block
           (group (brackets) (block (group (brackets (group num_jokers))))))
          (block
           (group
            (brackets (group a) (group (op &) rest))
            (block
             (group
              List
              (op |.|)
              cons
              (parens (group a (op +) num_jokers) (group rest))))))))))
      (group super (parens (group cards) (group bid) (group hand_type)))))
    (group
     property
     hand_type_name
     (op ::)
     Symbol
     (block
      (group
       match
       hand_type
       (alts
        (block (group (brackets (group 5)) (block (group (op |#'|) five))))
        (block
         (group (brackets (group 4) (group 1)) (block (group (op |#'|) four))))
        (block
         (group
          (brackets (group 3) (group 2))
          (block (group (op |#'|) full_house))))
        (block
         (group
          (brackets (group 3) (group 1) (group 1))
          (block (group (op |#'|) three))))
        (block
         (group
          (brackets (group 2) (group 2) (group 1))
          (block (group (op |#'|) two_pair))))
        (block
         (group
          (brackets (group 2) (group 1) (group 1) (group 1))
          (block (group (op |#'|) pair))))
        (block
         (group
          (brackets (group 1) (group 1) (group 1) (group 1) (group 1))
          (block (group (op |#'|) high))))))))
    (group
     method
     compare_hand_type
     (parens (group other (op ::) Hand))
     (op ::)
     CompareResult
     (block
      (group
       compare_enum
       (parens (group hand_type_name) (group other (op |.|) hand_type_name))
       (block
        (group (op |#'|) high)
        (group (op |#'|) pair)
        (group (op |#'|) two_pair)
        (group (op |#'|) three)
        (group (op |#'|) full_house)
        (group (op |#'|) four)
        (group (op |#'|) five)))))
    (group
     method
     compare_cards
     (parens (group a (op ::) List) (group b (op ::) List))
     (op ::)
     CompareResult
     (block
      (group
       cond
       (alts
        (block
         (group
          a
          (op ==)
          (brackets)
          (op &&)
          b
          (op ==)
          (brackets)
          (block (group (op |#'|) equal))))
        (block
         (group
          #:else
          (block
           (group
            refine_compare
            (alts
             (block
              (group
               C
               (op |.|)
               compare
               (parens (group a (op |.|) first) (group b (op |.|) first))))
             (block
              (group
               compare_cards
               (parens
                (group a (op |.|) rest)
                (group b (op |.|) rest)))))))))))))
    (group
     override
     method
     compare
     (parens (group other (op ::) Hand))
     (op ::)
     CompareResult
     (block
      (group
       refine_compare
       (alts
        (block (group compare_hand_type (parens (group other))))
        (block
         (group
          compare_cards
          (parens (group cards) (group other (op |.|) cards))))))))))
  (group
   operator
   a_p
   (op <\|>)
   b_p
   (block (group p (op |.|) choice (parens (group a_p) (group b_p)))))
  (group
   fun
   char_val_p
   (parens (group str (op ::) String) (group val))
   (block
    (group
     p
     (op |.|)
     try
     (parens
      (group
       p
       (op |.|)
       parse_sequence
       (block
        (group p (op |.|) char (parens (group str (brackets (group 0)))))
        (group p (op |.|) pure (parens (group val)))))))))
  (group
   fun
   card_p
   (parens (group j_value))
   (block
    (group
     char_val_p
     (parens (group "2") (group 2))
     (op <\|>)
     char_val_p
     (parens (group "3") (group 3))
     (op <\|>)
     char_val_p
     (parens (group "4") (group 4))
     (op <\|>)
     char_val_p
     (parens (group "5") (group 5))
     (op <\|>)
     char_val_p
     (parens (group "6") (group 6))
     (op <\|>)
     char_val_p
     (parens (group "7") (group 7))
     (op <\|>)
     char_val_p
     (parens (group "8") (group 8))
     (op <\|>)
     char_val_p
     (parens (group "9") (group 9))
     (op <\|>)
     char_val_p
     (parens (group "T") (group 10))
     (op <\|>)
     char_val_p
     (parens (group "J") (group j_value))
     (op <\|>)
     char_val_p
     (parens (group "Q") (group 12))
     (op <\|>)
     char_val_p
     (parens (group "K") (group 13))
     (op <\|>)
     char_val_p
     (parens (group "A") (group 14)))))
  (group
   fun
   hand_p
   (parens (group j_value))
   (block
    (group let card_p (block (group card_p (parens (group j_value)))))
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group a (op =) card_p)
      (group b (op =) card_p)
      (group c (op =) card_p)
      (group d (op =) card_p)
      (group e (op =) card_p)
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         (brackets (group a) (group b) (group c) (group d) (group e)))))))))
  (group
   fun
   line_p
   (parens (group j_value))
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group hand (op =) hand_p (parens (group j_value)))
      (group p (op |.|) spaces)
      (group bid (op =) p (op |.|) integer)
      (group p (op |.|) char (parens (group #\newline)))
      (group
       p
       (op |.|)
       pure
       (parens (group Hand (parens (group hand) (group bid)))))))))
  (group
   fun
   input_p
   (parens (group j_value))
   (block
    (group p (op |.|) many1 (parens (group line_p (parens (group j_value)))))))
  (group
   fun
   make_run
   (parens (group j_value))
   (block
    (group
     fun
     (parens (group input))
     (block
      (group
       def
       values
       (parens
        (group hands (op ::) List (op |.|) of (parens (group Hand)))
        (group (brackets)))
       (block
        (group
         p
         (op |.|)
         parse_string
         (parens (group input_p (parens (group j_value))) (group input)))))
      (group
       let
       hands
       (op :~)
       List
       (op |.|)
       of
       (parens (group Hand))
       (block (group hands (op |.|) sort (parens (group Hand (op |.|) less)))))
      (group
       for
       values
       (parens (group sum (op =) 0))
       (block
        (group
         each
         (block
          (group h (block (group hands)))
          (group i (block (group 1 (op ..))))))
        (group sum (op +) i (op *) h (op |.|) bid)))))))
  (group def run1 (op =) make_run (parens (group 11)))
  (group check (block (group run1 (parens (group test_input)) #:is 6440)))
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
        (group 7)))))))
  (group def run2 (op =) make_run (parens (group 1)))
  (group check (block (group run2 (parens (group test_input)) #:is 5905)))
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
        (group 7))))))))
