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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 9)))))
  (group
   let
   test_input
   (block
    (group
     multiline
     (block
      (group "0 3 6 9 12 15")
      (group "1 3 6 10 15 21")
      (group "10 13 16 21 30 45")))))
  (group
   fun
   parse_line
   (parens (group line (op ::) ReadableString))
   (block
    (group
     String
     (op |.|)
     to_number
     (op |.|)
     map
     (parens
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group line) (group " ")))))))
  (group
   fun
   differences
   (parens
    (group
     List
     (op |.|)
     cons
     (parens (group hd) (group ls))
     (op ::)
     List
     (op |.|)
     of
     (parens (group Int))))
   (block
    (group let mutable prev (op =) hd)
    (group
     for
     List
     (block
      (group each elt (block (group ls)))
      (group let vl (op =) elt (op -) prev)
      (group prev (op :=) elt)
      (group vl)))))
  (group
   fun
   (alts
    (block
     (group
      List
      (op |.|)
      last
      (parens
       (group List (op |.|) cons (parens (group hd) (group (brackets)))))
      (block (group hd))))
    (block
     (group
      List
      (op |.|)
      last
      (parens (group List (op |.|) cons (parens (group _) (group tail))))
      (block (group List (op |.|) last (parens (group tail))))))))
  (group
   fun
   (alts
    (block
     (group
      List
      (op |.|)
      is_empty
      (parens (group (brackets)))
      (block (group #t))))
    (block
     (group
      List
      (op |.|)
      is_empty
      (parens (group List (op |.|) cons (parens (group _) (group _))))
      (block (group #f))))))
  (group
   fun
   all_equal
   (parens (group ls (op ::) List (op |.|) of (parens (group Int))))
   (block
    (group
     let
     values
     (parens (group _) (group all_equal))
     (block
      (group
       for
       values
       (parens (group prev_vl (op =) #f) (group all_equal (op =) #t))
       (block
        (group each elt (block (group ls)))
        (group break_when (op !) all_equal)
        (group let prev_vl (block (group prev_vl (op \|\|) elt)))
        (group values (parens (group elt) (group prev_vl (op ==) elt)))))))
    (group all_equal)))
  (group
   check
   (block
    (group all_equal (parens (group (brackets (group 1) (group 2) (group 3)))))
    (group #:is #f)))
  (group
   check
   (block
    (group all_equal (parens (group (brackets (group 1) (group 1) (group 1)))))
    (group #:is #t)))
  (group
   fun
   parse
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     parse_line
     (op |.|)
     map
     (parens
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split_lines
       (parens (group raw_input)))))))
  (group
   fun
   predict_next_element
   (parens (group sequence (op ::) List (op |.|) of (parens (group Int))))
   (block
    (group let mutable diffs (block (group (brackets (group sequence)))))
    (group
     while
     (op !)
     all_equal
     (parens (group List (op |.|) first (parens (group diffs))))
     (block
      (group
       diffs
       (op :=)
       List
       (op |.|)
       cons
       (parens
        (group
         differences
         (parens (group List (op |.|) first (parens (group diffs)))))
        (group diffs)))))
    (group
     let
     List
     (op |.|)
     cons
     (parens (group all_equal) (group remaining_diffs))
     (block (group diffs)))
    (group
     let
     mutable
     diff
     (block (group List (op |.|) first (parens (group all_equal)))))
    (group diffs (op :=) remaining_diffs)
    (group
     while
     (op !)
     List
     (op |.|)
     is_empty
     (parens (group diffs))
     (block
      (group
       let
       List
       (op |.|)
       cons
       (parens (group sequence) (group remaining_diffs))
       (block (group diffs)))
      (group
       let
       last_element
       (op =)
       List
       (op |.|)
       last
       (parens (group sequence)))
      (group diff (op :=) last_element (op +) diff)
      (group diffs (op :=) remaining_diffs)))
    (group diff)))
  (group
   fun
   predict_prev_element
   (parens (group sequence (op ::) List (op |.|) of (parens (group Int))))
   (block
    (group let mutable diffs (block (group (brackets (group sequence)))))
    (group
     while
     (op !)
     all_equal
     (parens (group List (op |.|) first (parens (group diffs))))
     (block
      (group
       diffs
       (op :=)
       List
       (op |.|)
       cons
       (parens
        (group
         differences
         (parens (group List (op |.|) first (parens (group diffs)))))
        (group diffs)))))
    (group
     let
     List
     (op |.|)
     cons
     (parens (group all_equal) (group remaining_diffs))
     (block (group diffs)))
    (group
     let
     mutable
     diff
     (block (group List (op |.|) first (parens (group all_equal)))))
    (group diffs (op :=) remaining_diffs)
    (group
     while
     (op !)
     List
     (op |.|)
     is_empty
     (parens (group diffs))
     (block
      (group
       let
       List
       (op |.|)
       cons
       (parens (group sequence) (group remaining_diffs))
       (block (group diffs)))
      (group
       let
       first_element
       (op =)
       List
       (op |.|)
       first
       (parens (group sequence)))
      (group diff (op :=) first_element (op -) diff)
      (group diffs (op :=) remaining_diffs)))
    (group diff)))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group let lines (block (group parse (parens (group raw_input)))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each line (block (group lines)))
      (group sum (op +) predict_next_element (parens (group line)))))))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input)))
    (group #:is 114)))
  (group let result1 (block (group solve_for_part1 (parens (group input)))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group let lines (block (group parse (parens (group raw_input)))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each line (block (group lines)))
      (group
       let
       prev_element
       (block (group predict_prev_element (parens (group line)))))
      (group sum (op +) prev_element)))))
  (group
   check
   (block (group solve_for_part2 (parens (group test_input))) (group #:is 2)))
  (group let result2 (block (group solve_for_part2 (parens (group input))))))
