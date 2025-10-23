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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 16)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group ".|...\\....")
      (group "|.-.\\.....")
      (group ".....|-...")
      (group "........|.")
      (group "..........")
      (group ".........\\")
      (group "..../.\\\\..")
      (group ".-.-/..|..")
      (group ".|....-|.\\")
      (group "..//.|....")))))
  (group
   fun
   Array
   (op |.|)
   of_list
   (parens (group (brackets (group x) (group (op ...)))))
   (block (group Array (parens (group x) (group (op ...))))))
  (group
   annot
   (op |.|)
   macro
   (quotes (group Direction))
   (block
    (group
     (quotes
      (group
       matching
       (parens
        (group
         (op |#'|)
         north
         (op \|\|)
         (op |#'|)
         east
         (op \|\|)
         (op |#'|)
         south
         (op \|\|)
         (op |#'|)
         west)))))))
  (group
   fun
   step_in_direction
   (parens
    (group pos (op ::) utils (op |.|) Point)
    (group direction (op ::) Direction))
   (op ::)
   utils
   (op |.|)
   Point
   (block
    (group
     match
     direction
     (alts
      (block
       (group
        (op |#'|)
        north
        (block
         (group
          utils
          (op |.|)
          Point
          (parens (group pos (op |.|) x) (group pos (op |.|) y (op -) 1))))))
      (block
       (group
        (op |#'|)
        south
        (block
         (group
          utils
          (op |.|)
          Point
          (parens (group pos (op |.|) x) (group pos (op |.|) y (op +) 1))))))
      (block
       (group
        (op |#'|)
        east
        (block
         (group
          utils
          (op |.|)
          Point
          (parens (group pos (op |.|) x (op +) 1) (group pos (op |.|) y))))))
      (block
       (group
        (op |#'|)
        west
        (block
         (group
          utils
          (op |.|)
          Point
          (parens
           (group pos (op |.|) x (op -) 1)
           (group pos (op |.|) y))))))))))
  (group
   fun
   move_in_direction
   (parens
    (group pos (op ::) utils (op |.|) Point)
    (group direction (op ::) Direction))
   (op ::)
   Pair
   (op |.|)
   of
   (parens (group utils (op |.|) Point) (group Direction))
   (block
    (group
     Pair
     (parens
      (group step_in_direction (parens (group pos) (group direction)))
      (group direction)))))
  (group
   class
   Grid
   (parens
    (group WIDTH (op ::) Int)
    (group HEIGHT (op ::) Int)
    (group grid (op ::) Array (op |.|) of (parens (group String)))
    (group
     energised
     (op ::)
     Array
     (op |.|)
     of
     (parens (group Array (op |.|) of (parens (group Boolean)))))
    (group seen_beams (op ::) MutableSet)
    (group
     mutable
     beams
     (op ::)
     List
     (op |.|)
     of
     (parens
      (group
       Pair
       (op |.|)
       of
       (parens (group utils (op |.|) Point) (group Direction)))))
    (group mutable no_energised (op ::) Int))
   (block
    (group
     method
     valid_pos
     (parens (group pos (op ::) utils (op |.|) Point))
     (op ::)
     Boolean
     (block
      (group
       0
       (op <=)
       pos
       (op |.|)
       x
       (op &&)
       pos
       (op |.|)
       x
       (op <)
       WIDTH
       (op &&)
       0
       (op <=)
       pos
       (op |.|)
       y
       (op &&)
       pos
       (op |.|)
       y
       (op <)
       HEIGHT)))
    (group
     method
     apply_beam
     (parens
      (group
       Pair
       (parens
        (group pos (op ::) utils (op |.|) Point)
        (group direction (op ::) Direction))))
     (block
      (group
       match
       (brackets
        (group
         grid
         (brackets (group pos (op |.|) y))
         (brackets (group pos (op |.|) x)))
        (group direction))
       (alts
        (block
         (group
          (brackets (group #\.) (group _))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group direction))))))))
        (block
         (group
          (brackets (group #\/) (group (op |#'|) north))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) east))))))))
        (block
         (group
          (brackets (group #\/) (group (op |#'|) east))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) north))))))))
        (block
         (group
          (brackets (group #\/) (group (op |#'|) south))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) west))))))))
        (block
         (group
          (brackets (group #\/) (group (op |#'|) west))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) south))))))))
        (block
         (group
          (brackets (group #\\) (group (op |#'|) north))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) west))))))))
        (block
         (group
          (brackets (group #\\) (group (op |#'|) west))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) north))))))))
        (block
         (group
          (brackets (group #\\) (group (op |#'|) south))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) east))))))))
        (block
         (group
          (brackets (group #\\) (group (op |#'|) east))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) south))))))))
        (block
         (group
          (brackets
           (group #\|)
           (group (parens (group (op |#'|) north (op \|\|) (op |#'|) south))))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group direction))))))))
        (block
         (group
          (brackets
           (group #\-)
           (group (parens (group (op |#'|) east (op \|\|) (op |#'|) west))))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group direction))))))))
        (block
         (group
          (brackets
           (group #\|)
           (group (parens (group (op |#'|) east (op \|\|) (op |#'|) west))))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) north)))
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) south))))))))
        (block
         (group
          (brackets
           (group #\-)
           (group (parens (group (op |#'|) north (op \|\|) (op |#'|) south))))
          (block
           (group
            (brackets
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) east)))
             (group
              move_in_direction
              (parens (group pos) (group (op |#'|) west))))))))))))
    (group
     method
     valid_start_positions
     (parens)
     (block
      (group
       (parens
        (group
         for
         List
         (parens (group i (block (group 0 (op ..) WIDTH))))
         (block
          (group
           Pair
           (parens
            (group utils (op |.|) Point (parens (group i) (group 0)))
            (group (op |#'|) south))))))
       (op ++)
       (parens
        (group
         for
         List
         (parens (group i (block (group 0 (op ..) WIDTH))))
         (block
          (group
           Pair
           (parens
            (group
             utils
             (op |.|)
             Point
             (parens (group i) (group HEIGHT (op -) 1)))
            (group (op |#'|) north))))))
       (op ++)
       (parens
        (group
         for
         List
         (parens (group i (block (group 0 (op ..) HEIGHT))))
         (block
          (group
           Pair
           (parens
            (group utils (op |.|) Point (parens (group 0) (group i)))
            (group (op |#'|) east))))))
       (op ++)
       (parens
        (group
         for
         List
         (parens (group i (block (group 0 (op ..) HEIGHT))))
         (block
          (group
           Pair
           (parens
            (group
             utils
             (op |.|)
             Point
             (parens (group WIDTH (op -) 1) (group i)))
            (group (op |#'|) west)))))))))
    (group
     method
     beams_finished
     (parens)
     (block (group beams (op ==) (brackets))))
    (group
     method
     run_beam
     (parens)
     (block
      (group
       while
       (op !)
       beams_finished
       (parens)
       (block (group step_beam (parens))))))
    (group
     method
     record_beam
     (parens (group beam))
     (block
      (group seen_beams (brackets (group beam)) (op :=) #t)
      (group
       if
       energised
       (brackets (group beam (op |.|) first (op |.|) y))
       (brackets (group beam (op |.|) first (op |.|) x))
       (alts
        (block (group #<void>))
        (block
         (group no_energised (op :=) no_energised (op +) 1)
         (group
          energised
          (brackets (group beam (op |.|) first (op |.|) y))
          (brackets (group beam (op |.|) first (op |.|) x))
          (op :=)
          #t))))))
    (group
     method
     step_beam
     (parens)
     (block
      (group
       def
       new_beam_list
       (block
        (group
         for
         List
         (block
          (group each beam (block (group beams)))
          (group skip_when seen_beams (brackets (group beam)))
          (group record_beam (parens (group beam)))
          (group
           each
           new_beam
           (block (group apply_beam (parens (group beam)))))
          (group keep_when valid_pos (parens (group new_beam (op |.|) first)))
          (group new_beam)))))
      (group beams (op :=) new_beam_list)))
    (group
     method
     count_energised
     (parens)
     (block
      (group
       for
       values
       (parens (group count (op =) 0))
       (block
        (group each arr (block (group energised)))
        (group each elt (block (group arr)))
        (group keep_when elt)
        (group count (op +) 1)))))
    (group
     constructor
     (parens
      (group s (op ::) ReadableString)
      (group
       #:start_pos
       (block
        (group
         start_pos
         (op =)
         Pair
         (parens
          (group utils (op |.|) Point (parens (group 0) (group 0)))
          (group (op |#'|) east))))))
     (block
      (group
       let
       grid
       (op =)
       Array
       (op |.|)
       of_list
       (parens
        (group
         (parens
          (group
           fun
           (parens (group v (op ::) ReadableString))
           (block (group v (op |.|) to_string (parens)))))
         (op |.|)
         map
         (parens
          (group
           utils
           (op |.|)
           string
           (op |.|)
           split_lines
           (parens (group s)))))))
      (group
       let
       energised
       (op =)
       Array
       (op |.|)
       make
       (parens (group grid (op |.|) length (parens)) (group #f)))
      (group
       for
       (parens
        (group i (block (group 0 (op ..) energised (op |.|) length (parens)))))
       (block
        (group
         energised
         (brackets (group i))
         (op :=)
         Array
         (op |.|)
         make
         (parens
          (group grid (brackets (group 0)) (op |.|) length (parens))
          (group #f)))))
      (group
       super
       (parens
        (group grid (brackets (group 0)) (op |.|) length (parens))
        (group grid (op |.|) length (parens))
        (group grid)
        (group energised)
        (group MutableSet (parens))
        (group (brackets (group start_pos)))
        (group 0)))))))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group def grid (block (group Grid (parens (group raw_input)))))
    (group grid (op |.|) run_beam (parens))
    (group grid (op |.|) no_energised)))
  (group
   check
   (block (group solve_for_part1 (parens (group test_input))) (group #:is 46)))
  (group def result1 (block (group solve_for_part1 (parens (group input)))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group def mutable max_seen (block (group #f)))
    (group
     fun
     record_max_seen
     (parens (group seen))
     (block
      (group
       cond
       (alts
        (block (group (op !) max_seen (block (group max_seen (op :=) seen))))
        (block
         (group max_seen (op <) seen (block (group max_seen (op :=) seen))))
        (block (group #:else (block (group #<void>))))))))
    (group
     def
     mutable
     grids
     (block
      (group
       for
       List
       (parens
        (group
         pos
         (block
          (group
           Grid
           (parens (group raw_input))
           (op |.|)
           valid_start_positions
           (parens)))))
       (block
        (group
         def
         grid
         (block
          (group
           Grid
           (parens
            (group raw_input)
            (group #:start_pos (block (group pos)))))))
        (group
         for
         (parens (group i (block (group 0 (op ..) 10))))
         (block (group grid (op |.|) step_beam (parens))))
        (group
         when
         grid
         (op |.|)
         beams_finished
         (parens)
         (alts
          (block
           (group
            record_max_seen
            (parens (group grid (op |.|) no_energised))))))
        (group skip_when grid (op |.|) beams_finished (parens))
        (group grid)))))
    (group
     grids
     (op :=)
     List
     (op |.|)
     sort
     (parens
      (group grids)
      (group
       fun
       (parens (group l) (group r))
       (block
        (group l (op |.|) no_energised (op >) r (op |.|) no_energised)))))
    (group
     while
     grids
     (op !=)
     (brackets)
     (block
      (group
       let
       (brackets (group grid) (group remaining) (group (op ...)))
       (block (group grids)))
      (group grid (op |.|) step_beam (parens))
      (group
       if
       grid
       (op |.|)
       beams_finished
       (parens)
       (alts
        (block
         (group record_max_seen (parens (group grid (op |.|) no_energised)))
         (group grids (op :=) (brackets (group remaining) (group (op ...)))))
        (block
         (group
          grids
          (op :=)
          utils
          (op |.|)
          list
          (op |.|)
          insert_into_sorted
          (parens
           (group grid)
           (group (brackets (group remaining) (group (op ...))))
           (group
            #:key
            (block
             (group
              fun
              (parens (group elt))
              (block (group elt (op |.|) no_energised))))))))))))
    (group max_seen)))
  (group
   check
   (block (group solve_for_part2 (parens (group test_input))) (group #:is 51)))
  (group def result2 (block (group solve_for_part2 (parens (group input)))))
  (group result2))
