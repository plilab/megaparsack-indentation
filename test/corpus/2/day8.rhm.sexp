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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 8)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "RL")
      (group "")
      (group "AAA = (BBB, CCC)")
      (group "BBB = (DDD, EEE)")
      (group "CCC = (ZZZ, GGG)")
      (group "DDD = (DDD, DDD)")
      (group "EEE = (EEE, EEE)")
      (group "GGG = (GGG, GGG)")
      (group "ZZZ = (ZZZ, ZZZ)")))))
  (group
   def
   test_input2
   (block
    (group
     multiline
     (block
      (group "LLR")
      (group "")
      (group "AAA = (BBB, BBB)")
      (group "BBB = (AAA, ZZZ)")
      (group "ZZZ = (ZZZ, ZZZ)")))))
  (group
   def
   test_input3
   (block
    (group
     multiline
     (block
      (group "LR")
      (group "")
      (group "11A = (11B, XXX)")
      (group "11B = (XXX, 11Z)")
      (group "11Z = (11B, XXX)")
      (group "22A = (22B, XXX)")
      (group "22B = (22C, 22C)")
      (group "22C = (22Z, 22Z)")
      (group "22Z = (22B, 22B)")
      (group "XXX = (XXX, XXX)")))))
  (group class Direction (parens) (block (group nonfinal)))
  (group class Left (parens) (block (group extends Direction)))
  (group class Right (parens) (block (group extends Direction)))
  (group
   fun
   parse_instructions
   (parens (group str (op ::) ReadableString))
   (op ::)
   List
   (op |.|)
   of
   (parens (group Direction))
   (block
    (group
     for
     List
     (parens (group char (block (group str))))
     (block
      (group
       match
       char
       (alts
        (block (group #\R (block (group Right (parens)))))
        (block (group #\L (block (group Left (parens)))))))))))
  (group
   check
   (block
    (group parse_instructions (parens (group "RL")))
    (group #:is (brackets (group Right (parens)) (group Left (parens))))))
  (group
   check
   (block
    (group parse_instructions (parens (group "LLR")))
    (group
     #:is
     (brackets
      (group Left (parens))
      (group Left (parens))
      (group Right (parens))))))
  (group
   fun
   parse_mapping
   (parens (group str (op ::) ReadableString))
   (block
    (group
     let
     (brackets (group lhs) (group rhs))
     (op =)
     utils
     (op |.|)
     string
     (op |.|)
     trim
     (op |.|)
     map
     (parens
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group str) (group "=")))))
    (group
     let
     rhs
     (op =)
     racket
     (op |.|)
     substring
     (parens
      (group rhs)
      (group 1)
      (group rhs (op |.|) length (parens) (op -) 1)))
    (group
     let
     (brackets (group l) (group r))
     (op =)
     utils
     (op |.|)
     string
     (op |.|)
     trim
     (op |.|)
     map
     (parens
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group rhs) (group ",")))))
    (group
     Pair
     (parens (group lhs) (group Pair (parens (group l) (group r)))))))
  (group
   check
   (block
    (group parse_mapping (parens (group "AAA = (BBB, CCC)")))
    (group
     #:is
     Pair
     (parens
      (group "AAA")
      (group Pair (parens (group "BBB") (group "CCC")))))))
  (group
   fun
   parse_input
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     (brackets
      (group instruction_list)
      (group _)
      (group mapping)
      (group (op ...)))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split_lines
       (parens (group raw_input)))))
    (group
     let
     instructions
     (op =)
     parse_instructions
     (parens (group instruction_list)))
    (group
     let
     (brackets (group Pair (parens (group lhs) (group rhs))) (group (op ...)))
     (op =)
     (brackets
      (group parse_mapping (parens (group mapping)))
      (group (op ...))))
    (group
     let
     graph
     (op =)
     (braces (group lhs (block (group rhs))) (group (op ...))))
    (group values (parens (group instructions) (group graph)))))
  (group
   fun
   solve_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     values
     (parens (group instructions) (group graph))
     (block (group parse_input (parens (group raw_input)))))
    (group let ins_len (block (group instructions (op |.|) length (parens))))
    (group let mutable count (block (group 0)))
    (group let mutable current (block (group "AAA")))
    (group
     while
     current
     (op !=)
     "ZZZ"
     (block
      (group let ind (op =) count mod ins_len)
      (group
       let
       Pair
       (parens (group left) (group right))
       (block (group graph (brackets (group current)))))
      (group count (op :=) count (op +) 1)
      (group
       current
       (op :=)
       block
       (block
        (group
         match
         instructions
         (brackets (group ind))
         (alts
          (block (group Left (parens) (block (group left))))
          (block (group Right (parens) (block (group right))))))))))
    (group count)))
  (group
   check
   (block (group solve_part1 (parens (group test_input))) (group #:is 2)))
  (group
   check
   (block (group solve_part1 (parens (group test_input2))) (group #:is 6)))
  (group let result1 (op =) solve_part1 (parens (group input)))
  (group
   fun
   find_start_nodes
   (parens
    (group
     map
     (op ::)
     Map
     (op |.|)
     of
     (parens
      (group String)
      (group Pair (op |.|) of (parens (group String) (group String))))))
   (op ::)
   Array
   (op |.|)
   of
   (parens (group String))
   (block
    (group
     for
     Array
     (parens (group key (block (group map (op |.|) keys (parens)))))
     (block
      (group
       skip_when
       (op !)
       (parens
        (group
         racket
         (op |.|)
         string-suffix?
         (parens (group key) (group "A")))))
      (group key)))))
  (group
   fun
   are_all_nodes_completed
   (parens (group states (op ::) Array (op |.|) of (parens (group String))))
   (block
    (group
     for
     values
     (parens (group result (op =) #t))
     (block
      (group each state (block (group states)))
      (group
       skip_when
       racket
       (op |.|)
       string-suffix?
       (parens (group state) (group "Z")))
      (group break_when (op !) result)
      (group #f)))))
  (group
   check
   (block
    (group
     are_all_nodes_completed
     (parens (group Array (parens (group "AZ") (group "1Z") (group "2Z")))))
    (group #:is #t)))
  (group
   check
   (block
    (group
     are_all_nodes_completed
     (parens (group Array (parens (group "AZ") (group "1A") (group "2Z")))))
    (group #:is #f)))
  (group
   fun
   gcd_inner
   (parens (group a) (group b))
   (block
    (group
     if
     b
     (op ==)
     0
     (alts
      (block (group a))
      (block (group gcd_inner (parens (group b) (group a mod b))))))))
  (group
   fun
   (alts
    (block
     (group
      gcd
      (parens (group a) (group b))
      (block (group gcd_inner (parens (group a) (group b))))))
    (block
     (group
      gcd
      (parens (group a) (group b) (group c) (group (op ...)))
      (block
       (group
        gcd
        (parens
         (group gcd_inner (parens (group a) (group b)))
         (group c)
         (group (op ...)))))))))
  (group
   fun
   lcm_inner
   (parens (group a) (group b))
   (block
    (group
     (parens (group a (op /) gcd (parens (group a) (group b))))
     (op *)
     b)))
  (group
   fun
   (alts
    (block
     (group
      lcm
      (parens (group a) (group b))
      (block (group lcm_inner (parens (group a) (group b))))))
    (block
     (group
      lcm
      (parens (group a) (group b) (group c) (group (op ...)))
      (block
       (group
        lcm
        (parens
         (group lcm_inner (parens (group a) (group b)))
         (group c)
         (group (op ...)))))))))
  (group
   fun
   (alts
    (block
     (group
      calculate_lcms
      (parens
       (group
        reps
        (op ::)
        List
        (op |.|)
        of
        (parens (group Set (op |.|) of (parens (group Int))))))
      (block
       (group
        match
        reps
        (alts
         (block (group (brackets) (block (group #f))))
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group head) (group reps))
           (block
            (group
             for
             values
             (parens (group min (op =) #f))
             (block
              (group each rep (block (group head (op |.|) to_list (parens))))
              (group
               let
               lcm
               (block
                (group calculate_lcms (parens (group rep) (group reps)))))
              (group
               if
               (op !)
               min
               (alts
                (block (group lcm))
                (block
                 (group
                  math
                  (op |.|)
                  min
                  (parens (group lcm) (group min))))))))))))))))
    (block
     (group
      calculate_lcms
      (parens (group c_lcm) (group reps))
      (block
       (group
        match
        reps
        (alts
         (block (group (brackets) (block (group c_lcm))))
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group head) (group reps))
           (block
            (group
             for
             values
             (parens (group min (op =) #f))
             (block
              (group each rep (block (group head (op |.|) to_list (parens))))
              (group
               let
               lcm
               (block
                (group
                 calculate_lcms
                 (parens
                  (group lcm (parens (group c_lcm) (group rep)))
                  (group reps)))))
              (group
               if
               (op !)
               min
               (alts
                (block (group lcm))
                (block
                 (group
                  math
                  (op |.|)
                  min
                  (parens (group lcm) (group min))))))))))))))))))
  (group
   fun
   solve_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     values
     (parens (group instructions) (group graph))
     (block (group parse_input (parens (group raw_input)))))
    (group let ins_len (block (group instructions (op |.|) length (parens))))
    (group let current (block (group find_start_nodes (parens (group graph)))))
    (group
     let
     node_ranges
     (block
      (group
       for
       List
       (parens
        (group i (block (group 0 (op ..) current (op |.|) length (parens)))))
       (block
        (group
         let
         mutable
         current_state
         (block (group current (brackets (group i)))))
        (group let mutable count (block (group 0)))
        (group let seen (block (group MutableSet (parens))))
        (group let mutable complete (block (group MutableSet (parens))))
        (group
         let
         mutable
         pos_summary
         (block
          (group
           Pair
           (parens (group count mod ins_len) (group current_state)))))
        (group
         while
         (op !)
         seen
         (brackets (group pos_summary))
         (block
          (group seen (brackets (group pos_summary)) (op :=) #t)
          (group let ind (op =) count mod ins_len)
          (group
           let
           Pair
           (parens (group left) (group right))
           (block (group graph (brackets (group current_state)))))
          (group count (op :=) count (op +) 1)
          (group
           current_state
           (op :=)
           block
           (block
            (group
             match
             instructions
             (brackets (group ind))
             (alts
              (block (group Left (parens) (block (group left))))
              (block (group Right (parens) (block (group right))))))))
          (group
           pos_summary
           (op :=)
           Pair
           (parens (group count mod ins_len) (group current_state)))
          (group
           when
           racket
           (op |.|)
           string-suffix?
           (parens (group current_state) (group "Z"))
           (alts
            (block (group complete (brackets (group count)) (op :=) #t))))))
        (group complete (op |.|) snapshot (parens))))))
    (group calculate_lcms (parens (group node_ranges)))))
  (group
   check
   (block (group solve_part2 (parens (group test_input3))) (group #:is 6)))
  (group let result2 (op =) solve_part2 (parens (group input))))
