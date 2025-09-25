'(multi
  (group
   import
   (block
    (group file (parens (group "./utils/aoc_api.rhm")))
    (group file (parens (group "./utils/utils.rhm")))
    (group file (parens (group "./utils/lang.rhm")) open)
    (group
     lib
     (parens (group "racket/main.rkt"))
     as
     racket
     (block
      (group
       rename
       (block
        (group char-numeric? as is_numeric_char)
        (group char->integer as char_to_int)
        (group with-input-from-file as with_input_from_file)
        (group with-output-to-file as with_output_to_file)
        (group file-exists? as exists_file)))))
    (group
     lib
     (parens (group "racket/string.rkt"))
     as
     string
     (block
      (group
       rename
       (block
        (group string-prefix? as is_string_prefix)
        (group string-split as split)
        (group string-trim as trim)))))))
  (group
   def
   input
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 7)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "32T3K 765")
      (group "T55J5 684")
      (group "KK677 28")
      (group "KTJJT 220")
      (group "QQQJA 483")))))
  (group class Card (parens (group name) (group score (op ::) Int)))
  (group
   fun
   Card
   (op |.|)
   make
   (parens (group c (op ::) Char))
   (block
    (group
     match
     c
     (alts
      (block
       (group
        (parens (group #\A))
        (block (group Card (parens (group c) (group 13))))))
      (block
       (group
        (parens (group #\K))
        (block (group Card (parens (group c) (group 12))))))
      (block
       (group
        (parens (group #\Q))
        (block (group Card (parens (group c) (group 11))))))
      (block
       (group
        (parens (group #\J))
        (block (group Card (parens (group c) (group 10))))))
      (block
       (group
        (parens (group #\T))
        (block (group Card (parens (group c) (group 9))))))
      (block
       (group
        (parens (group #\9))
        (block (group Card (parens (group c) (group 8))))))
      (block
       (group
        (parens (group #\8))
        (block (group Card (parens (group c) (group 7))))))
      (block
       (group
        (parens (group #\7))
        (block (group Card (parens (group c) (group 6))))))
      (block
       (group
        (parens (group #\6))
        (block (group Card (parens (group c) (group 5))))))
      (block
       (group
        (parens (group #\5))
        (block (group Card (parens (group c) (group 4))))))
      (block
       (group
        (parens (group #\4))
        (block (group Card (parens (group c) (group 3))))))
      (block
       (group
        (parens (group #\3))
        (block (group Card (parens (group c) (group 2))))))
      (block
       (group
        (parens (group #\2))
        (block (group Card (parens (group c) (group 1))))))))))
  (group
   fun
   Card
   (op |.|)
   make_joker
   (parens (group c (op ::) Char))
   (block
    (group
     match
     c
     (alts
      (block
       (group
        (parens (group #\A))
        (block (group Card (parens (group c) (group 13))))))
      (block
       (group
        (parens (group #\K))
        (block (group Card (parens (group c) (group 12))))))
      (block
       (group
        (parens (group #\Q))
        (block (group Card (parens (group c) (group 11))))))
      (block
       (group
        (parens (group #\T))
        (block (group Card (parens (group c) (group 9))))))
      (block
       (group
        (parens (group #\9))
        (block (group Card (parens (group c) (group 8))))))
      (block
       (group
        (parens (group #\8))
        (block (group Card (parens (group c) (group 7))))))
      (block
       (group
        (parens (group #\7))
        (block (group Card (parens (group c) (group 6))))))
      (block
       (group
        (parens (group #\6))
        (block (group Card (parens (group c) (group 5))))))
      (block
       (group
        (parens (group #\5))
        (block (group Card (parens (group c) (group 4))))))
      (block
       (group
        (parens (group #\4))
        (block (group Card (parens (group c) (group 3))))))
      (block
       (group
        (parens (group #\3))
        (block (group Card (parens (group c) (group 2))))))
      (block
       (group
        (parens (group #\2))
        (block (group Card (parens (group c) (group 1))))))
      (block
       (group
        (parens (group #\J))
        (block (group Card (parens (group c) (group 0))))))))))
  (group
   class
   Hand
   (parens
    (group s (op ::) String)
    (group chars (op ::) List (op |.|) of (parens (group Card)))
    (group char_set (op ::) Map (op |.|) of (parens (group Char) (group Int)))
    (group
     rev_char_set
     (op ::)
     Map
     (op |.|)
     of
     (parens (group Int) (group List (op |.|) of (parens (group Char)))))
    (group joker_count (op ::) Int))
   (block
    (group
     method
     five_of_a_kind
     (parens)
     (block (group rev_char_set (op |.|) has_key (parens (group 5)))))
    (group
     method
     four_of_a_kind
     (parens)
     (block (group rev_char_set (op |.|) has_key (parens (group 4)))))
    (group
     method
     full_house
     (parens)
     (block
      (group
       rev_char_set
       (op |.|)
       has_key
       (parens (group 3))
       (op &&)
       rev_char_set
       (op |.|)
       has_key
       (parens (group 2)))))
    (group
     method
     three_of_a_kind
     (parens)
     (block (group rev_char_set (op |.|) has_key (parens (group 3)))))
    (group
     method
     two_pair
     (parens)
     (block
      (group
       rev_char_set
       (op |.|)
       has_key
       (parens (group 2))
       (op &&)
       rev_char_set
       (brackets (group 2))
       (op |.|)
       length
       (parens)
       (op ==)
       2)))
    (group
     method
     one_pair
     (parens)
     (block (group rev_char_set (op |.|) has_key (parens (group 2)))))
    (group
     method
     high_card
     (parens)
     (block
      (group
       rev_char_set
       (op |.|)
       has_key
       (parens (group 1))
       (op &&)
       rev_char_set
       (brackets (group 1))
       (op |.|)
       length
       (parens)
       (op ==)
       5)))
    (group
     method
     score
     (parens)
     (op ::)
     Int
     (block
      (group
       cond
       (alts
        (block (group five_of_a_kind (parens) (block (group 6))))
        (block (group four_of_a_kind (parens) (block (group 5))))
        (block (group full_house (parens) (block (group 4))))
        (block (group three_of_a_kind (parens) (block (group 3))))
        (block (group two_pair (parens) (block (group 2))))
        (block (group one_pair (parens) (block (group 1))))
        (block (group high_card (parens) (block (group 0))))))))
    (group
     method
     score_with_jokers
     (parens)
     (op ::)
     Int
     (block
      (group
       if
       joker_count
       (op ==)
       0
       (alts
        (block (group score (parens)))
        (block
         (group
          let
          values
          (parens (group max_occ) (group max_cs))
          (block
           (group
            for
            values
            (parens (group res (op =) 0) (group res_cs (op =) #f))
            (block
             (group
              each
              values
              (parens (group k) (group cs))
              (block (group rev_char_set)))
             (group
              cond
              (alts
               (block
                (group
                 (op !)
                 res
                 (block (group values (parens (group k) (group cs))))))
               (block
                (group
                 k
                 (op >)
                 res
                 (block (group values (parens (group k) (group cs))))))
               (block
                (group
                 #:else
                 (block
                  (group values (parens (group res) (group res_cs))))))))))))
         (group let joker_occ (block (group max_occ (op +) joker_count)))
         (group
          match
          joker_occ
          (alts
           (block (group 5 (block (group 6))))
           (block (group 4 (block (group 5))))
           (block
            (group
             3
             when
             rev_char_set
             (op |.|)
             has_key
             (parens (group 2))
             (op &&)
             rev_char_set
             (brackets (group 2))
             (op |.|)
             length
             (parens)
             (op ==)
             2
             (block (group 4))))
           (block (group 3 (block (group 3))))
           (block (group 2 (block (group 1)))))))))))
    (group
     constructor
     (alts
      (block
       (group
        (parens (group hand (op ::) ReadableString))
        (block
         (group
          let
          chars
          (block
           (group
            for
            List
            (block
             (group each card (block (group hand)))
             (group Card (op |.|) make (parens (group card)))))))
         (group
          let
          char_set
          (block
           (group let cset (block (group MutableMap (parens))))
           (group
            for
            (block
             (group each card (block (group hand)))
             (group
              if
              cset
              (op |.|)
              has_key
              (parens (group card))
              (alts
               (block
                (group
                 cset
                 (brackets (group card))
                 (op :=)
                 cset
                 (brackets (group card))
                 (op +)
                 1))
               (block (group cset (brackets (group card)) (op :=) 1))))))
           (group cset (op |.|) snapshot (parens))))
         (group
          let
          rev_char_set
          (block
           (group let cset (block (group MutableMap (parens))))
           (group
            for
            (block
             (group
              each
              values
              (parens (group char) (group occs))
              (block (group char_set)))
             (group
              if
              cset
              (op |.|)
              has_key
              (parens (group occs))
              (alts
               (block
                (group
                 cset
                 (brackets (group occs))
                 (op :=)
                 List
                 (op |.|)
                 cons
                 (parens (group char) (group cset (brackets (group occs))))))
               (block
                (group
                 cset
                 (brackets (group occs))
                 (op :=)
                 (brackets (group char))))))))
           (group cset (op |.|) snapshot (parens))))
         (group
          super
          (parens
           (group hand)
           (group chars)
           (group char_set)
           (group rev_char_set)
           (group 0))))))
      (block
       (group
        (parens
         (group hand (op ::) ReadableString)
         (group has_jokers (op ::) Boolean))
        (block
         (group
          if
          (op !)
          has_jokers
          (alts
           (block (group super (parens (group hand))))
           (block
            (group
             let
             chars
             (block
              (group
               for
               List
               (block
                (group each card (block (group hand)))
                (group Card (op |.|) make_joker (parens (group card)))))))
            (group let mutable jokers (block (group 0)))
            (group
             let
             char_set
             (block
              (group let cset (block (group MutableMap (parens))))
              (group
               for
               (block
                (group each card (block (group hand)))
                (group
                 cond
                 (alts
                  (block
                   (group
                    card
                    (op ==)
                    #\J
                    (block (group jokers (op :=) jokers (op +) 1))))
                  (block
                   (group
                    cset
                    (op |.|)
                    has_key
                    (parens (group card))
                    (block
                     (group
                      cset
                      (brackets (group card))
                      (op :=)
                      cset
                      (brackets (group card))
                      (op +)
                      1))))
                  (block
                   (group
                    #:else
                    (block
                     (group cset (brackets (group card)) (op :=) 1))))))))
              (group cset (op |.|) snapshot (parens))))
            (group
             let
             rev_char_set
             (block
              (group let cset (block (group MutableMap (parens))))
              (group
               for
               (block
                (group
                 each
                 values
                 (parens (group char) (group occs))
                 (block (group char_set)))
                (group
                 if
                 cset
                 (op |.|)
                 has_key
                 (parens (group occs))
                 (alts
                  (block
                   (group
                    cset
                    (brackets (group occs))
                    (op :=)
                    List
                    (op |.|)
                    cons
                    (parens
                     (group char)
                     (group cset (brackets (group occs))))))
                  (block
                   (group
                    cset
                    (brackets (group occs))
                    (op :=)
                    (brackets (group char))))))))
              (group cset (op |.|) snapshot (parens))))
            (group
             super
             (parens
              (group hand)
              (group chars)
              (group char_set)
              (group rev_char_set)
              (group jokers)))))))))))))
  (group
   fun
   card_list_lte
   (parens
    (group c1 (op ::) List (op |.|) of (parens (group Card)))
    (group c2 (op ::) List (op |.|) of (parens (group Card))))
   (block
    (group
     match
     (brackets (group c1) (group c2))
     (alts
      (block
       (group
        (brackets
         (group List (op |.|) cons (parens (group c1) (group c1_tail)))
         (group List (op |.|) cons (parens (group c2) (group c2_tail))))
        (block
         (group
          cond
          (alts
           (block
            (group
             c1
             (op |.|)
             score
             (op ==)
             c2
             (op |.|)
             score
             (block
              (group card_list_lte (parens (group c1_tail) (group c2_tail))))))
           (block
            (group
             #:else
             (block (group c1 (op |.|) score (op <) c2 (op |.|) score)))))))))
      (block
       (group
        (brackets (group (brackets)) (group (brackets)))
        (block (group #f))))))))
  (group
   check
   (block
    (group
     card_list_lte
     (parens
      (group
       (brackets
        (group Card (parens (group "a") (group 1)))
        (group Card (parens (group "b") (group 2)))))
      (group
       (brackets
        (group Card (parens (group "a") (group 10)))
        (group Card (parens (group "b") (group 20)))))))
    (group #:is #t)))
  (group
   check
   (block
    (group
     card_list_lte
     (parens
      (group
       (brackets
        (group Card (parens (group "a") (group 1)))
        (group Card (parens (group "b") (group 2)))))
      (group
       (brackets
        (group Card (parens (group "a") (group 1)))
        (group Card (parens (group "b") (group 20)))))))
    (group #:is #t)))
  (group
   fun
   deck_lt
   (parens
    (group ld (op ::) Pair (op |.|) of (parens (group Hand) (group Int)))
    (group rd (op ::) Pair (op |.|) of (parens (group Hand) (group Int))))
   (block
    (group let ld_score (op =) ld (op |.|) first (op |.|) score (parens))
    (group let rd_score (op =) rd (op |.|) first (op |.|) score (parens))
    (group
     cond
     (alts
      (block (group ld_score (op <) rd_score (block (group #t))))
      (block
       (group
        ld_score
        (op ==)
        rd_score
        (block
         (group
          card_list_lte
          (parens
           (group ld (op |.|) first (op |.|) chars)
           (group rd (op |.|) first (op |.|) chars))))))
      (block (group #:else (block (group #f))))))))
  (group
   check
   (block
    (group
     deck_lt
     (parens
      (group Pair (parens (group Hand (parens (group "33332"))) (group 1)))
      (group Pair (parens (group Hand (parens (group "2AAAA"))) (group 1)))))
    (group #:is #f)))
  (group
   check
   (block
    (group
     deck_lt
     (parens
      (group Pair (parens (group Hand (parens (group "77888"))) (group 1)))
      (group Pair (parens (group Hand (parens (group "77788"))) (group 1)))))
    (group #:is #f)))
  (group let raw_input (block (group test_input)))
  (group
   fun
   calculate_result1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     cards
     (block
      (group
       for
       List
       (parens
        (group
         line
         (block
          (group
           utils
           (op |.|)
           string
           (op |.|)
           split_lines
           (parens (group raw_input))))))
       (block
        (group
         let
         (brackets (group hand_str) (group bid))
         (op =)
         utils
         (op |.|)
         string
         (op |.|)
         split
         (parens (group line) (group " ")))
        (group let hand (op =) Hand (parens (group hand_str)))
        (group
         Pair
         (parens
          (group hand)
          (group String (op |.|) to_number (parens (group bid)))))))))
    (group
     let
     sorted_cards
     (op =)
     cards
     (op |.|)
     sort
     (parens (group deck_lt)))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group
       each
       (block
        (group
         Pair
         (parens (group card) (group bid))
         (block (group sorted_cards)))
        (group i (block (group 1 (op ..))))))
      (group sum (op +) i (op *) bid)))))
  (group
   check
   (block
    (group calculate_result1 (parens (group test_input)))
    (group #:is 6440)))
  (group let result1 (block (group calculate_result1 (parens (group input)))))
  (group
   fun
   deck_lt_joker
   (parens
    (group ld (op ::) Pair (op |.|) of (parens (group Hand) (group Int)))
    (group rd (op ::) Pair (op |.|) of (parens (group Hand) (group Int))))
   (block
    (group
     let
     ld_score
     (op =)
     ld
     (op |.|)
     first
     (op |.|)
     score_with_jokers
     (parens))
    (group
     let
     rd_score
     (op =)
     rd
     (op |.|)
     first
     (op |.|)
     score_with_jokers
     (parens))
    (group
     cond
     (alts
      (block (group ld_score (op <) rd_score (block (group #t))))
      (block
       (group
        ld_score
        (op ==)
        rd_score
        (block
         (group
          card_list_lte
          (parens
           (group ld (op |.|) first (op |.|) chars)
           (group rd (op |.|) first (op |.|) chars))))))
      (block (group #:else (block (group #f))))))))
  (group
   fun
   calculate_result2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     cards
     (block
      (group
       for
       List
       (parens
        (group
         line
         (block
          (group
           utils
           (op |.|)
           string
           (op |.|)
           split_lines
           (parens (group raw_input))))))
       (block
        (group
         let
         (brackets (group hand_str) (group bid))
         (op =)
         utils
         (op |.|)
         string
         (op |.|)
         split
         (parens (group line) (group " ")))
        (group let hand (op =) Hand (parens (group hand_str) (group #t)))
        (group
         Pair
         (parens
          (group hand)
          (group String (op |.|) to_number (parens (group bid)))))))))
    (group
     let
     sorted_cards
     (op =)
     cards
     (op |.|)
     sort
     (parens (group deck_lt_joker)))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group
       each
       (block
        (group
         Pair
         (parens (group card) (group bid))
         (block (group sorted_cards)))
        (group i (block (group 1 (op ..))))))
      (group sum (op +) i (op *) bid)))))
  (group
   check
   (block
    (group calculate_result2 (parens (group test_input)))
    (group #:is 5905)))
  (group let result2 (block (group calculate_result2 (parens (group input))))))
