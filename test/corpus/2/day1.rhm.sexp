'(multi
  (group
   import
   (block
    (group file (parens (group "./utils/aoc_api.rhm")))
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
        (group string-split as split)))))))
  (group
   def
   input
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 1)))))
  (group
   def
   lines
   (block (group string (op |.|) split (parens (group input) (group "\n")))))
  (group
   fun
   String
   (op |.|)
   index_of_first_digit
   (parens (group str))
   (block
    (group
     for
     values
     (parens (group res (op =) #f) (group digit (op =) #f))
     (block
      (group
       each
       (block
        (group i (block (group 0 (op ..))))
        (group char (block (group str)))))
      (group final_when Char (op |.|) is_numeric (parens (group char)))
      (group values (parens (group i) (group char)))))))
  (group
   fun
   String
   (op |.|)
   first_digit
   (parens (group str))
   (block
    (group
     for
     values
     (parens (group res (op =) #f))
     (block
      (group each char (block (group str)))
      (group final_when Char (op |.|) is_numeric (parens (group char)))
      (group char)))))
  (group
   fun
   String
   (op |.|)
   index_of_last_digit
   (parens (group str))
   (block
    (group
     for
     values
     (parens (group res (op =) #f) (group digit (op =) #f))
     (block
      (group each i (block (group 0 (op ..) str (op |.|) length (parens))))
      (group
       def
       ind
       (block (group str (op |.|) length (parens) (op -) i (op -) 1)))
      (group def char (block (group str (brackets (group ind)))))
      (group final_when Char (op |.|) is_numeric (parens (group char)))
      (group values (parens (group ind) (group char)))))))
  (group
   fun
   String
   (op |.|)
   last_digit
   (parens (group str))
   (block
    (group
     for
     values
     (parens (group res (op =) #f))
     (block
      (group each i (block (group 0 (op ..) str (op |.|) length (parens))))
      (group
       def
       char
       (block
        (group
         str
         (brackets (group str (op |.|) length (parens) (op -) i (op -) 1)))))
      (group final_when Char (op |.|) is_numeric (parens (group char)))
      (group char)))))
  (group
   def
   result_day1
   (block
    (group
     for
     values
     (parens (group sum (op =) 0))
     (parens (group line (block (group lines))))
     (block
      (group
       def
       first_char
       (block (group String (op |.|) first_digit (parens (group line)))))
      (group
       def
       last_char
       (block (group String (op |.|) last_digit (parens (group line)))))
      (group
       sum
       (op +)
       String
       (op |.|)
       to_number
       (parens (group first_char (op +&) last_char)))))))
  (group
   fun
   (alts
    (block
     (group numeric_digit_to_string (parens (group "one")) (block (group 1))))
    (block
     (group numeric_digit_to_string (parens (group "two")) (block (group 2))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "three"))
      (block (group 3))))
    (block
     (group numeric_digit_to_string (parens (group "four")) (block (group 4))))
    (block
     (group numeric_digit_to_string (parens (group "five")) (block (group 5))))
    (block
     (group numeric_digit_to_string (parens (group "six")) (block (group 6))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "seven"))
      (block (group 7))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "eight"))
      (block (group 8))))
    (block
     (group numeric_digit_to_string (parens (group "nine")) (block (group 9))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "twone"))
      (block
       (group
        Pair
        (parens (group 3) (group (brackets (group 2) (group 1))))))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "oneight"))
      (block
       (group
        Pair
        (parens (group 3) (group (brackets (group 1) (group 8))))))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "threeight"))
      (block
       (group
        Pair
        (parens (group 5) (group (brackets (group 3) (group 8))))))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "fiveight"))
      (block
       (group
        Pair
        (parens (group 4) (group (brackets (group 5) (group 8))))))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "nineight"))
      (block
       (group
        Pair
        (parens (group 4) (group (brackets (group 9) (group 8))))))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "sevenine"))
      (block
       (group
        Pair
        (parens (group 5) (group (brackets (group 7) (group 9))))))))
    (block
     (group
      numeric_digit_to_string
      (parens (group "eightwo"))
      (block
       (group
        Pair
        (parens (group 5) (group (brackets (group 8) (group 2))))))))))
  (group
   def
   numeric_digit
   (block
    (group
     "twone|oneight|threeight|fiveight|nineight|sevenine|eightwo|one|two|three|four|five|six|seven|eight|nine")))
  (group
   fun
   String
   (op |.|)
   numeric_digits
   (parens (group str))
   (block
    (group
     for
     List
     (block
      (group
       each
       Pair
       (parens (group st) (group end))
       (block
        (group
         racket
         (op |.|)
         regexp-match-positions*
         (parens
          (group racket (op |.|) regexp (parens (group numeric_digit)))
          (group str)))))
      (group
       def
       digit
       (block
        (group
         numeric_digit_to_string
         (parens
          (group
           String
           (op |.|)
           substring
           (parens (group str) (group st) (group end)))))))
      (group
       each
       pair
       (block
        (group
         match
         digit
         (alts
          (block
           (group
            n
            (op ::)
            Number
            (block
             (group
              (brackets (group Pair (parens (group st) (group digit))))))))
          (block
           (group
            Pair
            (parens (group offset) (group (brackets (group d1) (group d2))))
            (op ::)
            Pair
            (block
             (group
              (brackets
               (group Pair (parens (group st) (group d1)))
               (group
                Pair
                (parens (group st (op +) offset) (group d2))))))))))))
      (group pair)))))
  (group
   def
   lines2
   (block (group (brackets (group "fiveightjlkfmtwoseventhreeoneightbsr")))))
  (group
   def
   result_day2
   (block
    (group
     for
     values
     (parens (group sum (op =) 0))
     (parens (group str (block (group lines))))
     (block
      (group
       def
       digits
       (block (group String (op |.|) numeric_digits (parens (group str)))))
      (group
       def
       first_digit
       (block
        (group
         def
         values
         (parens (group i) (group digit))
         (block
          (group String (op |.|) index_of_first_digit (parens (group str)))))
        (group
         for
         values
         (parens (group min_digit (op =) digit))
         (block
          (group
           each
           Pair
           (parens (group st) (group digit))
           (block (group digits)))
          (group break_when i (op <) st)
          (group final_when st (op <) i)
          (group values (parens (group digit)))))))
      (group
       def
       last_digit
       (block
        (group
         def
         values
         (parens (group i) (group digit))
         (block
          (group String (op |.|) index_of_last_digit (parens (group str)))))
        (group
         for
         values
         (parens (group max_digit (op =) digit))
         (block
          (group
           each
           Pair
           (parens (group st) (group digit))
           (block (group digits)))
          (group skip_when st (op <) i)
          (group values (parens (group digit)))))))
      (group
       sum
       (op +)
       String
       (op |.|)
       to_number
       (parens (group first_digit (op +&) last_digit))))))))
