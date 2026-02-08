'(multi
  (group
   import
   (block
    (group file (parens (group "./utils/aoc_api.rhm")))
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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 3)))))
  (group
   def
   test_input
   (block
    (group
     "467..114..\n"
     (op +&)
     "...*......\n"
     (op +&)
     "..35..633.\n"
     (op +&)
     "......#...\n"
     (op +&)
     "617*......\n"
     (op +&)
     ".....+.58.\n"
     (op +&)
     "..592.....\n"
     (op +&)
     "......755.\n"
     (op +&)
     "...$.*....\n"
     (op +&)
     ".664.598..")))
  (group def input_text (block (group test_input)))
  (group
   fun
   skip_numeric
   (parens (group str (op ::) String) (group ind))
   (block
    (group
     if
     ind
     (op <)
     str
     (op |.|)
     length
     (parens)
     (op &&)
     Char
     (op |.|)
     is_numeric
     (parens (group str (brackets (group ind))))
     (alts
      (block (group skip_numeric (parens (group str) (group ind (op +) 1))))
      (block (group ind))))))
  (group
   fun
   skip_till_numeric
   (parens (group str (op ::) String) (group ind (op ::) Int))
   (block
    (group
     if
     (parens
      (group
       ind
       (op <)
       str
       (op |.|)
       length
       (parens)
       (op &&)
       (op !)
       Char
       (op |.|)
       is_numeric
       (parens (group str (brackets (group ind))))))
     (alts
      (block
       (group skip_till_numeric (parens (group str) (group ind (op +) 1))))
      (block (group ind))))))
  (group
   fun
   is_symbol
   (parens (group c (op ::) Char))
   (block
    (group
     cond
     (alts
      (block (group c (op ==) #\. (block (group #f))))
      (block
       (group Char (op |.|) is_numeric (parens (group c)) (block (group #f))))
      (block (group #:else (block (group #t))))))))
  (group
   fun
   check_for_symbol
   (parens
    (group str (op ::) String)
    (group st (op ::) Int)
    (group end (op ::) Int))
   (block
    (group
     if
     st
     (op ==)
     end
     (alts
      (block (group #f))
      (block
       (group def c (block (group str (brackets (group st)))))
       (group
        if
        is_symbol
        (parens (group c))
        (alts
         (block (group st))
         (block
          (group
           check_for_symbol
           (parens (group str) (group st (op +) 1) (group end)))))))))))
  (group
   fun
   collect_symbol_inds
   (parens
    (group str (op ::) String)
    (group st (op ::) Int)
    (group end (op ::) Int))
   (op ::)
   List
   (op |.|)
   of
   (parens (group Int))
   (block
    (group
     if
     st
     (op ==)
     end
     (alts
      (block (group (brackets)))
      (block
       (group def c (block (group str (brackets (group st)))))
       (group
        if
        is_symbol
        (parens (group c))
        (alts
         (block
          (group
           List
           (op |.|)
           cons
           (parens
            (group st)
            (group
             collect_symbol_inds
             (parens (group str) (group st (op +) 1) (group end))))))
         (block
          (group
           collect_symbol_inds
           (parens (group str) (group st (op +) 1) (group end)))))))))))
  (group
   fun
   split_numbers
   (parens (group line (op ::) String))
   (op ::)
   List
   (op |.|)
   of
   (parens
    (group
     Pair
     (op |.|)
     of
     (parens (group Int) (group List (op |.|) of (parens (group Int))))))
   (block
    (group def mutable ind (block (group 0)))
    (group def mutable lines (block (group (brackets))))
    (group
     while
     (parens (group ind (op <) line (op |.|) length (parens)))
     (block
      (group
       let
       start
       (block (group skip_till_numeric (parens (group line) (group ind)))))
      (group
       let
       end
       (block (group skip_numeric (parens (group line) (group start)))))
      (group
       let
       number_str
       (block
        (group
         String
         (op |.|)
         substring
         (parens (group line) (group start) (group end)))))
      (group
       let
       number
       (block (group String (op |.|) to_number (parens (group number_str)))))
      (group
       when
       number
       (alts
        (block
         (group
          lines
          (op :=)
          List
          (op |.|)
          cons
          (parens
           (group
            Pair
            (parens
             (group number)
             (group (brackets (group start) (group end)))))
           (group lines))))))
      (group ind (op :=) end)))
    (group List (op |.|) reverse (parens (group lines)))))
  (group
   fun
   solve_part1
   (parens (group input_text (op ::) ReadableString))
   (block
    (group
     def
     (brackets (group line) (group (op ...)))
     (op ::)
     List
     (op |.|)
     of
     (parens (group ReadableString))
     (block
      (group string (op |.|) split (parens (group input_text) (group "\n")))))
    (group
     def
     data
     (block
      (group
       Array
       (parens (group line (op |.|) to_string (parens)) (group (op ...))))))
    (group def mutable sum (block (group 0)))
    (group
     for
     (block
      (group each i (block (group 0 (op ..) data (op |.|) length (parens))))
      (group
       let
       prev_line
       (block
        (group
         if
         i
         (op >)
         0
         (alts
          (block (group data (brackets (group i (op -) 1))))
          (block (group #f))))))
      (group
       let
       next_line
       (block
        (group
         if
         i
         (op <)
         data
         (op |.|)
         length
         (parens)
         (op -)
         1
         (alts
          (block (group data (brackets (group i (op +) 1))))
          (block (group #f))))))
      (group let line (op =) data (brackets (group i)))
      (group
       let
       total
       (block
        (group
         for
         values
         (parens (group lsum (op =) 0))
         (block
          (group
           each
           Pair
           (parens (group number) (group (brackets (group start) (group end))))
           (block (group split_numbers (parens (group line)))))
          (group
           let
           start_diagonal
           (block
            (group
             racket
             (op |.|)
             max
             (parens (group 0) (group start (op -) 1)))))
          (group
           let
           end_diagonal
           (block
            (group
             racket
             (op |.|)
             min
             (parens
              (group end (op +) 1)
              (group line (op |.|) length (parens))))))
          (group
           cond
           (alts
            (block
             (group
              is_symbol
              (parens (group line (brackets (group start_diagonal))))
              (block (group lsum (op +) number))))
            (block
             (group
              end
              (op <)
              line
              (op |.|)
              length
              (parens)
              (op &&)
              is_symbol
              (parens (group line (brackets (group end))))
              (block (group lsum (op +) number))))
            (block
             (group
              prev_line
              (op &&)
              check_for_symbol
              (parens
               (group prev_line)
               (group start_diagonal)
               (group end_diagonal))
              (block (group lsum (op +) number))))
            (block
             (group
              next_line
              (op &&)
              check_for_symbol
              (parens
               (group next_line)
               (group start_diagonal)
               (group end_diagonal))
              (block (group lsum (op +) number))))
            (block (group #:else (block (group lsum))))))))))
      (group sum (op :=) sum (op +) total)))
    (group sum)))
  (group
   check
   (block (group solve_part1 (parens (group test_input))) (group #:is 4361)))
  (group
   fun
   solve_part2
   (parens (group input_text))
   (block
    (group
     def
     (brackets (group line) (group (op ...)))
     (op ::)
     List
     (op |.|)
     of
     (parens (group ReadableString))
     (block
      (group string (op |.|) split (parens (group input_text) (group "\n")))))
    (group
     def
     data
     (block
      (group
       Array
       (parens (group line (op |.|) to_string (parens)) (group (op ...))))))
    (group def map (block (group MutableMap (parens))))
    (group
     fun
     insert_into_map
     (parens (group line) (group col) (group number))
     (block
      (group let pair (block (group Pair (parens (group line) (group col)))))
      (group
       if
       map
       (op |.|)
       has_key
       (parens (group pair))
       (alts
        (block
         (group
          map
          (brackets (group pair))
          (op :=)
          List
          (op |.|)
          cons
          (parens (group number) (group map (brackets (group pair))))))
        (block
         (group
          map
          (brackets (group pair))
          (op :=)
          (brackets (group number))))))))
    (group
     for
     (block
      (group each i (block (group 0 (op ..) data (op |.|) length (parens))))
      (group
       let
       prev_line
       (block
        (group
         if
         i
         (op >)
         0
         (alts
          (block (group data (brackets (group i (op -) 1))))
          (block (group #f))))))
      (group
       let
       next_line
       (block
        (group
         if
         i
         (op <)
         data
         (op |.|)
         length
         (parens)
         (op -)
         1
         (alts
          (block (group data (brackets (group i (op +) 1))))
          (block (group #f))))))
      (group let line (op =) data (brackets (group i)))
      (group
       for
       (block
        (group
         each
         Pair
         (parens (group number) (group (brackets (group start) (group end))))
         (block (group split_numbers (parens (group line)))))
        (group
         let
         start_diagonal
         (block
          (group
           racket
           (op |.|)
           max
           (parens (group 0) (group start (op -) 1)))))
        (group
         let
         end_diagonal
         (block
          (group
           racket
           (op |.|)
           min
           (parens
            (group end (op +) 1)
            (group line (op |.|) length (parens))))))
        (group
         when
         is_symbol
         (parens (group line (brackets (group start_diagonal))))
         (alts
          (block
           (group
            insert_into_map
            (parens (group i) (group start_diagonal) (group number))))))
        (group
         when
         end
         (op <)
         line
         (op |.|)
         length
         (parens)
         (op &&)
         is_symbol
         (parens (group line (brackets (group end))))
         (alts
          (block
           (group
            insert_into_map
            (parens (group i) (group end) (group number))))))
        (group
         when
         prev_line
         (alts
          (block
           (group
            for
            (parens
             (group
              sym_ind
              (block
               (group
                collect_symbol_inds
                (parens
                 (group prev_line)
                 (group start_diagonal)
                 (group end_diagonal))))))
            (block
             (group
              insert_into_map
              (parens (group i (op -) 1) (group sym_ind) (group number))))))))
        (group
         when
         next_line
         (alts
          (block
           (group
            for
            (parens
             (group
              sym_ind
              (block
               (group
                collect_symbol_inds
                (parens
                 (group next_line)
                 (group start_diagonal)
                 (group end_diagonal))))))
            (block
             (group
              insert_into_map
              (parens
               (group i (op +) 1)
               (group sym_ind)
               (group number))))))))))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each values (parens (group loc) (group nums)) (block (group map)))
      (group
       if
       nums
       (op |.|)
       length
       (parens)
       (op ==)
       2
       (alts
        (block
         (group
          sum
          (op +)
          nums
          (brackets (group 0))
          (op *)
          nums
          (brackets (group 1))))
        (block (group sum))))))))
  (group
   check
   (block
    (group solve_part2 (parens (group test_input)))
    (group #:is 467835))))
