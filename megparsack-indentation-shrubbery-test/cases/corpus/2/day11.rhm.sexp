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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 11)))))
  (group
   def
   test_input1
   (block
    (group
     multiline
     (block
      (group "...#......")
      (group ".......#..")
      (group "#.........")
      (group "..........")
      (group "......#...")
      (group ".#........")
      (group ".........#")
      (group "..........")
      (group ".......#..")
      (group "#...#.....")))))
  (group
   check
   (block
    (group
     utils
     (op |.|)
     List
     (op |.|)
     all
     (parens
      (group fun (parens (group x)) (block (group x (op ==) 1)))
      (group (brackets (group 1) (group 1) (group 1) (group 1) (group 1)))))
    (group #:is #t)))
  (group
   check
   (block
    (group
     utils
     (op |.|)
     List
     (op |.|)
     all
     (parens
      (group fun (parens (group x)) (block (group x (op ==) 1)))
      (group (brackets (group 1) (group 1) (group 1) (group 2) (group 1)))))
    (group #:is #f)))
  (group
   class
   List
   (op |.|)
   Indexed
   (parens (group ls (op ::) List))
   (block
    (group implements Sequenceable)
    (group
     override
     method
     to_sequence
     (parens)
     (block
      (group
       Sequence
       (op |.|)
       make
       (parens
        (group
         #:initial_position
         (block (group Pair (parens (group ls) (group 0)))))
        (group
         #:continue_at_position
         (block
          (group
           fun
           (alts
            (block
             (group
              (parens
               (group
                Pair
                (parens
                 (group List (op |.|) cons (parens (group _) (group _)))
                 (group _))))
              (block (group #t))))
            (block (group (parens (group _)) (block (group #f))))))))
        (group
         #:position_to_next
         (block
          (group
           fun
           (parens
            (group
             Pair
             (parens
              (group List (op |.|) cons (parens (group _) (group tail)))
              (group ind))))
           (block (group Pair (parens (group tail) (group ind (op +) 1)))))))
        (group
         #:position_to_element
         (block
          (group
           fun
           (parens
            (group
             Pair
             (parens
              (group List (op |.|) cons (parens (group hd) (group _)))
              (group ind))))
           (block (group values (parens (group ind) (group hd)))))))))))))
  (group
   fun
   (alts
    (block
     (group
      dup_elt
      (parens
       (group 0)
       (group (brackets (group hd) (group tail) (group (op ...)))))
      (block
       (group
        (brackets (group hd) (group hd) (group tail) (group (op ...)))))))
    (block
     (group
      dup_elt
      (parens
       (group ind)
       (group List (op |.|) cons (parens (group hd) (group tail))))
      (block
       (group
        List
        (op |.|)
        cons
        (parens
         (group hd)
         (group dup_elt (parens (group ind (op -) 1) (group tail))))))))))
  (group
   check
   (block
    (group
     dup_elt
     (parens
      (group 3)
      (group (brackets (group 1) (group 2) (group 3) (group 4)))))
    (group
     #:is
     (block
      (group (brackets (group 1) (group 2) (group 3) (group 4) (group 4)))))))
  (group
   check
   (block
    (group
     dup_elt
     (parens
      (group 2)
      (group (brackets (group 1) (group 2) (group 3) (group 4)))))
    (group
     #:is
     (block
      (group (brackets (group 1) (group 2) (group 3) (group 3) (group 4)))))))
  (group
   fun
   extract_points
   (parens (group lines))
   (block
    (group
     for
     List
     (block
      (group
       each
       values
       (parens (group j) (group row))
       (block (group List (op |.|) Indexed (parens (group lines)))))
      (group
       each
       values
       (parens (group i) (group char))
       (block (group List (op |.|) Indexed (parens (group row)))))
      (group keep_when char (op ==) #\#)
      (group utils (op |.|) Point (parens (group i) (group j)))))))
  (group
   fun
   (alts
    (block
     (group
      calculate_cost
      (parens (group ls))
      (block (group calculate_cost (parens (group 0) (group ls))))))
    (block
     (group
      calculate_cost
      (parens (group res) (group (brackets)))
      (block (group res))))
    (block
     (group
      calculate_cost
      (parens
       (group res)
       (group List (op |.|) cons (parens (group hd) (group tail))))
      (block
       (group
        def
        new_res
        (block
         (group
          for
          values
          (parens (group sum (op =) res))
          (block
           (group each other (block (group tail)))
           (group
            sum
            (op +)
            hd
            (op |.|)
            abs_manhatten_distance
            (parens (group other)))))))
       (group calculate_cost (parens (group new_res) (group tail))))))))
  (group
   fun
   parse_input
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     racket
     (op |.|)
     string->list
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
   calculate_rows_to_expand
   (parens
    (group
     lines
     (op ::)
     List
     (op |.|)
     of
     (parens (group List (op |.|) of (parens (group Char))))))
   (block
    (group
     for
     List
     (block
      (group
       each
       values
       (parens (group i) (group row))
       (block (group List (op |.|) Indexed (parens (group lines)))))
      (group
       skip_when
       (op !)
       utils
       (op |.|)
       List
       (op |.|)
       all
       (parens
        (group fun (parens (group c)) (block (group c (op ==) #\.)))
        (group row)))
      (group i)))))
  (group
   fun
   calculate_cols_to_expand
   (parens
    (group
     lines
     (op ::)
     List
     (op |.|)
     of
     (parens (group List (op |.|) of (parens (group Char))))))
   (block
    (group
     def
     col_length
     (block (group lines (brackets (group 0)) (op |.|) length (parens))))
    (group
     for
     List
     (block
      (group each j (block (group 0 (op ..) col_length)))
      (group
       keep_when
       (block
        (group
         for
         values
         (parens (group result (op =) #t))
         (block
          (group each row (block (group lines)))
          (group skip_when row (brackets (group j)) (op ==) #\.)
          (group final_when #t)
          (group row (brackets (group j)) (op ==) #\.)))))
      (group j)))))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group def lines (op =) parse_input (parens (group raw_input)))
    (group
     def
     rows_to_expand
     (block (group calculate_rows_to_expand (parens (group lines)))))
    (group
     def
     cols_to_expand
     (block (group calculate_cols_to_expand (parens (group lines)))))
    (group
     def
     lines_w_expanded_rows
     (block
      (group
       for
       values
       (parens (group ls (op =) lines))
       (block
        (group
         each
         row
         (block (group rows_to_expand (op |.|) reverse (parens))))
        (group dup_elt (parens (group row) (group ls)))))))
    (group
     def
     lines_expanded
     (block
      (group
       for
       values
       (parens (group ls (op =) lines_w_expanded_rows))
       (block
        (group
         each
         column
         (block (group cols_to_expand (op |.|) reverse (parens))))
        (group
         for
         List
         (block
          (group each row (block (group ls)))
          (group dup_elt (parens (group column) (group row)))))))))
    (group
     def
     points
     (block (group extract_points (parens (group lines_expanded)))))
    (group calculate_cost (parens (group points)))))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input1)))
    (group #:is 374)))
  (group def result1 (op =) solve_for_part1 (parens (group input)))
  (group
   fun
   solve_for_part2
   (parens
    (group raw_input (op ::) ReadableString)
    (group #:by (block (group by (op =) 1000000))))
   (block
    (group def lines (op =) parse_input (parens (group raw_input)))
    (group
     def
     rows_to_expand
     (block (group calculate_rows_to_expand (parens (group lines)))))
    (group
     def
     cols_to_expand
     (block (group calculate_cols_to_expand (parens (group lines)))))
    (group def points (block (group extract_points (parens (group lines)))))
    (group
     def
     expanded_points
     (block
      (group
       def
       MAX_ROWS
       (block (group rows_to_expand (op |.|) length (parens))))
      (group
       def
       MAX_COLS
       (block (group cols_to_expand (op |.|) length (parens))))
      (group
       for
       List
       (parens (group point (block (group points))))
       (block
        (group
         let
         mul_y
         (block
          (group
           utils
           (op |.|)
           List
           (op |.|)
           find_index
           (parens
            (group rows_to_expand)
            (group
             fun
             (parens (group y))
             (block (group point (op |.|) y (op <) y))))
           (op \|\|)
           MAX_ROWS)))
        (group
         let
         mul_x
         (block
          (group
           utils
           (op |.|)
           List
           (op |.|)
           find_index
           (parens
            (group cols_to_expand)
            (group
             fun
             (parens (group x))
             (block (group point (op |.|) x (op <) x))))
           (op \|\|)
           MAX_COLS)))
        (group
         utils
         (op |.|)
         Point
         (parens
          (group
           point
           (op |.|)
           x
           (op +)
           mul_x
           (op *)
           (parens (group by (op -) 1)))
          (group
           point
           (op |.|)
           y
           (op +)
           mul_y
           (op *)
           (parens (group by (op -) 1)))))))))
    (group calculate_cost (parens (group expanded_points)))))
  (group
   check
   (block
    (group
     solve_for_part2
     (parens (group test_input1) (group #:by (block (group 10)))))
    (group #:is 1030)))
  (group
   check
   (block
    (group
     solve_for_part2
     (parens (group test_input1) (group #:by (block (group 100)))))
    (group #:is 8410)))
  (group let result2 (op =) solve_for_part2 (parens (group input))))
