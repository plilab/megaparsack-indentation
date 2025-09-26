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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 10)))))
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
   let
   test_input
   (block
    (group
     multiline
     (block
      (group ".....")
      (group ".S-7.")
      (group ".|.|.")
      (group ".L-J.")
      (group ".....")))))
  (group
   let
   test_input2
   (block
    (group
     multiline
     (block
      (group "..F7.")
      (group ".FJ|.")
      (group "SJ.L7")
      (group "|F--J")
      (group "LJ...")))))
  (group
   fun
   MutableSet
   (op |.|)
   pop
   (parens (group set (op ::) MutableSet))
   (block
    (group
     let
     element
     (block
      (group
       for
       values
       (parens (group result (op =) #f))
       (parens (group s (block (group set))))
       (block (group final_when #t) (group s)))))
    (group set (brackets (group element)) (op :=) #f)
    (group element)))
  (group
   fun
   List
   (op |.|)
   contains
   (parens (group ls) (group elt))
   (block
    (group
     match
     ls
     (alts
      (block (group (brackets) (block (group #f))))
      (block
       (group
        List
        (op |.|)
        cons
        (parens (group hd) (group tail))
        (block
         (group
          if
          hd
          (op ==)
          elt
          (alts
           (block (group #t))
           (block
            (group
             List
             (op |.|)
             contains
             (parens (group tail) (group elt)))))))))))))
  (group
   fun
   add_directed_edge
   (parens (group graph) (group c1 (op ::) Point) (group c2 (op ::) Point))
   (block
    (group
     if
     graph
     (op |.|)
     has_key
     (parens (group c1))
     (alts
      (block
       (group graph (brackets (group c1)) (brackets (group c2)) (op :=) #t))
      (block
       (group
        graph
        (brackets (group c1))
        (op :=)
        MutableSet
        (parens (group c2))))))))
  (group
   fun
   add_edge
   (parens (group graph) (group c1) (group c2))
   (block
    (group add_directed_edge (parens (group graph) (group c1) (group c2)))
    (group add_directed_edge (parens (group graph) (group c2) (group c1)))))
  (group
   class
   Pipe
   (parens
    (group north (op ::) Boolean)
    (group east (op ::) Boolean)
    (group south (op ::) Boolean)
    (group west (op ::) Boolean)))
  (group
   fun
   Pipe
   (op |.|)
   of_char
   (parens (group char))
   (block
    (group
     match
     char
     (alts
      (block
       (group
        #\S
        (block
         (group Pipe (parens (group #t) (group #t) (group #t) (group #t))))))
      (block
       (group
        #\.
        (block
         (group Pipe (parens (group #f) (group #f) (group #f) (group #f))))))
      (block
       (group
        #\|
        (block
         (group Pipe (parens (group #t) (group #f) (group #t) (group #f))))))
      (block
       (group
        #\-
        (block
         (group Pipe (parens (group #f) (group #t) (group #f) (group #t))))))
      (block
       (group
        #\L
        (block
         (group Pipe (parens (group #t) (group #t) (group #f) (group #f))))))
      (block
       (group
        #\J
        (block
         (group Pipe (parens (group #t) (group #f) (group #f) (group #t))))))
      (block
       (group
        #\7
        (block
         (group Pipe (parens (group #f) (group #f) (group #t) (group #t))))))
      (block
       (group
        #\F
        (block
         (group
          Pipe
          (parens (group #f) (group #t) (group #t) (group #f))))))))))
  (group
   fun
   handle_edge
   (parens
    (group lines)
    (group graph)
    (group coord)
    (group char)
    (group #:delta (block (group delta (op =) 1))))
   (block
    (group
     fun
     get_pipe
     (parens (group position))
     (block
      (group let coord (op =) position (op |.|) div (parens (group delta)))
      (group
       cond
       (alts
        (block
         (group
          0
          (op <=)
          coord
          (op |.|)
          y
          (op &&)
          coord
          (op |.|)
          y
          (op <)
          lines
          (op |.|)
          length
          (parens)
          (op &&)
          0
          (op <=)
          coord
          (op |.|)
          x
          (op &&)
          coord
          (op |.|)
          x
          (op <)
          lines
          (brackets (group coord (op |.|) y))
          (op |.|)
          length
          (parens)
          (block
           (group
            Pipe
            (op |.|)
            of_char
            (parens
             (group
              lines
              (brackets (group coord (op |.|) y))
              (brackets (group coord (op |.|) x))))))))
        (block
         (group
          #:else
          (block
           (group
            Pipe
            (parens (group #f) (group #f) (group #f) (group #f))))))))))
    (group
     match
     char
     (alts
      (block (group #\. (block (group #<void>))))
      (block
       (group
        c
        (block
         (group let pipe (op =) Pipe (op |.|) of_char (parens (group c)))
         (group
          when
          pipe
          (alts
           (block
            (group
             when
             pipe
             (op |.|)
             north
             (op &&)
             get_pipe
             (parens
              (group
               coord
               (op |.|)
               north
               (parens (group #:delta (block (group delta))))))
             (op |.|)
             south
             (alts
              (block
               (group
                add_edge
                (parens
                 (group graph)
                 (group coord)
                 (group
                  coord
                  (op |.|)
                  north
                  (parens (group #:delta (block (group delta))))))))))
            (group
             when
             pipe
             (op |.|)
             east
             (op &&)
             get_pipe
             (parens
              (group
               coord
               (op |.|)
               east
               (parens (group #:delta (block (group delta))))))
             (op |.|)
             west
             (alts
              (block
               (group
                add_edge
                (parens
                 (group graph)
                 (group coord)
                 (group
                  coord
                  (op |.|)
                  east
                  (parens (group #:delta (block (group delta))))))))))
            (group
             when
             pipe
             (op |.|)
             south
             (op &&)
             get_pipe
             (parens
              (group
               coord
               (op |.|)
               south
               (parens (group #:delta (block (group delta))))))
             (op |.|)
             north
             (alts
              (block
               (group
                add_edge
                (parens
                 (group graph)
                 (group coord)
                 (group
                  coord
                  (op |.|)
                  south
                  (parens (group #:delta (block (group delta))))))))))
            (group
             when
             pipe
             (op |.|)
             west
             (op &&)
             get_pipe
             (parens
              (group
               coord
               (op |.|)
               west
               (parens (group #:delta (block (group delta))))))
             (op |.|)
             east
             (alts
              (block
               (group
                add_edge
                (parens
                 (group graph)
                 (group coord)
                 (group
                  coord
                  (op |.|)
                  west
                  (parens
                   (group #:delta (block (group delta))))))))))))))))))))
  (group
   fun
   parse_input
   (parens
    (group raw_input (op ::) ReadableString)
    (group #:delta (block (group delta (op =) 1))))
   (block
    (group let graph (op =) MutableMap (parens))
    (group
     let
     lines
     (op =)
     utils
     (op |.|)
     string
     (op |.|)
     split_lines
     (parens (group raw_input)))
    (group let mutable start_pos (op =) #f)
    (group
     for
     (block
      (group
       each
       (block
        (group line (block (group lines)))
        (group i (block (group 0 (op ..))))))
      (group
       each
       (block
        (group char (block (group line)))
        (group j (block (group 0 (op ..))))))
      (group
       if
       char
       (op ==)
       #\S
       (alts
        (block
         (group
          start_pos
          (op :=)
          Point
          (parens (group j (op *) delta) (group i (op *) delta))))
        (block
         (group
          handle_edge
          (parens
           (group lines)
           (group graph)
           (group Point (parens (group j (op *) delta) (group i (op *) delta)))
           (group char)
           (group #:delta (block (group delta))))))))))
    (group values (parens (group graph) (group start_pos)))))
  (group
   fun
   get_connected
   (parens (group graph) (group node))
   (block
    (group
     if
     graph
     (op |.|)
     has_key
     (parens (group node))
     (alts
      (block (group graph (brackets (group node))))
      (block (group MutableSet (braces)))))))
  (group
   fun
   shortest_path
   (parens (group graph) (group start_pos))
   (block
    (group
     let
     costs
     (block (group MutableMap (braces (group start_pos (block (group 0)))))))
    (group let parents (block (group MutableMap (braces))))
    (group let mutable queue (block (group (brackets (group start_pos)))))
    (group
     fun
     update_cost
     (parens (group node) (group new_cost))
     (block
      (group
       cond
       (alts
        (block
         (group
          costs
          (op |.|)
          has_key
          (parens (group node))
          (op &&)
          costs
          (brackets (group node))
          (op >)
          new_cost
          (block
           (group costs (brackets (group node)) (op :=) new_cost)
           (group #t))))
        (block
         (group
          (op !)
          costs
          (op |.|)
          has_key
          (parens (group node))
          (block
           (group costs (brackets (group node)) (op :=) new_cost)
           (group #t))))
        (block (group #:else (block (group #f))))))))
    (group
     fun
     remove_node
     (parens (group nodes) (group neighbour))
     (block
      (group
       for
       List
       (block
        (group each node (block (group nodes)))
        (group skip_when node (op ==) neighbour)
        (group node)))))
    (group
     fun
     insert_into_queue
     (parens (group get_cost) (group neighbour) (group queue))
     (block
      (group
       match
       queue
       (alts
        (block (group (brackets) (block (group (brackets (group neighbour))))))
        (block
         (group
          (brackets (group node) (group tail) (group (op ...)))
          when
          get_cost
          (parens (group node))
          (op >)
          get_cost
          (parens (group neighbour))
          (block
           (group
            let
            (brackets (group new_tail) (group (op ...)))
            (block
             (group
              remove_node
              (parens
               (group (brackets (group node) (group tail) (group (op ...))))
               (group neighbour)))))
           (group
            (brackets (group neighbour) (group new_tail) (group (op ...)))))))
        (block
         (group
          (brackets (group node) (group tail) (group (op ...)))
          (block
           (group
            List
            (op |.|)
            cons
            (parens
             (group node)
             (group
              insert_into_queue
              (parens
               (group get_cost)
               (group neighbour)
               (group (brackets (group tail) (group (op ...)))))))))))))))
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
       (parens (group node) (group tail))
       (op =)
       queue)
      (group queue (op :=) tail)
      (group
       let
       new_cost
       (block (group costs (brackets (group node)) (op +) 1)))
      (group
       for
       (parens
        (group
         neighbour
         (block (group get_connected (parens (group graph) (group node))))))
       (block
        (group
         when
         update_cost
         (parens (group neighbour) (group new_cost))
         (alts
          (block
           (group
            queue
            (op :=)
            insert_into_queue
            (parens
             (group
              fun
              (parens (group node))
              (block (group costs (brackets (group node)))))
             (group neighbour)
             (group queue)))
           (group parents (brackets (group neighbour)) (op :=) node))))))))
    (group values (parens (group costs) (group parents)))))
  (group
   fun
   find_cycle
   (parens (group graph) (group start_pos))
   (block
    (group class Path (parens (group current) (group path) (group seen)))
    (group
     let
     (braces (group start_neighbour) (group (op ...)))
     (op =)
     get_connected
     (parens (group graph) (group start_pos))
     (op |.|)
     snapshot
     (parens))
    (group let mutable parent (op =) MutableMap (braces))
    (group
     let
     mutable
     queue
     (op =)
     (brackets
      (group
       Path
       (parens
        (group start_neighbour)
        (group (brackets (group start_pos)))
        (group Set (braces (group start_neighbour)))))
      (group (op ...))))
    (group def mutable cycle_found (op =) #f)
    (group
     for
     (parens
      (group
       start_neighbour
       (block (group get_connected (parens (group graph) (group start_pos))))))
     (block
      (group parent (brackets (group start_neighbour)) (op :=) start_pos)))
    (group
     while
     queue
     (op !=)
     (brackets)
     (op &&)
     (op !)
     cycle_found
     (block
      (group
       let
       (brackets
        (group Path (parens (group pos) (group path) (group seen)))
        (group rest)
        (group (op ...)))
       (op =)
       queue)
      (group queue (op :=) (brackets (group rest) (group (op ...))))
      (group
       let
       neighbours
       (op =)
       get_connected
       (parens (group graph) (group pos)))
      (group
       for
       (parens (group neighbour (block (group neighbours))))
       (block
        (group
         skip_when
         parent
         (op |.|)
         has_key
         (parens (group pos))
         (op &&)
         parent
         (brackets (group pos))
         (op ==)
         neighbour)
        (group skip_when seen (brackets (group neighbour)))
        (group
         let
         entry
         (op =)
         Path
         (parens
          (group neighbour)
          (group List (op |.|) cons (parens (group pos) (group path)))
          (group
           seen
           (op |.|)
           union
           (parens (group Set (braces (group neighbour)))))))
        (group queue (op :=) queue (op ++) (brackets (group entry)))
        (group parent (brackets (group neighbour)) (op :=) pos)
        (group
         when
         get_connected
         (parens (group graph) (group neighbour))
         (brackets (group start_pos))
         (alts (block (group cycle_found (op :=) entry))))))))
    (group
     List
     (op |.|)
     cons
     (parens
      (group cycle_found (op |.|) current)
      (group cycle_found (op |.|) path))
     (op |.|)
     reverse
     (parens))))
  (group
   fun
   find_connected
   (parens (group is_valid_node) (group start_pos))
   (block
    (group
     let
     seen_points
     (block (group MutableSet (braces (group start_pos)))))
    (group let mutable queue (op =) (brackets (group start_pos)))
    (group
     fun
     unseen_empty_node
     (parens (group node (op ::) Point))
     (block
      (group
       is_valid_node
       (parens (group node))
       (op &&)
       (op !)
       seen_points
       (brackets (group node)))))
    (group
     while
     queue
     (op !=)
     (brackets)
     (block
      (group
       let
       (brackets (group node) (group tail) (group (op ...)))
       (block (group queue)))
      (group queue (op :=) (brackets (group tail) (group (op ...))))
      (group
       when
       unseen_empty_node
       (parens (group node (op |.|) north (parens)))
       (alts
        (block
         (group
          queue
          (op :=)
          List
          (op |.|)
          cons
          (parens (group node (op |.|) north (parens)) (group queue)))
         (group
          seen_points
          (brackets (group node (op |.|) north (parens)))
          (op :=)
          #t))))
      (group
       when
       unseen_empty_node
       (parens (group node (op |.|) east (parens)))
       (alts
        (block
         (group
          queue
          (op :=)
          List
          (op |.|)
          cons
          (parens (group node (op |.|) east (parens)) (group queue)))
         (group
          seen_points
          (brackets (group node (op |.|) east (parens)))
          (op :=)
          #t))))
      (group
       when
       unseen_empty_node
       (parens (group node (op |.|) south (parens)))
       (alts
        (block
         (group
          queue
          (op :=)
          List
          (op |.|)
          cons
          (parens (group node (op |.|) south (parens)) (group queue)))
         (group
          seen_points
          (brackets (group node (op |.|) south (parens)))
          (op :=)
          #t))))
      (group
       when
       unseen_empty_node
       (parens (group node (op |.|) west (parens)))
       (alts
        (block
         (group
          queue
          (op :=)
          List
          (op |.|)
          cons
          (parens (group node (op |.|) west (parens)) (group queue)))
         (group
          seen_points
          (brackets (group node (op |.|) west (parens)))
          (op :=)
          #t))))))
    (group seen_points)))
  (group
   fun
   interpolate_path
   (parens
    (group
     List
     (op |.|)
     cons
     (parens (group start) (group path))
     (op ::)
     List
     (op |.|)
     of
     (parens (group Point))))
   (block
    (group
     fun
     loop
     (parens (group current) (group rest))
     (block
      (group
       match
       rest
       (alts
        (block
         (group
          (brackets)
          (block
           (group
            when
            start
            (op |.|)
            sub
            (parens (group current))
            (op |.|)
            sum
            (parens)
            (op !=)
            2
            (op &&)
            start
            (op |.|)
            sub
            (parens (group current))
            (op |.|)
            sum
            (parens)
            (op !=)
            -2
            (alts
             (block
              (group
               println
               (parens (group start (op |.|) sub (parens (group current))))))))
           (group
            (brackets
             (group
              current
              (op |.|)
              add
              (parens
               (group
                start
                (op |.|)
                sub
                (parens (group current))
                (op |.|)
                div
                (parens (group 2))))))))))
        (block
         (group
          (brackets (group head) (group tail) (group (op ...)))
          (block
           (group
            when
            head
            (op |.|)
            sub
            (parens (group current))
            (op |.|)
            sum
            (parens)
            (op !=)
            2
            (op &&)
            head
            (op |.|)
            sub
            (parens (group current))
            (op |.|)
            sum
            (parens)
            (op !=)
            -2
            (alts
             (block
              (group
               println
               (parens (group head (op |.|) sub (parens (group current))))))))
           (group
            let
            current_interp
            (block
             (group
              current
              (op |.|)
              add
              (parens
               (group
                head
                (op |.|)
                sub
                (parens (group current))
                (op |.|)
                div
                (parens (group 2)))))))
           (group
            let
            (brackets (group new_tail) (group (op ...)))
            (block
             (group
              loop
              (parens
               (group head)
               (group (brackets (group tail) (group (op ...))))))))
           (group
            (brackets
             (group current_interp)
             (group head)
             (group new_tail)
             (group (op ...)))))))))))
    (group
     List
     (op |.|)
     cons
     (parens (group start) (group loop (parens (group start) (group path)))))))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     def
     values
     (parens (group graph) (group start_pos))
     (block (group parse_input (parens (group raw_input)))))
    (group
     def
     values
     (parens (group costs) (group parents))
     (block (group shortest_path (parens (group graph) (group start_pos)))))
    (group
     def
     cycle
     (op =)
     find_cycle
     (parens (group graph) (group start_pos)))
    (group
     for
     values
     (parens (group max_cost (op =) #f))
     (parens (group node (block (group cycle))))
     (block
      (group
       cond
       (alts
        (block
         (group (op !) max_cost (block (group costs (brackets (group node))))))
        (block
         (group
          costs
          (brackets (group node))
          (op >)
          max_cost
          (block (group costs (brackets (group node))))))
        (block (group #:else (block (group max_cost))))))))))
  (group
   check
   (block (group solve_for_part1 (parens (group test_input))) (group #:is 4)))
  (group
   check
   (block (group solve_for_part1 (parens (group test_input2))) (group #:is 8)))
  (group def result1 (op =) solve_for_part1 (parens (group input)))
  (group
   fun
   solve_for_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     def
     MAX_X
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split_lines
       (parens (group raw_input))
       (brackets (group 0))
       (op |.|)
       length
       (parens)
       (op *)
       2)))
    (group
     def
     MAX_Y
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split_lines
       (parens (group raw_input))
       (op |.|)
       length
       (parens)
       (op *)
       2)))
    (group
     def
     values
     (parens (group graph) (group start_pos))
     (block
      (group
       parse_input
       (parens (group raw_input) (group #:delta (block (group 2)))))))
    (group
     def
     values
     (parens (group costs) (group parents))
     (block (group shortest_path (parens (group graph) (group start_pos)))))
    (group
     def
     (brackets (group cycle) (group (op ...)))
     (op =)
     interpolate_path
     (parens (group find_cycle (parens (group graph) (group start_pos)))))
    (group
     def
     path_points
     (block (group Set (braces (group cycle) (group (op ...))))))
    (group
     fun
     in_range
     (parens (group p (op ::) Point))
     (block
      (group
       0
       (op <=)
       p
       (op |.|)
       x
       (op &&)
       p
       (op |.|)
       x
       (op <=)
       MAX_X
       (op &&)
       0
       (op <=)
       p
       (op |.|)
       y
       (op &&)
       p
       (op |.|)
       y
       (op <=)
       MAX_Y)))
    (group
     fun
     is_valid_node
     (parens (group node (op ::) Point))
     (block
      (group
       in_range
       (parens (group node))
       (op &&)
       (op !)
       path_points
       (brackets (group node)))))
    (group
     def
     contained_points
     (block
      (group
       find_connected
       (parens
        (group is_valid_node)
        (group
         Point
         (parens
          (group start_pos (op |.|) x)
          (group start_pos (op |.|) y (op +) 1)))))))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each x (block (group 0 (op ..) MAX_X (op /) 2)))
      (group each y (block (group 0 (op ..) MAX_Y (op /) 2)))
      (group
       if
       contained_points
       (brackets (group Point (parens (group x (op *) 2) (group y (op *) 2))))
       (alts (block (group sum (op +) 1)) (block (group sum))))))))
  (group
   check
   (block (group solve_for_part2 (parens (group test_input))) (group #:is 17)))
  (group let result2 (op =) solve_for_part2 (parens (group input))))
