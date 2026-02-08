'(multi
  (group
   import
   (block
    (group file (parens (group "./utils/aoc_api.rhm")))
    (group file (parens (group "./utils/utils.rhm")))
    (group file (parens (group "./utils/lang.rhm")) open)
    (group
     meta
     (block (group lib (parens (group "racket/syntax.rkt")) as syntax)))
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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 13)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "#.##..##.")
      (group "..#.##.#.")
      (group "##......#")
      (group "##......#")
      (group "..#.##.#.")
      (group "..##..##.")
      (group "#.#.##.#.")
      (group "")
      (group "#...##..#")
      (group "#....#..#")
      (group "..##..###")
      (group "#####.##.")
      (group "#####.##.")
      (group "..##..###")
      (group "#....#..#")))))
  (group
   defn
   (op |.|)
   macro
   (quotes
    (group
     fun_cached
     (op $)
     (parens (group f (op ::) Identifier))
     (parens (group (op $) this) (group (op $) arg) (group (op ...)))
     using
     cache
     (op $)
     (parens (group cache))
     (block (group (op $) body) (group (op ...)))))
   (block
    (group
     let
     f_inner
     (op =)
     syntax
     (op |.|)
     format-id
     (parens (group (quotes (group here))) (group "~a_inner") (group f)))
    (group
     let
     f_cache
     (op =)
     syntax
     (op |.|)
     format-id
     (parens (group (quotes (group here))) (group "~a_cache") (group f)))
    (group
     (quotes
      (group
       block
       (block
        (group
         fun
         (op $)
         f_inner
         (parens (group (op $) this) (group (op $) arg) (group (op ...)))
         (block (group (op $) body) (group (op ...))))
        (group
         fun
         (op $)
         f
         (parens (group (op $) this) (group (op $) arg) (group (op ...)))
         (block
          (group let (op $) f_cache (block (group (op $) cache)))
          (group let elt (op =) (brackets (group (op $) arg) (group (op ...))))
          (group
           if
           (op $)
           (parens (group f_cache))
           (op |.|)
           has_key
           (parens (group elt))
           (alts
            (block
             (group (op $) (parens (group f_cache)) (brackets (group elt))))
            (block
             (group
              let
              result
              (op =)
              (op $)
              f_inner
              (parens (group (op $) this) (group (op $) arg) (group (op ...))))
             (group
              (op $)
              (parens (group f_cache))
              (brackets (group elt))
              (op :=)
              result)
             (group result))))))
        (group (op $) f)))))))
  (group
   fun
   smudge_equal
   (parens
    (group s1)
    (group s2)
    (group
     #:equal
     (block
      (group
       equal
       (op =)
       fun
       (parens (group a) (group b))
       (block (group a (op ==) b))))))
   (block
    (group
     for
     values
     (parens (group no_different (op =) 0))
     (block
      (group
       each
       (block
        (group s1_elt (block (group s1)))
        (group s2_elt (block (group s2)))))
      (group break_when no_different (op >) 1)
      (group
       if
       (op !)
       equal
       (parens (group s1_elt) (group s2_elt))
       (alts
        (block (group no_different (op +) 1))
        (block (group no_different))))))))
  (group
   class
   Pattern
   (parens
    (group s (op ::) List (op |.|) of (parens (group ReadableString)))
    (group col_cache)
    (group row_cache)
    (group col_smudge_cache)
    (group row_smudge_cache))
   (block
    (group
     constructor
     (parens (group s (op ::) ReadableString))
     (block
      (group
       super
       (parens
        (group utils (op |.|) string (op |.|) split_lines (parens (group s)))
        (group MutableMap (parens))
        (group MutableMap (parens))
        (group MutableMap (parens))
        (group MutableMap (parens))))))
    (group method rows (parens) (block (group s (op |.|) length (parens))))
    (group
     method
     cols
     (parens)
     (block (group s (brackets (group 0)) (op |.|) length (parens))))
    (group
     field
     column_smudge_equal
     (block
      (group
       fun_cached
       column_equal
       (parens (group this) (group i) (group j))
       using
       cache
       (parens (group this (op |.|) col_smudge_cache))
       (block
        (group
         for
         values
         (parens (group no_diff (op =) 0))
         (parens (group line (block (group this (op |.|) s))))
         (block
          (group
           skip_when
           line
           (brackets (group i))
           (op ==)
           line
           (brackets (group j)))
          (group break_when no_diff (op >) 1)
          (group
           if
           line
           (brackets (group i))
           (op !=)
           line
           (brackets (group j))
           (alts
            (block (group no_diff (op +) 1))
            (block (group no_diff))))))))))
    (group
     field
     column_equal
     (block
      (group
       fun_cached
       column_equal
       (parens (group this) (group i) (group j))
       using
       cache
       (parens (group this (op |.|) col_cache))
       (block
        (group
         for
         values
         (parens (group result (op =) #t))
         (parens (group line (block (group this (op |.|) s))))
         (block
          (group
           skip_when
           line
           (brackets (group i))
           (op ==)
           line
           (brackets (group j)))
          (group break_when (op !) result)
          (group
           line
           (brackets (group i))
           (op ==)
           line
           (brackets (group j)))))))))
    (group
     field
     row_smudge_equal
     (block
      (group
       fun_cached
       row_equal
       (parens (group this) (group i) (group j))
       using
       cache
       (parens (group this (op |.|) row_smudge_cache))
       (block
        (group
         smudge_equal
         (parens
          (group this (op |.|) s (brackets (group i)))
          (group this (op |.|) s (brackets (group j)))))))))
    (group
     field
     row_equal
     (block
      (group
       fun_cached
       row_equal
       (parens (group this) (group i) (group j))
       using
       cache
       (parens (group this (op |.|) row_cache))
       (block
        (group
         racket
         (op |.|)
         equal?
         (parens
          (group this (op |.|) s (brackets (group i)))
          (group this (op |.|) s (brackets (group j)))))))))
    (group
     method
     is_reflected_smudged_row
     (parens (group row (op ::) Int))
     (block
      (group
       let
       init_offset
       (op =)
       math
       (op |.|)
       min
       (parens (group rows (parens) (op -) 1 (op -) row (op -) 1) (group row)))
      (group
       let
       no_diff
       (block
        (group
         recur
         is_reflected
         (parens (group offset (op =) init_offset) (group no_diff (op =) 0))
         (block
          (group
           cond
           (alts
            (block (group no_diff (op >) 1 (block (group no_diff))))
            (block
             (group
              offset
              (op ==)
              0
              (block
               (group
                no_diff
                (op +)
                row_smudge_equal
                (parens (group this) (group row) (group row (op +) 1))))))
            (block
             (group
              #:else
              (block
               (group
                let
                smudge_diff
                (op =)
                row_smudge_equal
                (parens
                 (group this)
                 (group row (op -) offset)
                 (group row (op +) 1 (op +) offset)))
               (group
                is_reflected
                (parens
                 (group offset (op -) 1)
                 (group no_diff (op +) smudge_diff))))))))))))
      (group
       if
       no_diff
       (op ==)
       1
       (alts (block (group #t)) (block (group #f))))))
    (group
     method
     is_reflected_row
     (parens (group row (op ::) Int))
     (block
      (group
       let
       init_offset
       (op =)
       math
       (op |.|)
       min
       (parens (group rows (parens) (op -) 1 (op -) row (op -) 1) (group row)))
      (group
       recur
       is_reflected
       (parens (group offset (op =) init_offset))
       (block
        (group
         cond
         (alts
          (block
           (group
            offset
            (op ==)
            0
            (block
             (group
              row_equal
              (parens (group this) (group row) (group row (op +) 1))))))
          (block
           (group
            row_equal
            (parens
             (group this)
             (group row (op -) offset)
             (group row (op +) 1 (op +) offset))
            (block (group is_reflected (parens (group offset (op -) 1))))))
          (block (group #:else (block (group #f))))))))))
    (group
     method
     is_reflected_smudged_col
     (parens (group col (op ::) Int))
     (block
      (group
       let
       init_offset
       (op =)
       math
       (op |.|)
       min
       (parens (group cols (parens) (op -) 1 (op -) col (op -) 1) (group col)))
      (group
       let
       no_diff
       (block
        (group
         recur
         is_reflected
         (parens (group offset (op =) init_offset) (group no_diff (op =) 0))
         (block
          (group
           cond
           (alts
            (block (group no_diff (op >) 1 (block (group no_diff))))
            (block
             (group
              offset
              (op ==)
              0
              (block
               (group
                no_diff
                (op +)
                column_smudge_equal
                (parens (group this) (group col) (group col (op +) 1))))))
            (block
             (group
              #:else
              (block
               (group
                let
                smudge_diff
                (op =)
                column_smudge_equal
                (parens
                 (group this)
                 (group col (op -) offset)
                 (group col (op +) 1 (op +) offset)))
               (group
                is_reflected
                (parens
                 (group offset (op -) 1)
                 (group no_diff (op +) smudge_diff))))))))))))
      (group
       if
       no_diff
       (op ==)
       1
       (alts (block (group #t)) (block (group #f))))))
    (group
     method
     is_reflected_col
     (parens (group col (op ::) Int))
     (block
      (group
       let
       init_offset
       (op =)
       math
       (op |.|)
       min
       (parens (group cols (parens) (op -) 1 (op -) col (op -) 1) (group col)))
      (group
       recur
       is_reflected
       (parens (group offset (op =) init_offset))
       (block
        (group
         cond
         (alts
          (block
           (group
            offset
            (op ==)
            0
            (block
             (group
              column_equal
              (parens (group this) (group col) (group col (op +) 1))))))
          (block
           (group
            column_equal
            (parens
             (group this)
             (group col (op -) offset)
             (group col (op +) 1 (op +) offset))
            (block (group is_reflected (parens (group offset (op -) 1))))))
          (block (group #:else (block (group #f))))))))))
    (group
     method
     find_smudged_rows
     (parens)
     (block
      (group
       for
       List
       (parens (group row (block (group 0 (op ..) rows (parens) (op -) 1))))
       (block
        (group keep_when is_reflected_smudged_row (parens (group row)))
        (group final_when is_reflected_smudged_row (parens (group row)))
        (group row (op +) 1)))))
    (group
     method
     find_reflected_rows
     (parens)
     (block
      (group
       for
       List
       (parens (group row (block (group 0 (op ..) rows (parens) (op -) 1))))
       (block
        (group keep_when is_reflected_row (parens (group row)))
        (group row (op +) 1)))))
    (group
     method
     find_smudged_cols
     (parens)
     (block
      (group
       for
       List
       (parens (group col (block (group 0 (op ..) cols (parens) (op -) 1))))
       (block
        (group keep_when is_reflected_smudged_col (parens (group col)))
        (group final_when is_reflected_smudged_col (parens (group col)))
        (group col (op +) 1)))))
    (group
     method
     find_reflected_cols
     (parens)
     (block
      (group
       for
       List
       (parens (group col (block (group 0 (op ..) cols (parens) (op -) 1))))
       (block
        (group keep_when is_reflected_col (parens (group col)))
        (group col (op +) 1)))))
    (group
     method
     summarise_cols
     (parens)
     (block
      (group
       (parens
        (group
         for
         values
         (parens (group sum (op =) 0))
         (parens (group col (block (group find_reflected_cols (parens)))))
         (block (group sum (op +) col)))))))
    (group
     method
     summarise_rows
     (parens)
     (block
      (group
       (parens
        (group
         for
         values
         (parens (group sum (op =) 0))
         (parens (group row (block (group find_reflected_rows (parens)))))
         (block (group sum (op +) row (op *) 100)))))))
    (group
     method
     summarise
     (parens)
     (block (group summarise_cols (parens) (op +) summarise_rows (parens))))
    (group
     method
     summarise_smudged_cols
     (parens)
     (block
      (group
       (parens
        (group
         for
         values
         (parens (group sum (op =) 0))
         (parens (group col (block (group find_smudged_cols (parens)))))
         (block (group sum (op +) col)))))))
    (group
     method
     summarise_smudged_rows
     (parens)
     (block
      (group
       (parens
        (group
         for
         values
         (parens (group sum (op =) 0))
         (parens (group row (block (group find_smudged_rows (parens)))))
         (block (group sum (op +) row (op *) 100)))))))
    (group
     method
     summarise_smudged
     (parens)
     (block
      (group
       summarise_smudged_cols
       (parens)
       (op +)
       summarise_smudged_rows
       (parens))))))
  (group
   fun
   parse_input
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     (brackets (group pat) (group (op ...)))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group raw_input) (group "\n\n")))))
    (group (brackets (group Pattern (parens (group pat))) (group (op ...))))))
  (group
   fun
   solve_for_part1
   (parens (group raw_input))
   (block
    (group
     def
     (brackets (group pat) (group (op ...)))
     (block (group parse_input (parens (group raw_input)))))
    (group
     math
     (op |.|)
     sum
     (parens (group pat (op |.|) summarise (parens)) (group (op ...))))))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input)))
    (group #:is 405)))
  (group def result1 (block (group solve_for_part1 (parens (group input)))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input))
   (block
    (group
     def
     (brackets (group pat) (group (op ...)))
     (block (group parse_input (parens (group raw_input)))))
    (group
     math
     (op |.|)
     sum
     (parens
      (group pat (op |.|) summarise_smudged (parens))
      (group (op ...))))))
  (group
   check
   (block
    (group solve_for_part2 (parens (group test_input)))
    (group #:is 400)))
  (group solve_for_part2 (parens (group input))))
