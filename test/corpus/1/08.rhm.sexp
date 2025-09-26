'(multi
  (group
   import
   (block
    (group lib (parens (group "racket/base.rkt")))
    (group "util/advent_of_code.rhm" as aoc)
    (group "util/misc.rhm" as util)
    (group "util/parsec.rhm" as p)))
  (group
   util
   (op |.|)
   example_input
   (parens
    (group test_input1)
    (group
     (brackets
      (group "RL")
      (group "\n")
      (group "\n")
      (group "AAA = (BBB, CCC)")
      (group "\n")
      (group "BBB = (DDD, EEE)")
      (group "\n")
      (group "CCC = (ZZZ, GGG)")
      (group "\n")
      (group "DDD = (DDD, DDD)")
      (group "\n")
      (group "EEE = (EEE, EEE)")
      (group "\n")
      (group "GGG = (GGG, GGG)")
      (group "\n")
      (group "ZZZ = (ZZZ, ZZZ)")
      (group (parens (group "\n")))))))
  (group
   util
   (op |.|)
   example_input
   (parens
    (group test_input2)
    (group
     (brackets
      (group "LLR")
      (group "\n")
      (group "\n")
      (group "AAA = (BBB, BBB)")
      (group "\n")
      (group "BBB = (AAA, ZZZ)")
      (group "\n")
      (group "ZZZ = (ZZZ, ZZZ)")
      (group (parens (group "\n")))))))
  (group
   fun
   Map
   (op |.|)
   merge
   (parens (group maps (op ::) List (op |.|) of (parens (group Map))))
   (op :~)
   Map
   (block
    (group
     for
     values
     (parens (group v (op =) (braces)))
     (block (group each m (block (group maps))) (group v (op ++) m)))))
  (group
   annot
   (op |.|)
   macro
   (quotes (group Direction))
   (block
    (group
     (quotes
      (group matching (parens (group (op |#'|) L (op \|\|) (op |#'|) R)))))))
  (group
   class
   DesertMap
   (parens
    (group directions (op ::) Array (op |.|) of (parens (group Direction)))
    (group
     nodes
     (op ::)
     Map
     (op |.|)
     of
     (parens
      (group String)
      (group Pair (op |.|) of (parens (group String) (group String))))))
   (block
    (group
     method
     is_final
     (parens (group s (op :~) String))
     (block (group s (brackets (group 2)) (op ==) #\Z)))
    (group
     method
     measure_path
     (parens (group start))
     (block
      (group
       def
       values
       (parens (group count) (group _))
       (block
        (group
         for
         values
         (parens (group count (op =) 0) (group current (op =) start))
         (block
          (group each i (block (group 0 (op ..))))
          (group break_when is_final (parens (group current)))
          (group
           values
           (parens
            (group count (op +) 1)
            (group next_node (parens (group i) (group current)))))))))
      (group count)))
    (group
     method
     measure_path2
     (parens)
     (block
      (group
       def
       counts
       (block
        (group
         for
         List
         (block
          (group
           each
           n
           (op :~)
           String
           (block (group nodes (op |.|) keys (parens))))
          (group keep_when n (brackets (group 2)) (op ==) #\A)
          (group measure_path (parens (group n)))))))
      (group base (op |.|) lcm (parens (group (op &) counts)))))
    (group
     method
     next_node
     (parens (group i (op :~) NonnegInt) (group node (op :~) String))
     (block
      (group
       match
       directions
       (brackets (group i mod directions (op |.|) length (parens)))
       (alts
        (block
         (group
          (op |#'|)
          L
          (block (group nodes (brackets (group node)) (op |.|) first))))
        (block
         (group
          (op |#'|)
          R
          (block (group nodes (brackets (group node)) (op |.|) rest))))))))))
  (group
   operator
   a_p
   (op <\|>)
   b_p
   (block (group p (op |.|) choice (parens (group a_p) (group b_p)))))
  (group
   fun
   char_val_p
   (parens (group str (op ::) String) (group val))
   (block
    (group
     p
     (op |.|)
     try
     (parens
      (group
       p
       (op |.|)
       parse_sequence
       (block
        (group p (op |.|) char (parens (group str (brackets (group 0)))))
        (group p (op |.|) pure (parens (group val)))))))))
  (group
   def
   dir_p
   (block
    (group
     char_val_p
     (parens (group "L") (group (op |#'|) L))
     (op <\|>)
     char_val_p
     (parens (group "R") (group (op |#'|) R)))))
  (group
   def
   name_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group a (op =) p (op |.|) any)
      (group b (op =) p (op |.|) any)
      (group c (op =) p (op |.|) any)
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         util
         (op |.|)
         list_to_string
         (parens (group (brackets (group a) (group b) (group c)))))))))))
  (group
   def
   node_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group n (op =) name_p)
      (group p (op |.|) spaces)
      (group p (op |.|) char (parens (group #\=)))
      (group p (op |.|) spaces)
      (group p (op |.|) char (parens (group #\()))
      (group l (op =) name_p)
      (group p (op |.|) char (parens (group #\,)))
      (group p (op |.|) spaces)
      (group r (op =) name_p)
      (group p (op |.|) char (parens (group #\))))
      (group p (op |.|) spaces)
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         (braces
          (group n (block (group Pair (parens (group l) (group r)))))))))))))
  (group
   def
   input_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group dirs (op =) p (op |.|) many1 (parens (group dir_p)))
      (group p (op |.|) spaces)
      (group nodes (op =) p (op |.|) many1 (parens (group node_p)))
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         DesertMap
         (parens
          (group Array (parens (group (op &) dirs)))
          (group Map (op |.|) merge (parens (group nodes)))))))))))
  (group
   fun
   run1
   (parens (group input))
   (block
    (group
     def
     values
     (parens (group m (op :~) DesertMap) (group (brackets)))
     (op =)
     p
     (op |.|)
     parse_string
     (parens (group input_p) (group input)))
    (group m (op |.|) measure_path (parens (group "AAA")))))
  (group
   check
   (block
    (group run1 (parens (group test_input1)) #:is 2)
    (group run1 (parens (group test_input2)) #:is 6)))
  (group
   module
   part1
   (block
    (group
     run1
     (parens
      (group
       aoc
       (op |.|)
       fetch_input
       (parens
        (group aoc (op |.|) find_session (parens))
        (group 2023)
        (group 8)))))))
  (group
   util
   (op |.|)
   example_input
   (parens
    (group test_input3)
    (group
     (brackets
      (group "LR")
      (group "\n")
      (group "\n")
      (group "11A = (11B, XXX)")
      (group "\n")
      (group "11B = (XXX, 11Z)")
      (group "\n")
      (group "11Z = (11B, XXX)")
      (group "\n")
      (group "22A = (22B, XXX)")
      (group "\n")
      (group "22B = (22C, 22C)")
      (group "\n")
      (group "22C = (22Z, 22Z)")
      (group "\n")
      (group "22Z = (22B, 22B)")
      (group "\n")
      (group "XXX = (XXX, XXX)")
      (group (parens (group "\n")))))))
  (group
   fun
   run2
   (parens (group input))
   (block
    (group
     def
     values
     (parens (group m (op :~) DesertMap) (group (brackets)))
     (op =)
     p
     (op |.|)
     parse_string
     (parens (group input_p) (group input)))
    (group m (op |.|) measure_path2 (parens))))
  (group check (block (group run2 (parens (group test_input3)) #:is 6)))
  (group
   module
   part2
   (block
    (group
     run2
     (parens
      (group
       aoc
       (op |.|)
       fetch_input
       (parens
        (group aoc (op |.|) find_session (parens))
        (group 2023)
        (group 8))))))))
