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
   fun
   map_string
   (parens (group f) (group s))
   (block
    (group
     (parens
      (group
       racket
       (op |.|)
       list->string
       (parens
        (group
         f
         (parens (group racket (op |.|) string->list (parens (group s))))))
       (op :~)
       ReadableString))
     (op |.|)
     to_string
     (parens))))
  (group
   def
   input
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 14)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "O....#....")
      (group "O.OO#....#")
      (group ".....##...")
      (group "OO.#O....O")
      (group ".O.....O#.")
      (group "O.#..O.#.#")
      (group "..O..#O..O")
      (group ".......O..")
      (group "#....###..")
      (group "#OO..#....")))))
  (group
   fun
   (alts
    (block
     (group
      fun_repeat
      (parens (group 0) (group f) (group v))
      (block (group v))))
    (block
     (group
      fun_repeat
      (parens (group n) (group f) (group v))
      (block
       (group
        if
        n
        (op <)
        0
        (alts
         (block (group #f))
         (block
          (group
           fun_repeat
           (parens
            (group n (op -) 1)
            (group f)
            (group f (parens (group v)))))))))))))
  (group
   fun
   transpose
   (parens (group grid (op ::) List (op |.|) of (parens (group List))))
   (block
    (group
     for
     List
     (parens
      (group
       i
       (block
        (group 0 (op ..) grid (brackets (group 0)) (op |.|) length (parens)))))
     (block
      (group
       for
       List
       (parens (group row (block (group grid))))
       (block (group row (brackets (group i)))))))))
  (group
   fun
   shift_stones
   (parens (group row (op ::) List))
   (op ::)
   List
   (block
    (group
     recur
     loop
     (parens
      (group row (op =) row)
      (group acc_stones (op =) (brackets))
      (group acc_holes (op =) (brackets)))
     (block
      (group
       match
       row
       (alts
        (block (group (brackets) (block (group acc_holes (op ++) acc_stones))))
        (block
         (group
          List
          (op |.|)
          cons
          (parens (group #\.) (group tail))
          (block
           (group
            loop
            (parens
             (group tail)
             (group acc_stones)
             (group
              List
              (op |.|)
              cons
              (parens (group #\.) (group acc_holes))))))))
        (block
         (group
          List
          (op |.|)
          cons
          (parens (group #\O) (group tail))
          (block
           (group
            loop
            (parens
             (group tail)
             (group List (op |.|) cons (parens (group #\O) (group acc_stones)))
             (group acc_holes))))))
        (block
         (group
          List
          (op |.|)
          cons
          (parens (group #\#) (group tail))
          (block
           (group
            acc_holes
            (op ++)
            acc_stones
            (op ++)
            (brackets (group #\#))
            (op ++)
            loop
            (parens
             (group tail)
             (group (brackets))
             (group (brackets)))))))))))))
  (group
   fun
   shift_stones_east
   (parens (group grid (op ::) List))
   (block
    (group
     for
     List
     (parens (group row (block (group grid))))
     (block (group shift_stones (parens (group row)))))))
  (group
   fun
   shift_stones_west
   (parens (group grid (op ::) List))
   (block
    (group
     for
     List
     (parens (group row (block (group grid))))
     (block
      (group
       shift_stones
       (parens (group row (op |.|) reverse (parens)))
       (op |.|)
       reverse
       (parens))))))
  (group
   fun
   shift_stones_south
   (parens (group grid (op ::) List))
   (block
    (group
     transpose
     (parens
      (group
       shift_stones_east
       (parens (group transpose (parens (group grid)))))))))
  (group
   fun
   shift_stones_north
   (parens (group grid (op ::) List))
   (block
    (group
     transpose
     (parens
      (group
       shift_stones_west
       (parens (group transpose (parens (group grid)))))))))
  (group
   fun
   (alts
    (block
     (group
      List
      (op |.|)
      count
      (parens (group pred) (group (brackets)) (group n))
      (block (group n))))
    (block
     (group
      List
      (op |.|)
      count
      (parens
       (group pred)
       (group List (op |.|) cons (parens (group hd) (group tail)))
       (group n))
      (block
       (group
        List
        (op |.|)
        count
        (parens
         (group pred)
         (group tail)
         (group
          (parens
           (group
            if
            pred
            (parens (group hd))
            (alts (block (group n (op +) 1)) (block (group n)))))))))))
    (block
     (group
      List
      (op |.|)
      count
      (parens (group pred) (group ls))
      (block
       (group
        List
        (op |.|)
        count
        (parens (group pred) (group ls) (group 0))))))))
  (group
   check
   (block
    (group map_string (parens (group shift_stones) (group "O....#O...")))
    (group #:is "....O#...O")))
  (group
   class
   Grid
   (parens
    (group
     grid
     (op ::)
     List
     (op |.|)
     of
     (parens (group List (op |.|) of (parens (group Char))))))
   (block
    (group
     constructor
     (alts
      (block
       (group
        (parens
         (group
          s
          (op ::)
          List
          (op |.|)
          of
          (parens (group List (op |.|) of (parens (group Char))))))
        (block (group super (parens (group s))))))
      (block
       (group
        (parens (group s (op ::) ReadableString))
        (block
         (group
          super
          (parens
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
              (parens (group s))))))))))))
    (group
     method
     shift_north
     (parens)
     (block
      (group Grid (parens (group shift_stones_north (parens (group grid)))))))
    (group
     method
     shift_east
     (parens)
     (block
      (group Grid (parens (group shift_stones_east (parens (group grid)))))))
    (group
     method
     shift_south
     (parens)
     (block
      (group Grid (parens (group shift_stones_south (parens (group grid)))))))
    (group
     method
     shift_west
     (parens)
     (block
      (group Grid (parens (group shift_stones_west (parens (group grid)))))))
    (group
     method
     score
     (parens)
     (block
      (group
       for
       values
       (parens (group sum (op =) 0))
       (block
        (group
         each
         (block
          (group row (block (group grid (op |.|) reverse (parens))))
          (group i (block (group 1 (op ..))))))
        (group
         sum
         (op +)
         i
         (op *)
         List
         (op |.|)
         count
         (parens
          (group
           fun
           (alts
            (block (group (parens (group #\O)) (block (group #t))))
            (block (group (parens (group _)) (block (group #f))))))
          (group row)))))))
    (group
     method
     cycle
     (parens)
     (block
      (group
       this
       (op |.|)
       shift_north
       (parens)
       (op |.|)
       shift_west
       (parens)
       (op |.|)
       shift_south
       (parens)
       (op |.|)
       shift_east
       (parens))))))
  (group
   fun
   cycle_till_fixpoint
   (parens
    (group grid)
    (group #:limit (block (group limit (op =) 1000000000))))
   (block
    (group let seen (block (group MutableMap (parens))))
    (group
     recur
     loop
     (parens (group grid (op =) grid) (group count (op =) limit))
     (block
      (group
       cond
       (alts
        (block
         (group count (op ==) 0 (block (group grid (op |.|) score (parens)))))
        (block
         (group
          #:else
          (block
           (group let new_grid (op =) grid (op |.|) cycle (parens))
           (group
            if
            seen
            (op |.|)
            has_key
            (parens (group new_grid))
            (alts
             (block
              (group
               let
               diff
               (op =)
               seen
               (brackets (group new_grid))
               (op -)
               count)
              (group let extra (op =) count mod diff)
              (group
               (parens
                (group
                 fun_repeat
                 (parens
                  (group extra (op -) 1)
                  (group
                   fun
                   (parens (group v))
                   (block (group v (op |.|) cycle (parens))))
                  (group new_grid))
                 (op |.|)
                 score
                 (parens)))))
             (block
              (group seen (brackets (group new_grid)) (op :=) count)
              (group
               loop
               (parens (group new_grid) (group count (op -) 1)))))))))))))))
  (group
   check
   (block
    (group
     Grid
     (parens (group test_input))
     (op |.|)
     shift_north
     (parens)
     (op |.|)
     score
     (parens))
    (group #:is 136)))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     Grid
     (parens (group raw_input))
     (op |.|)
     shift_north
     (parens)
     (op |.|)
     score
     (parens))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     cycle_till_fixpoint
     (parens (group Grid (parens (group raw_input)))))))
  (group def result1 (block (group solve_for_part1 (parens (group input)))))
  (group def result2 (block (group solve_for_part2 (parens (group input))))))
