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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 4)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53")
      (group "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19")
      (group "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1")
      (group "Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83")
      (group "Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36")
      (group "Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11")))))
  (group
   class
   Card
   (parens
    (group id (op ::) Int)
    (group goal (op ::) Set (op |.|) of (parens (group Int)))
    (group current (op ::) Set (op |.|) of (parens (group Int))))
   (block
    (group
     method
     count_matching
     (parens)
     (block
      (group
       goal
       (op |.|)
       intersect
       (parens (group current))
       (op |.|)
       length
       (parens))))
    (group
     method
     calculate_score
     (parens)
     (block
      (group let no_matching (block (group count_matching (parens))))
      (group
       if
       no_matching
       (op >)
       0
       (alts
        (block
         (group
          math
          (op |.|)
          expt
          (parens (group 2) (group no_matching (op -) 1))))
        (block (group 0))))))))
  (group
   fun
   parse_card_id
   (parens (group card (op ::) String))
   (block
    (group
     match
     utils
     (op |.|)
     string
     (op |.|)
     split
     (parens (group card) (group " "))
     (alts
      (block
       (group
        (brackets (group "Card") (group id))
        (block (group String (op |.|) to_number (parens (group id))))))
      (block
       (group
        other
        (block
         (group
          racket
          (op |.|)
          error
          (parens (group "invalid input") (group other))))))))))
  (group
   fun
   parse_int_list
   (parens (group ls (op ::) String))
   (block
    (group
     for
     List
     (block
      (group
       each
       num_str
       (block
        (group
         utils
         (op |.|)
         string
         (op |.|)
         split
         (parens (group ls) (group " ")))))
      (group def num (op =) String (op |.|) to_number (parens (group num_str)))
      (group skip_when (op !) num)
      (group num)))))
  (group
   fun
   parse_card_desc
   (parens (group desc (op ::) String))
   (block
    (group
     match
     utils
     (op |.|)
     string
     (op |.|)
     split
     (parens (group desc) (group "|"))
     (alts
      (block
       (group
        (brackets (group raw_goal) (group raw_have))
        (block
         (group let goal (op =) parse_int_list (parens (group raw_goal)))
         (group let have (op =) parse_int_list (parens (group raw_have)))
         (group values (parens (group goal) (group have))))))))))
  (group
   fun
   parse_input
   (parens (group input (op ::) ReadableString))
   (block
    (group
     for
     List
     (block
      (group
       each
       raw_line
       (block
        (group
         utils
         (op |.|)
         string
         (op |.|)
         split_lines
         (parens (group input)))))
      (group let line (op =) raw_line (op |.|) to_string (parens))
      (group
       match
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group line) (group ":"))
       (alts
        (block
         (group
          (brackets (group card) (group desc))
          (block
           (group let id (op =) parse_card_id (parens (group card)))
           (group
            let
            values
            (parens (group goal) (group have))
            (op =)
            parse_card_desc
            (parens (group desc)))
           (group
            Card
            (parens
             (group id)
             (group utils (op |.|) set (op |.|) of_list (parens (group goal)))
             (group
              utils
              (op |.|)
              set
              (op |.|)
              of_list
              (parens (group have))))))))))))))
  (group
   fun
   calculate_result1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group let cards (block (group parse_input (parens (group raw_input)))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (parens (group card (block (group cards))))
     (block
      (group let count (block (group card (op |.|) calculate_score (parens))))
      (group sum (op +) count)))))
  (group
   check
   (block
    (group calculate_result1 (parens (group test_input)))
    (group #:is 13)))
  (group let result1 (op =) calculate_result1 (parens (group input)))
  (group
   fun
   calculate_result2
   (parens (group raw_input))
   (block
    (group let cards (block (group parse_input (parens (group raw_input)))))
    (group
     let
     card_count
     (block
      (group
       Array
       (op |.|)
       make
       (parens (group cards (op |.|) length (parens)) (group 1)))))
    (group
     for
     (block
      (group
       each
       (block
        (group i (block (group 0 (op ..))))
        (group card (block (group cards)))))
      (group
       let
       current_card_count
       (block (group card_count (brackets (group i)))))
      (group let no_matching (op =) card (op |.|) count_matching (parens))
      (group
       for
       (block
        (group
         each
         j
         (block (group i (op +) 1 (op ..) i (op +) no_matching (op +) 1)))
        (group
         card_count
         (brackets (group j))
         (op :=)
         card_count
         (brackets (group j))
         (op +)
         current_card_count)))))
    (group utils (op |.|) array (op |.|) sum (parens (group card_count)))))
  (group
   check
   (block
    (group calculate_result2 (parens (group test_input)))
    (group #:is 30)))
  (group let result2 (op =) calculate_result2 (parens (group input))))
