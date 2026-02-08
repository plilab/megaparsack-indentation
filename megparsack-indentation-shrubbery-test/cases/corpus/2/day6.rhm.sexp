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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 6)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block (group "Time:      7  15   30") (group "Distance:  9  40  200")))))
  (group let raw_input (block (group test_input)))
  (group
   fun
   solve_quadratic
   (parens (group a) (group b) (group c))
   (block
    (group
     values
     (parens
      (group
       (parens
        (group
         (op -)
         b
         (op +)
         math
         (op |.|)
         sqrt
         (parens (group b (op *) b (op -) 4 (op *) a (op *) c))))
       (op /)
       (parens (group 2 (op *) a)))
      (group
       (parens
        (group
         (op -)
         b
         (op -)
         math
         (op |.|)
         sqrt
         (parens (group b (op *) b (op -) 4 (op *) a (op *) c))))
       (op /)
       (parens (group 2 (op *) a)))))))
  (group let time (op =) 7)
  (group let res (op =) 9)
  (group
   fun
   count_solutions
   (parens (group time) (group res))
   (block
    (group
     let
     values
     (parens (group p1) (group p2))
     (op =)
     solve_quadratic
     (parens (group 1) (group (op -) time) (group res)))
    (group
     let
     min
     (op =)
     racket
     (op |.|)
     floor
     (parens
      (group
       racket
       (op |.|)
       max
       (parens
        (group racket (op |.|) min (parens (group p1) (group p2)))
        (group 0))
       (op +)
       1)))
    (group
     let
     max
     (op =)
     racket
     (op |.|)
     ceiling
     (parens
      (group
       racket
       (op |.|)
       max
       (parens
        (group racket (op |.|) max (parens (group p1) (group p2)))
        (group 0))
       (op -)
       1)))
    (group max (op -) min (op +) 1)))
  (group
   fun
   extract_times
   (parens (group str))
   (block
    (group
     let
     (brackets (group "Time") (group times))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group str) (group ":")))))
    (group
     let
     (brackets (group time) (group (op ...)))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group times) (group " ")))))
    (group
     (brackets
      (group String (op |.|) to_number (parens (group time)))
      (group (op ...))))))
  (group
   fun
   extract_distances
   (parens (group str))
   (block
    (group
     let
     (brackets (group "Distance") (group distances))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group str) (group ":")))))
    (group
     let
     (brackets (group distance) (group (op ...)))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group distances) (group " ")))))
    (group
     (brackets
      (group String (op |.|) to_number (parens (group distance)))
      (group (op ...))))))
  (group
   fun
   parse_input
   (parens (group raw_input))
   (block
    (group
     match
     utils
     (op |.|)
     string
     (op |.|)
     split_lines
     (parens (group raw_input))
     (alts
      (block
       (group
        (brackets (group times) (group distances))
        (block
         (group
          let
          (brackets (group time) (group (op ...)))
          (block (group extract_times (parens (group times)))))
         (group
          let
          (brackets (group dist) (group (op ...)))
          (block (group extract_distances (parens (group distances)))))
         (group
          (brackets
           (group Pair (parens (group time) (group dist)))
           (group (op ...)))))))))))
  (group
   fun
   solve_for_part1
   (parens (group raw_input))
   (block
    (group
     let
     (brackets
      (group Pair (parens (group time) (group dist)))
      (group (op ...)))
     (block (group parse_input (parens (group raw_input)))))
    (group
     let
     solutions
     (block
      (group
       (brackets
        (group count_solutions (parens (group time) (group dist)))
        (group (op ...))))))
    (group
     math
     (op |.|)
     exact
     (parens (group racket (op |.|) * (parens (group (op &) solutions)))))))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input)))
    (group #:is 288)))
  (group
   fun
   extract_times2
   (parens (group str))
   (block
    (group
     let
     (brackets (group "Time") (group times))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group str) (group ":")))))
    (group
     let
     (brackets (group time) (group (op ...)))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group times) (group " ")))))
    (group
     String
     (op |.|)
     to_number
     (parens
      (group
       utils
       (op |.|)
       string
       (op |.|)
       join
       (parens (group time) (group (op ...))))))))
  (group
   fun
   extract_distances2
   (parens (group str))
   (block
    (group
     let
     (brackets (group "Distance") (group distances))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group str) (group ":")))))
    (group
     let
     (brackets (group distance) (group (op ...)))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group distances) (group " ")))))
    (group
     String
     (op |.|)
     to_number
     (parens
      (group
       utils
       (op |.|)
       string
       (op |.|)
       join
       (parens (group distance) (group (op ...))))))))
  (group
   fun
   parse_input2
   (parens (group raw_input))
   (block
    (group
     match
     utils
     (op |.|)
     string
     (op |.|)
     split_lines
     (parens (group raw_input))
     (alts
      (block
       (group
        (brackets (group times) (group distances))
        (block
         (group let time (block (group extract_times2 (parens (group times)))))
         (group
          let
          dist
          (block (group extract_distances2 (parens (group distances)))))
         (group Pair (parens (group time) (group dist))))))))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input))
   (block
    (group
     let
     Pair
     (parens (group time) (group dist))
     (block (group parse_input2 (parens (group raw_input)))))
    (group
     let
     solutions
     (block (group count_solutions (parens (group time) (group dist)))))
    (group math (op |.|) exact (parens (group solutions)))))
  (group
   check
   (block
    (group solve_for_part2 (parens (group test_input)))
    (group #:is 71503)))
  (group let result2 (block (group solve_for_part2 (parens (group input))))))
