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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 17)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "2413432311323")
      (group "3215453535623")
      (group "3255245654254")
      (group "3446585845452")
      (group "4546657867536")
      (group "1438598798454")
      (group "4457876987766")
      (group "3637877979653")
      (group "4654967986887")
      (group "4564679986453")
      (group "1224686865563")
      (group "2546548887735")
      (group "4322674655533")))))
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
         south
         (op \|\|)
         (op |#'|)
         west
         (op \|\|)
         (op |#'|)
         east)))))))
  (group
   fun
   parse_input
   (parens (group raw_input (op ::) ReadableString))
   (op ::)
   Matrix
   (block
    (group
     for
     Array
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
       for
       Array
       (parens (group char (block (group line))))
       (block
        (group
         String
         (op |.|)
         to_number
         (parens (group "" (op +&) char)))))))))
  (group
   class
   Grid
   (parens
    (group data (op ::) Matrix)
    (group WIDTH (op ::) Int)
    (group HEIGHT (op ::) Int))
   (block
    (group
     constructor
     (parens (group data (op ::) Matrix))
     (block
      (group
       super
       (parens
        (group data)
        (group data (brackets (group 0)) (op |.|) length (parens))
        (group data (op |.|) length (parens))))))))
  (group
   fun
   direction_to_delta
   (parens (group direction (op ::) Direction))
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
        (block (group utils (op |.|) Point (parens (group 0) (group -1))))))
      (block
       (group
        (op |#'|)
        south
        (block (group utils (op |.|) Point (parens (group 0) (group 1))))))
      (block
       (group
        (op |#'|)
        east
        (block (group utils (op |.|) Point (parens (group 1) (group 0))))))
      (block
       (group
        (op |#'|)
        west
        (block
         (group utils (op |.|) Point (parens (group -1) (group 0))))))))))
  (group
   annot
   (op |.|)
   macro
   (quotes (group Delta))
   (block
    (group
     (quotes
      (group
       converting
       (parens
        (group
         fun
         (parens (group dir (op ::) Direction))
         (op ::)
         utils
         (op |.|)
         Point
         (block (group direction_to_delta (parens (group dir)))))))))))
  (group
   fun
   turning_directions
   (parens (group direction (op ::) Direction))
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
         (group (brackets (group (op |#'|) west) (group (op |#'|) east))))))
      (block
       (group
        (op |#'|)
        east
        (block
         (group (brackets (group (op |#'|) north) (group (op |#'|) south))))))
      (block
       (group
        (op |#'|)
        south
        (block
         (group (brackets (group (op |#'|) east) (group (op |#'|) west))))))
      (block
       (group
        (op |#'|)
        west
        (block
         (group
          (brackets (group (op |#'|) south) (group (op |#'|) north))))))))))
  (group
   class
   State
   (parens
    (group WIDTH (op ::) Int)
    (group HEIGHT (op ::) Int)
    (group position (op ::) utils (op |.|) Point)
    (group direction (op ::) Direction)
    (group steps (op ::) Int))
   (block
    (group
     method
     valid_point
     (parens)
     (block
      (group
       0
       (op <=)
       position
       (op |.|)
       x
       (op &&)
       position
       (op |.|)
       x
       (op <)
       WIDTH
       (op &&)
       0
       (op <=)
       position
       (op |.|)
       y
       (op &&)
       position
       (op |.|)
       y
       (op <)
       HEIGHT)))
    (group
     method
     steps_in_range
     (parens (group low) (group high))
     (block (group low (op <) steps (op &&) steps (op <=) high)))
    (group
     method
     neighbours_internal
     (parens)
     (op ::)
     List
     (block
      (group
       let
       (brackets (group left_dir) (group right_dir))
       (block (group turning_directions (parens (group direction)))))
      (group
       (brackets
        (group
         State
         (parens
          (group WIDTH)
          (group HEIGHT)
          (group
           position
           (op |.|)
           add
           (parens (group direction (op ::) Delta)))
          (group direction)
          (group steps (op +) 1)))
        (group
         State
         (parens
          (group WIDTH)
          (group HEIGHT)
          (group position (op |.|) add (parens (group left_dir (op ::) Delta)))
          (group left_dir)
          (group 1)))
        (group
         State
         (parens
          (group WIDTH)
          (group HEIGHT)
          (group
           position
           (op |.|)
           add
           (parens (group right_dir (op ::) Delta)))
          (group right_dir)
          (group 1)))))))
    (group
     method
     neighbours
     (parens)
     (op ::)
     List
     (block
      (group
       for
       List
       (parens (group neighbour (block (group neighbours_internal (parens)))))
       (block
        (group skip_when (op !) neighbour (op |.|) valid_point (parens))
        (group
         skip_when
         (op !)
         neighbour
         (op |.|)
         steps_in_range
         (parens (group 0) (group 3)))
        (group neighbour)))))
    (group
     method
     ultra_neighbours_internal
     (parens)
     (op ::)
     List
     (block
      (group
       let
       (brackets (group left_dir) (group right_dir))
       (block (group turning_directions (parens (group direction)))))
      (group
       let
       forward_step
       (op =)
       State
       (parens
        (group WIDTH)
        (group HEIGHT)
        (group
         position
         (op |.|)
         add
         (parens (group (parens (group direction (op ::) Delta)))))
        (group direction)
        (group steps (op +) 1)))
      (group
       cond
       (alts
        (block
         (group
          steps
          (op <)
          4
          (block (group (brackets (group forward_step))))))
        (block
         (group
          4
          (op <=)
          steps
          (op &&)
          steps
          (op <=)
          9
          (block
           (group
            (brackets
             (group forward_step)
             (group
              State
              (parens
               (group WIDTH)
               (group HEIGHT)
               (group
                position
                (op |.|)
                add
                (parens (group left_dir (op ::) Delta)))
               (group left_dir)
               (group 1)))
             (group
              State
              (parens
               (group WIDTH)
               (group HEIGHT)
               (group
                position
                (op |.|)
                add
                (parens (group right_dir (op ::) Delta)))
               (group right_dir)
               (group 1))))))))
        (block
         (group
          steps
          (op ==)
          10
          (block
           (group
            (brackets
             (group
              State
              (parens
               (group WIDTH)
               (group HEIGHT)
               (group
                position
                (op |.|)
                add
                (parens (group left_dir (op ::) Delta)))
               (group left_dir)
               (group 1)))
             (group
              State
              (parens
               (group WIDTH)
               (group HEIGHT)
               (group
                position
                (op |.|)
                add
                (parens (group right_dir (op ::) Delta)))
               (group right_dir)
               (group 1))))))))))))
    (group
     method
     ultra_neighbours
     (parens)
     (op ::)
     List
     (block
      (group
       for
       List
       (parens
        (group neighbour (block (group ultra_neighbours_internal (parens)))))
       (block
        (group skip_when (op !) neighbour (op |.|) valid_point (parens))
        (group
         skip_when
         (op !)
         neighbour
         (op |.|)
         steps_in_range
         (parens (group 0) (group 10)))
        (group neighbour)))))))
  (group
   fun
   distance
   (parens (group x1) (group y1) (group x2) (group y2))
   (block
    (group let dx (op =) x2 (op -) x1)
    (group let dy (op =) y2 (op -) y1)
    (group
     math
     (op |.|)
     sqrt
     (parens (group dx (op *) dx (op +) dy (op *) dy)))))
  (group
   fun
   solve
   (parens (group grid (op ::) Grid))
   (block
    (group
     let
     initial_point
     (op =)
     State
     (parens
      (group grid (op |.|) WIDTH)
      (group grid (op |.|) HEIGHT)
      (group utils (op |.|) Point (parens (group 0) (group 0)))
      (group (op |#'|) east)
      (group 1)))
    (group let mutable queue (block (group (brackets (group initial_point)))))
    (group
     let
     heat_loss
     (block
      (group MutableMap (braces (group initial_point (block (group 0)))))))
    (group let node_cost (block (group MutableMap (braces))))
    (group let mutable target_point_found (op =) #f)
    (group
     fun
     cost_of_node
     (parens (group state (op ::) State))
     (block
      (group
       if
       node_cost
       (op |.|)
       has_key
       (parens (group state))
       (alts
        (block (group node_cost (brackets (group state))))
        (block
         (group
          let
          cost
          (op =)
          (op -)
          heat_loss
          (brackets (group state))
          (op -)
          distance
          (parens
           (group grid (op |.|) WIDTH (op -) 1)
           (group grid (op |.|) HEIGHT (op -) 1)
           (group state (op |.|) position (op |.|) x)
           (group state (op |.|) position (op |.|) y)))
         (group node_cost (brackets (group state)) (op :=) cost)
         (group cost))))))
    (group
     while
     (op !)
     target_point_found
     (block
      (group
       let
       (brackets (group state) (group next) (group (op ...)))
       (block (group queue)))
      (group queue (op :=) (brackets (group next) (group (op ...))))
      (group let state_heat_loss (op =) heat_loss (brackets (group state)))
      (group
       for
       (parens
        (group neighbour (block (group state (op |.|) neighbours (parens)))))
       (block
        (group
         let
         neighbour_cost
         (op =)
         state_heat_loss
         (op +)
         grid
         (op |.|)
         data
         (brackets (group neighbour (op |.|) position (op |.|) y))
         (brackets (group neighbour (op |.|) position (op |.|) x)))
        (group
         cond
         (alts
          (block
           (group
            (parens
             (group
              heat_loss
              (op |.|)
              has_key
              (parens (group neighbour))
              (op &&)
              heat_loss
              (brackets (group neighbour))
              (op >)
              neighbour_cost))
            (op \|\|)
            (op !)
            heat_loss
            (op |.|)
            has_key
            (parens (group neighbour))
            (block
             (group
              heat_loss
              (brackets (group neighbour))
              (op :=)
              neighbour_cost)
             (group
              queue
              (op :=)
              utils
              (op |.|)
              list
              (op |.|)
              insert_into_sorted
              (parens
               (group neighbour)
               (group queue)
               (group #:key (block (group cost_of_node))))))))
          (block (group #:else (block (group #<void>))))))
        (group
         when
         neighbour
         (op |.|)
         position
         (op |.|)
         x
         (op ==)
         grid
         (op |.|)
         WIDTH
         (op -)
         1
         (op &&)
         neighbour
         (op |.|)
         position
         (op |.|)
         y
         (op ==)
         grid
         (op |.|)
         HEIGHT
         (op -)
         1
         (alts (block (group target_point_found (op :=) neighbour))))))))
    (group heat_loss (brackets (group target_point_found)))))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     grid
     (op =)
     Grid
     (parens (group parse_input (parens (group raw_input)))))
    (group solve (parens (group grid)))))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input)))
    (group #:is 102)))
  (group
   fun
   ultra_solve
   (parens
    (group grid (op ::) Grid)
    (group #:start_dir (block (group start_dir (op =) (op |#'|) east))))
   (block
    (group
     let
     initial_point
     (op =)
     State
     (parens
      (group grid (op |.|) WIDTH)
      (group grid (op |.|) HEIGHT)
      (group utils (op |.|) Point (parens (group 0) (group 0)))
      (group start_dir)
      (group 1)))
    (group
     let
     heat_loss
     (block
      (group MutableMap (braces (group initial_point (block (group 0)))))))
    (group
     let
     queue
     (block
      (group
       heap
       (op |.|)
       make-heap
       (parens
        (group
         fun
         (parens (group x) (group y))
         (block
          (group x (brackets (group 0)) (op <=) y (brackets (group 0)))))))))
    (group
     heap
     (op |.|)
     heap-add!
     (parens (group queue) (group (brackets (group 0) (group initial_point)))))
    (group
     recur
     loop
     (parens)
     (block
      (group
       let
       (brackets (group _) (group state))
       (op =)
       heap
       (op |.|)
       heap-min
       (parens (group queue)))
      (group heap (op |.|) heap-remove-min! (parens (group queue)))
      (group
       cond
       (alts
        (block
         (group
          state
          (op |.|)
          position
          (op |.|)
          x
          (op ==)
          grid
          (op |.|)
          WIDTH
          (op -)
          1
          (op &&)
          state
          (op |.|)
          position
          (op |.|)
          y
          (op ==)
          grid
          (op |.|)
          HEIGHT
          (op -)
          1
          (op &&)
          state
          (op |.|)
          steps
          (op >=)
          4
          (block (group heat_loss (brackets (group state))))))
        (block
         (group
          #:else
          (block
           (group
            let
            state_heat_loss
            (op =)
            heat_loss
            (brackets (group state)))
           (group
            let
            neighbours
            (op =)
            state
            (op |.|)
            ultra_neighbours
            (parens))
           (group
            for
            (parens (group neighbour (block (group neighbours))))
            (block
             (group
              let
              neighbour_cost
              (op =)
              state_heat_loss
              (op +)
              grid
              (op |.|)
              data
              (brackets (group neighbour (op |.|) position (op |.|) y))
              (brackets (group neighbour (op |.|) position (op |.|) x)))
             (group
              when
              (op !)
              heat_loss
              (op |.|)
              has_key
              (parens (group neighbour))
              (op \|\|)
              neighbour_cost
              (op <)
              heat_loss
              (brackets (group neighbour))
              (alts
               (block
                (group
                 heat_loss
                 (brackets (group neighbour))
                 (op :=)
                 neighbour_cost)
                (group
                 heap
                 (op |.|)
                 heap-add!
                 (parens
                  (group queue)
                  (group
                   (brackets (group neighbour_cost) (group neighbour))))))))))
           (group loop (parens)))))))))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     grid
     (op =)
     Grid
     (parens (group parse_input (parens (group raw_input)))))
    (group
     math
     (op |.|)
     min
     (parens
      (group ultra_solve (parens (group grid)))
      (group ultra_solve (parens (group grid) (group (op |#'|) east)))))))
  (group solve_for_part2 (parens (group input))))
