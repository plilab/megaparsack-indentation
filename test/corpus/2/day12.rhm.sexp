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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 12)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "???.### 1,1,3")
      (group ".??..??...?##. 1,1,3")
      (group "?#?#?#?#?#?#?#? 1,3,1,6")
      (group "????.#...#... 4,1,1")
      (group "????.######..#####. 1,6,5")
      (group "?###???????? 3,2,1")))))
  (group
   meta
   (block
    (group
     syntax_class
     Assignment
     (alts
      (block
       (group
        (quotes
         (group
          (op $)
          (parens (group var (op ::) Identifier))
          (op =)
          (op $)
          value
          (op ...)))))))))
  (group
   expr
   (op |.|)
   macro
   (quotes
    (group
     loop
     (op $)
     (parens (group f (op ::) Identifier))
     (parens
      (group (op $) (parens (group arg (op ::) Assignment)))
      (group (op ...)))
     (block (group (op $) body) (group (op ...)))))
   (block
    (group
     (quotes
      (group
       block
       (block
        (group
         fun
         (op $)
         f
         (parens (group (op $) arg (op |.|) var) (group (op ...)))
         (block (group (op $) body) (group (op ...))))
        (group
         (op $)
         f
         (parens
          (group (op $) arg (op |.|) value (op ...))
          (group (op ...))))))))))
  (group
   fun
   List
   (op |.|)
   mul_by_five
   (parens (group (brackets (group elt) (group (op ...)))))
   (block
    (group
     (brackets
      (group elt)
      (group (op ...))
      (group elt)
      (group (op ...))
      (group elt)
      (group (op ...))
      (group elt)
      (group (op ...))
      (group elt)
      (group (op ...))))))
  (group
   class
   Pattern
   (parens (group s (op ::) String))
   (block
    (group implements Indexable)
    (group
     override
     method
     get
     (parens (group ind))
     (block (group s (brackets (group ind)))))
    (group
     method
     expand
     (parens)
     (block
      (group
       Pattern
       (parens
        (group
         s
         (op +&)
         "?"
         (op +&)
         s
         (op +&)
         "?"
         (op +&)
         s
         (op +&)
         "?"
         (op +&)
         s
         (op +&)
         "?"
         (op +&)
         s)))))
    (group
     method
     remaining
     (parens (group ind))
     (block
      (group
       if
       ind
       (op >=)
       0
       (alts
        (block
         (group
          racket
          (op |.|)
          substring
          (parens (group s) (group 0) (group ind (op +) 1))))
        (block (group ""))))))
    (group method length (parens) (block (group s (op |.|) length (parens))))
    (group
     method
     is_functional
     (parens (group ind))
     (block
      (group
       match
       s
       (brackets (group ind))
       (alts
        (block (group #\. (block (group #t))))
        (block (group #\# (block (group #f))))))))
    (group
     method
     is_broken
     (parens (group ind))
     (block
      (group
       match
       s
       (brackets (group ind))
       (alts
        (block (group #\# (block (group #t))))
        (block (group #\. (block (group #f))))))))
    (group
     method
     is_unknown
     (parens (group ind))
     (block
      (group
       match
       s
       (brackets (group ind))
       (alts
        (block (group #\? (block (group #t))))
        (block (group #\. (block (group #f))))
        (block (group #\# (block (group #f))))))))
    (group
     method
     unknowns
     (parens)
     (block
      (group
       for
       List
       (parens (group i (block (group 0 (op ..) length (parens)))))
       (block (group keep_when is_unknown (parens (group i))) (group i)))))
    (group
     method
     find_contiguous_errors
     (parens (group ind) (group #:len (block (group len))))
     (block
      (group
       if
       len
       (op >)
       ind
       (op +)
       1
       (alts
        (block (group #f))
        (block
         (group
          loop
          check_contiguous
          (parens (group i (op =) ind))
          (block
           (group
            cond
            (alts
             (block
              (group
               i
               (op <=)
               ind
               (op -)
               len
               (block
                (group
                 if
                 i
                 (op <)
                 0
                 (op \|\|)
                 is_unknown
                 (parens (group i))
                 (op \|\|)
                 is_functional
                 (parens (group i))
                 (alts (block (group i (op -) 1)) (block (group #f)))))))
             (block
              (group
               is_unknown
               (parens (group i))
               (op \|\|)
               is_broken
               (parens (group i))
               (block (group check_contiguous (parens (group i (op -) 1))))))
             (block (group #:else (block (group #f)))))))))))))
    (group
     method
     check_no_errors
     (parens (group i))
     (block
      (group
       for
       values
       (parens (group result (op =) #t))
       (block
        (group each i (block (group 0 (op ..) i (op +) 1)))
        (group break_when (op !) result)
        (group
         skip_when
         is_unknown
         (parens (group i))
         (op \|\|)
         is_functional
         (parens (group i)))
        (group (op !) is_broken (parens (group i)))))))))
  (group
   fun
   parse_input
   (parens (group raw_input (op ::) ReadableString))
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
       (brackets (group pat) (group spec))
       (block
        (group
         utils
         (op |.|)
         string
         (op |.|)
         split
         (parens (group line) (group " ")))))
      (group
       let
       spec
       (op =)
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
         (parens (group spec) (group ",")))))
      (group
       Pair
       (parens (group Pattern (parens (group pat))) (group spec)))))))
  (group let mutable indent (op =) 0)
  (group
   fun
   calculate_combinations
   (parens
    (group pat (op ::) Pattern)
    (group inds (op ::) List (op |.|) of (parens (group Int))))
   (block
    (group def memo (block (group MutableMap (parens))))
    (group
     fun
     no_combinations
     (parens (group ind) (group ls))
     (block
      (group let elt (block (group Pair (parens (group ind) (group ls)))))
      (group
       if
       memo
       (op |.|)
       has_key
       (parens (group elt))
       (alts
        (block (group memo (brackets (group elt))))
        (block
         (group
          let
          result
          (block
           (group no_combinations_inner (parens (group ind) (group ls)))))
         (group memo (brackets (group elt)) (op :=) result)
         (group result))))))
    (group
     fun
     (alts
      (block
       (group
        no_combinations_inner
        (parens (group ind) (group (brackets)))
        (block
         (group
          if
          pat
          (op |.|)
          check_no_errors
          (parens (group ind))
          (alts (block (group 1)) (block (group 0)))))))
      (block
       (group
        no_combinations_inner
        (parens
         (group ind)
         (group List (op |.|) cons (parens (group hd) (group tail))))
        (block
         (group
          cond
          (alts
           (block (group ind (op <) 0 (block (group 0))))
           (block
            (group
             pat
             (op |.|)
             is_unknown
             (parens (group ind))
             (block
              (group
               let
               no_assign_combs
               (block
                (group
                 let
                 new_ind
                 (block
                  (group
                   pat
                   (op |.|)
                   find_contiguous_errors
                   (parens (group ind) (group #:len (block (group hd)))))))
                (group
                 if
                 new_ind
                 (alts
                  (block
                   (group
                    no_combinations
                    (parens (group new_ind) (group tail))))
                  (block (group 0))))))
              (group
               let
               assign_combs
               (block
                (group
                 no_combinations
                 (parens
                  (group ind (op -) 1)
                  (group
                   List
                   (op |.|)
                   cons
                   (parens (group hd) (group tail)))))))
              (group assign_combs (op +) no_assign_combs))))
           (block
            (group
             pat
             (op |.|)
             is_functional
             (parens (group ind))
             (block
              (group
               no_combinations
               (parens
                (group ind (op -) 1)
                (group
                 List
                 (op |.|)
                 cons
                 (parens (group hd) (group tail))))))))
           (block
            (group
             pat
             (op |.|)
             is_broken
             (parens (group ind))
             (block
              (group
               let
               new_ind
               (block
                (group
                 pat
                 (op |.|)
                 find_contiguous_errors
                 (parens (group ind) (group #:len (block (group hd)))))))
              (group
               if
               new_ind
               (alts
                (block
                 (group no_combinations (parens (group new_ind) (group tail))))
                (block (group 0))))))))))))))
    (group
     no_combinations
     (parens
      (group pat (op |.|) length (parens) (op -) 1)
      (group inds (op |.|) reverse (parens))))))
  (group
   check
   (block
    (group
     Pattern
     (parens (group "???.###"))
     (op |.|)
     find_contiguous_errors
     (parens (group 6) (group #:len (block (group 3)))))
    (group #:is 2)))
  (group
   check
   (block
    (group
     Pattern
     (parens (group "???.###"))
     (op |.|)
     find_contiguous_errors
     (parens (group 4) (group #:len (block (group 1)))))
    (group #:is 2)))
  (group
   check
   (block
    (group
     Pattern
     (parens (group "???.###"))
     (op |.|)
     find_contiguous_errors
     (parens (group 4) (group #:len (block (group 2)))))
    (group #:is #f)))
  (group
   check
   (block
    (group
     Pattern
     (parens (group "???.###"))
     (op |.|)
     find_contiguous_errors
     (parens (group 2) (group #:len (block (group 2)))))
    (group #:is -1)))
  (group
   check
   (block
    (group
     Pattern
     (parens (group "???.###"))
     (op |.|)
     find_contiguous_errors
     (parens (group 0) (group #:len (block (group 1)))))
    (group #:is -2)))
  (group
   check
   (block
    (group
     calculate_combinations
     (parens
      (group Pattern (parens (group "???.###")))
      (group (brackets (group 1) (group 1) (group 3)))))
    (group #:is 1)))
  (group
   check
   (block
    (group
     calculate_combinations
     (parens
      (group Pattern (parens (group ".??..??...?##.")))
      (group (brackets (group 1) (group 1) (group 3)))))
    (group #:is 4)))
  (group
   check
   (block
    (group
     calculate_combinations
     (parens
      (group Pattern (parens (group "?#?#?#?#?#?#?#?")))
      (group (brackets (group 1) (group 3) (group 1) (group 6)))))
    (group #:is 1)))
  (group
   check
   (block
    (group
     calculate_combinations
     (parens
      (group Pattern (parens (group "????.#...#...")))
      (group (brackets (group 4) (group 1) (group 1)))))
    (group #:is 1)))
  (group
   check
   (block
    (group
     calculate_combinations
     (parens
      (group Pattern (parens (group "????.######..#####.")))
      (group (brackets (group 1) (group 6) (group 5)))))
    (group #:is 4)))
  (group
   check
   (block
    (group
     calculate_combinations
     (parens
      (group Pattern (parens (group "?###????????")))
      (group (brackets (group 3) (group 2) (group 1)))))
    (group #:is 10)))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group
       each
       Pair
       (parens (group pat) (group spec))
       (block (group parse_input (parens (group raw_input)))))
      (group
       sum
       (op +)
       calculate_combinations
       (parens (group pat) (group spec)))))))
  (group
   check
   (block (group solve_for_part1 (parens (group test_input))) (group #:is 21)))
  (group def result1 (block (group solve_for_part1 (parens (group input)))))
  (group
   check
   (block
    (group Pattern (parens (group ".#")) (op |.|) expand (parens))
    (group #:is Pattern (parens (group ".#?.#?.#?.#?.#")))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group
       each
       Pair
       (parens (group pat) (group spec))
       (block (group parse_input (parens (group raw_input)))))
      (group
       sum
       (op +)
       calculate_combinations
       (parens
        (group pat (op |.|) expand (parens))
        (group List (op |.|) mul_by_five (parens (group spec)))))))))
  (group
   check
   (block
    (group solve_for_part2 (parens (group test_input)))
    (group #:is 525152)))
  (group def result2 (block (group solve_for_part2 (parens (group input))))))
