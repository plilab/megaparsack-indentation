'(multi
  (group
   import
   (block
    (group file (parens (group "./utils/aoc_api.rhm")))
    (group file (parens (group "./utils/utils.rhm")))
    (group file (parens (group "./utils/lang.rhm")) open)
    (group lib (parens (group "data/heap.rkt")) as heap)
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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 18)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "R 6 (#70c710)")
      (group "D 5 (#0dc571)")
      (group "L 2 (#5713f0)")
      (group "D 2 (#d2c081)")
      (group "R 2 (#59c680)")
      (group "D 2 (#411b91)")
      (group "L 5 (#8ceee2)")
      (group "U 2 (#caa173)")
      (group "L 1 (#1b58a2)")
      (group "U 2 (#caa171)")
      (group "R 2 (#7807d2)")
      (group "U 3 (#a77fa3)")
      (group "L 2 (#015232)")
      (group "U 2 (#7a21e3)")))))
  (group let raw_input (op =) test_input)
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
         left
         (op \|\|)
         (op |#'|)
         right
         (op \|\|)
         (op |#'|)
         up
         (op \|\|)
         (op |#'|)
         down)))))))
  (group
   annot
   (op |.|)
   macro
   (quotes (group Matrix))
   (block
    (group
     (quotes
      (group
       Array
       (op |.|)
       of
       (parens (group Array (op |.|) of (parens (group Int)))))))))
  (group
   namespace
   Direction
   (block
    (group export (block (group to_delta)))
    (group
     fun
     (alts
      (block
       (group
        to_delta
        (parens (group (op |#'|) left))
        (block (group utils (op |.|) Point (parens (group -1) (group 0))))))
      (block
       (group
        to_delta
        (parens (group (op |#'|) right))
        (block (group utils (op |.|) Point (parens (group 1) (group 0))))))
      (block
       (group
        to_delta
        (parens (group (op |#'|) up))
        (block (group utils (op |.|) Point (parens (group 0) (group -1))))))
      (block
       (group
        to_delta
        (parens (group (op |#'|) down))
        (block (group utils (op |.|) Point (parens (group 0) (group 1))))))))))
  (group
   class
   Instruction
   (parens
    (group direction (op ::) Direction)
    (group distance (op ::) Int)
    (group color (op ::) String))
   (block
    (group
     method
     decode
     (parens)
     (block
      (group
       let
       distance
       (op =)
       racket
       (op |.|)
       string->number
       (parens
        (group
         racket
         (op |.|)
         substring
         (parens (group color) (group 1) (group 6)))
        (group 16)))
      (group
       let
       direction
       (op =)
       match
       color
       (brackets (group 6))
       (alts
        (block (group #\0 (block (group (op |#'|) right))))
        (block (group #\1 (block (group (op |#'|) down))))
        (block (group #\2 (block (group (op |#'|) left))))
        (block (group #\3 (block (group (op |#'|) up))))))
      (group
       Instruction
       (parens (group direction) (group distance) (group "")))))
    (group
     method
     delta
     (parens)
     (op ::)
     utils
     (op |.|)
     Point
     (block
      (group
       Direction
       (op |.|)
       to_delta
       (parens (group direction))
       (op |.|)
       mul
       (parens (group distance)))))))
  (group
   class
   DigMap
   (parens
    (group
     data
     (op ::)
     Array
     (op |.|)
     of
     (parens (group Array (op |.|) of (parens (group Boolean)))))
    (group base_x (op ::) Int)
    (group base_y (op ::) Int))
   (block
    (group implements MutableIndexable)
    (group
     method
     to_string
     (parens)
     (block
      (group
       for
       values
       (parens (group res (op =) ""))
       (parens
        (group i (block (group 0 (op ..) data (op |.|) length (parens)))))
       (block
        (group let elt (op =) data (brackets (group i)))
        (group
         res
         (op +&)
         "\n"
         (op +&)
         for
         values
         (parens (group res (op =) ""))
         (parens
          (group j (block (group 0 (op ..) elt (op |.|) length (parens)))))
         (block
          (group
           res
           (op +&)
           if
           elt
           (brackets (group j))
           (alts (block (group "#")) (block (group "."))))))))))
    (group
     override
     method
     get
     (parens (group point (op ::) utils (op |.|) Point))
     (block
      (group
       data
       (brackets (group point (op |.|) y (op -) base_y))
       (brackets (group point (op |.|) x (op -) base_x)))))
    (group
     override
     method
     set
     (parens (group point (op ::) utils (op |.|) Point) (group val))
     (block
      (group
       data
       (brackets (group point (op |.|) y (op -) base_y))
       (brackets (group point (op |.|) x (op -) base_x))
       (op :=)
       val)))
    (group
     method
     count_area
     (parens)
     (block
      (group
       for
       values
       (parens (group area (op =) 0))
       (parens
        (group i (block (group 0 (op ..) data (op |.|) length (parens)))))
       (block
        (group let row (op =) data (brackets (group i)))
        (group
         for
         values
         (parens (group area (op =) area))
         (parens
          (group j (block (group 0 (op ..) row (op |.|) length (parens)))))
         (block
          (group
           if
           row
           (brackets (group j))
           (alts (block (group area (op +) 1)) (block (group area))))))))))
    (group
     method
     fill_in_interior
     (parens)
     (block
      (group
       let
       mutable
       queue
       (op =)
       (brackets (group utils (op |.|) Point (parens (group 1) (group 1)))))
      (group
       while
       queue
       (op !=)
       (brackets)
       (block
        (group
         let
         List
         (op |.|)
         cons
         (parens (group hd) (group tail))
         (op =)
         queue)
        (group queue (op :=) tail)
        (group
         for
         (parens
          (group
           point
           (block
            (group
             (brackets
              (group hd (op |.|) north (parens))
              (group hd (op |.|) south (parens))
              (group hd (op |.|) west (parens))
              (group hd (op |.|) east (parens)))))))
         (block
          (group
           keep_when
           0
           (op <=)
           point
           (op |.|)
           x
           (op -)
           base_x
           (op &&)
           point
           (op |.|)
           x
           (op -)
           base_x
           (op <)
           data
           (brackets (group 0))
           (op |.|)
           length
           (parens))
          (group
           keep_when
           0
           (op <=)
           point
           (op |.|)
           y
           (op -)
           base_y
           (op &&)
           point
           (op |.|)
           y
           (op -)
           base_y
           (op <)
           data
           (op |.|)
           length
           (parens))
          (group
           keep_when
           (op !)
           data
           (brackets (group point (op |.|) y (op -) base_y))
           (brackets (group point (op |.|) x (op -) base_x)))
          (group
           data
           (brackets (group point (op |.|) y (op -) base_y))
           (brackets (group point (op |.|) x (op -) base_x))
           (op :=)
           #t)
          (group
           queue
           (op :=)
           List
           (op |.|)
           cons
           (parens (group point) (group queue)))))))))))
  (group
   fun
   calculate_bounds
   (parens
    (group instructions (op ::) List (op |.|) of (parens (group Instruction))))
   (block
    (group
     let
     (brackets
      (group mutable min_x)
      (group mutable max_x)
      (group mutable min_y)
      (group mutable max_y))
     (block (group (brackets (group 0) (group 0) (group 0) (group 0)))))
    (group
     fun
     update_min_max
     (parens (group pos))
     (block
      (group
       min_x
       (op :=)
       math
       (op |.|)
       min
       (parens (group min_x) (group pos (op |.|) x)))
      (group
       max_x
       (op :=)
       math
       (op |.|)
       max
       (parens (group max_x) (group pos (op |.|) x)))
      (group
       min_y
       (op :=)
       math
       (op |.|)
       min
       (parens (group min_y) (group pos (op |.|) y)))
      (group
       max_y
       (op :=)
       math
       (op |.|)
       max
       (parens (group max_y) (group pos (op |.|) y)))
      (group pos)))
    (group
     for
     values
     (parens
      (group
       current_position
       (op =)
       utils
       (op |.|)
       Point
       (parens (group 0) (group 0))))
     (parens (group instruction (block (group instructions))))
     (block
      (group
       update_min_max
       (parens
        (group
         current_position
         (op |.|)
         add
         (parens (group instruction (op |.|) delta (parens))))))))
    (group
     (brackets
      (group (brackets (group min_x) (group max_x)))
      (group (brackets (group min_y) (group max_y)))))))
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
       (brackets (group dir (op ::) ReadableString) (group no) (group color))
       (op =)
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group line) (group " ")))
      (group
       let
       dir
       (op =)
       match
       dir
       (op |.|)
       to_string
       (parens)
       (alts
        (block (group "R" (block (group (op |#'|) right))))
        (block (group "L" (block (group (op |#'|) left))))
        (block (group "U" (block (group (op |#'|) up))))
        (block (group "D" (block (group (op |#'|) down))))))
      (group let no (op =) String (op |.|) to_number (parens (group no)))
      (group
       let
       color
       (op ::)
       ReadableString
       (op =)
       racket
       (op |.|)
       substring
       (parens
        (group color)
        (group 1)
        (group color (op |.|) length (parens) (op -) 1)))
      (group
       Instruction
       (parens
        (group dir)
        (group no)
        (group color (op |.|) to_string (parens))))))))
  (group
   fun
   build_dig_map
   (parens
    (group instructions (op ::) List (op |.|) of (parens (group Instruction))))
   (block
    (group
     let
     (brackets
      (group (brackets (group min_x) (group max_x)))
      (group (brackets (group min_y) (group max_y))))
     (block (group calculate_bounds (parens (group instructions)))))
    (group
     def
     data
     (block
      (group
       Array
       (op |.|)
       make
       (parens (group max_y (op -) min_y (op +) 1) (group #f)))))
    (group
     for
     (parens (group i (block (group 0 (op ..) max_y (op -) min_y (op +) 1))))
     (block
      (group
       data
       (brackets (group i))
       (op :=)
       Array
       (op |.|)
       make
       (parens (group max_x (op -) min_x (op +) 1) (group #f)))))
    (group DigMap (parens (group data) (group min_x) (group min_y)))))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group let instructions (op =) parse_input (parens (group raw_input)))
    (group let dig_map (op =) build_dig_map (parens (group instructions)))
    (group
     for
     values
     (parens
      (group
       current_position
       (op =)
       utils
       (op |.|)
       Point
       (parens (group 0) (group 0))))
     (parens (group instruction (block (group instructions))))
     (block
      (group
       let
       delta
       (op =)
       Direction
       (op |.|)
       to_delta
       (parens (group instruction (op |.|) direction)))
      (group
       for
       values
       (parens (group current_position (op =) current_position))
       (parens
        (group i (block (group 0 (op ..) instruction (op |.|) distance))))
       (block
        (group
         let
         new_position
         (op =)
         current_position
         (op |.|)
         add
         (parens (group delta)))
        (group dig_map (brackets (group new_position)) (op :=) #t)
        (group new_position)))))
    (group dig_map (op |.|) fill_in_interior (parens))
    (group dig_map (op |.|) count_area (parens))))
  (group
   check
   (block (group solve_for_part1 (parens (group test_input))) (group #:is 62)))
  (group
   fun
   solve_for_part2
   (parens (group raw_input))
   (block
    (group let instructions (op =) parse_input (parens (group raw_input)))
    (group
     def
     values
     (parens (group _) (group vertices) (group perimeter))
     (block
      (group
       for
       values
       (parens
        (group
         current_position
         (op =)
         utils
         (op |.|)
         Point
         (parens (group 0) (group 0)))
        (group
         vertices
         (op =)
         (brackets (group utils (op |.|) Point (parens (group 0) (group 0)))))
        (group perimeter (op =) 0))
       (parens (group ins (block (group instructions))))
       (block
        (group
         let
         delta
         (op =)
         ins
         (op |.|)
         decode
         (parens)
         (op |.|)
         delta
         (parens))
        (group
         let
         new_position
         (op =)
         current_position
         (op |.|)
         add
         (parens (group delta)))
        (group
         values
         (parens
          (group new_position)
          (group
           List
           (op |.|)
           cons
           (parens (group new_position) (group vertices)))
          (group
           perimeter
           (op +)
           math
           (op |.|)
           abs
           (parens (group delta (op |.|) x))
           (op +)
           math
           (op |.|)
           abs
           (parens (group delta (op |.|) y)))))))))
    (group
     let
     List
     (op |.|)
     cons
     (parens (group prev_vertex) (group vertexes))
     (op =)
     vertices
     (op |.|)
     reverse
     (parens))
    (group
     let
     values
     (parens (group _) (group sum))
     (block
      (group
       for
       values
       (parens (group prev_vertex (op =) prev_vertex) (group sum (op =) 0))
       (parens (group vertex (block (group vertexes))))
       (block
        (group
         let
         new_sum
         (op =)
         sum
         (op +)
         (parens
          (group
           (parens (group prev_vertex (op |.|) x (op *) vertex (op |.|) y))
           (op -)
           (parens (group vertex (op |.|) x (op *) prev_vertex (op |.|) y)))))
        (group values (parens (group vertex) (group new_sum)))))))
    (group
     (parens (group 1/2))
     (op *)
     math
     (op |.|)
     abs
     (parens (group sum))
     (op +)
     perimeter
     (op /)
     2
     (op +)
     1)))
  (group
   check
   (block
    (group solve_for_part2 (parens (group test_input)))
    (group #:is 952408144115)))
  (group solve_for_part2 (parens (group input))))
