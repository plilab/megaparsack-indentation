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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 19)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "px{a<2006:qkq,m>2090:A,rfg}")
      (group "pv{a>1716:R,A}")
      (group "lnx{m>1548:A,A}")
      (group "rfg{s<537:gd,x>2440:R,A}")
      (group "qs{s>3448:A,lnx}")
      (group "qkq{x<1416:A,crn}")
      (group "crn{x>2662:A,R}")
      (group "in{s<1351:px,qqz}")
      (group "qqz{s>2770:qs,m<1801:hdj,R}")
      (group "gd{a>3333:R,R}")
      (group "hdj{m>838:A,pv}")
      (group "")
      (group "{x=787,m=2655,a=1222,s=2876}")
      (group "{x=1679,m=44,a=2067,s=496}")
      (group "{x=2036,m=264,a=79,s=2244}")
      (group "{x=2461,m=1339,a=466,s=291}")
      (group "{x=2127,m=1623,a=2188,s=1013}")))))
  (group
   class
   Range
   (parens (group start (op ::) Int) (group stop (op ::) Int))
   (block
    (group
     constructor
     (parens (group low) (group high))
     (block
      (group
       if
       high
       (op <)
       low
       (alts
        (block
         (group
          error
          (parens
           (group
            "attempted to create a range between "
            (op +&)
            low
            (op +&)
            " to "
            (op +&)
            high))))
        (block (group super (parens (group low) (group high))))))))
    (group method count (parens) (block (group stop (op -) start)))))
  (group
   fun
   split_range
   (parens (group r1 (op ::) Range) (group r2 (op ::) Range))
   (op ::)
   values
   (parens (group Range) (group List (op |.|) of (parens (group Range))))
   (block
    (group
     let
     overlap_start
     (op =)
     math
     (op |.|)
     max
     (parens (group r1 (op |.|) start) (group r2 (op |.|) start)))
    (group
     let
     overlap_stop
     (op =)
     math
     (op |.|)
     min
     (parens (group r1 (op |.|) stop) (group r2 (op |.|) stop)))
    (group
     let
     non_overlapping
     (block
      (group
       (parens
        (group
         if
         overlap_start
         (op >)
         r1
         (op |.|)
         start
         (alts
          (block
           (group
            (brackets
             (group
              Range
              (parens (group r1 (op |.|) start) (group overlap_start))))))
          (block (group (brackets))))))
       (op ++)
       (parens
        (group
         if
         overlap_start
         (op >)
         r2
         (op |.|)
         start
         (alts
          (block
           (group
            (brackets
             (group
              Range
              (parens (group r2 (op |.|) start) (group overlap_start))))))
          (block (group (brackets))))))
       (op ++)
       (parens
        (group
         if
         overlap_stop
         (op <)
         r1
         (op |.|)
         stop
         (alts
          (block
           (group
            (brackets
             (group
              Range
              (parens (group overlap_stop) (group r1 (op |.|) stop))))))
          (block (group (brackets))))))
       (op ++)
       (parens
        (group
         if
         overlap_stop
         (op <)
         r2
         (op |.|)
         stop
         (alts
          (block
           (group
            (brackets
             (group
              Range
              (parens (group overlap_stop) (group r2 (op |.|) stop))))))
          (block (group (brackets)))))))))
    (group
     values
     (parens
      (group Range (parens (group overlap_start) (group overlap_stop)))
      (group non_overlapping)))))
  (group
   check
   (block
    (group
     split_range
     (parens
      (group Range (parens (group 1) (group 10)))
      (group Range (parens (group 5) (group 15)))))
    (group
     #:is
     values
     (parens
      (group Range (parens (group 5) (group 10)))
      (group
       (brackets
        (group Range (parens (group 1) (group 5)))
        (group Range (parens (group 10) (group 15)))))))))
  (group
   check
   (block
    (group
     split_range
     (parens
      (group Range (parens (group 5) (group 15)))
      (group Range (parens (group 1) (group 10)))))
    (group
     #:is
     values
     (parens
      (group Range (parens (group 5) (group 10)))
      (group
       (brackets
        (group Range (parens (group 1) (group 5)))
        (group Range (parens (group 10) (group 15)))))))))
  (group
   check
   (block
    (group
     split_range
     (parens
      (group Range (parens (group 1) (group 10)))
      (group Range (parens (group 3) (group 6)))))
    (group
     #:is
     values
     (parens
      (group Range (parens (group 3) (group 6)))
      (group
       (brackets
        (group Range (parens (group 1) (group 3)))
        (group Range (parens (group 6) (group 10)))))))))
  (group
   check
   (block
    (group
     split_range
     (parens
      (group Range (parens (group 3) (group 6)))
      (group Range (parens (group 1) (group 10)))))
    (group
     #:is
     values
     (parens
      (group Range (parens (group 3) (group 6)))
      (group
       (brackets
        (group Range (parens (group 1) (group 3)))
        (group Range (parens (group 6) (group 10)))))))))
  (group
   fun
   disjoint_ranges
   (parens (group r1 (op ::) Range) (group r2 (op ::) Range))
   (block
    (group
     r1
     (op |.|)
     stop
     (op <=)
     r2
     (op |.|)
     start
     (op \|\|)
     r2
     (op |.|)
     stop
     (op <=)
     r1
     (op |.|)
     start)))
  (group
   class
   State
   (parens
    (group a (op ::) Range)
    (group m (op ::) Range)
    (group s (op ::) Range)
    (group x (op ::) Range))
   (block
    (group implements Indexable)
    (group
     method
     count
     (parens)
     (block
      (group
       a
       (op |.|)
       count
       (parens)
       (op *)
       m
       (op |.|)
       count
       (parens)
       (op *)
       s
       (op |.|)
       count
       (parens)
       (op *)
       x
       (op |.|)
       count
       (parens))))
    (group
     override
     method
     get
     (parens (group index))
     (block
      (group
       match
       index
       (alts
        (block (group "a" (block (group a))))
        (block (group "m" (block (group m))))
        (block (group "s" (block (group s))))
        (block (group "x" (block (group x))))
        (block
         (group
          (brackets (group "a") (group vl))
          (block
           (group State (parens (group vl) (group m) (group s) (group x))))))
        (block
         (group
          (brackets (group "m") (group vl))
          (block
           (group State (parens (group a) (group vl) (group s) (group x))))))
        (block
         (group
          (brackets (group "s") (group vl))
          (block
           (group State (parens (group a) (group m) (group vl) (group x))))))
        (block
         (group
          (brackets (group "x") (group vl))
          (block
           (group
            State
            (parens (group a) (group m) (group s) (group vl))))))))))))
  (group
   fun
   disjoint_states
   (parens (group s1 (op ::) State) (group s2 (op ::) State))
   (block
    (group
     disjoint_ranges
     (parens (group s1 (op |.|) a) (group s2 (op |.|) a))
     (op \|\|)
     disjoint_ranges
     (parens (group s1 (op |.|) m) (group s2 (op |.|) m))
     (op \|\|)
     disjoint_ranges
     (parens (group s1 (op |.|) s) (group s2 (op |.|) s))
     (op \|\|)
     disjoint_ranges
     (parens (group s1 (op |.|) x) (group s2 (op |.|) x)))))
  (group
   fun
   split_state
   (parens (group s1 (op ::) State) (group s2 (op ::) State))
   (block
    (group
     let
     values
     (parens (group a_overlap) (group a_non_overlap))
     (op =)
     split_range
     (parens (group s1 (op |.|) a) (group s2 (op |.|) a)))
    (group
     let
     values
     (parens (group m_overlap) (group m_non_overlap))
     (op =)
     split_range
     (parens (group s1 (op |.|) m) (group s2 (op |.|) m)))
    (group
     let
     values
     (parens (group s_overlap) (group s_non_overlap))
     (op =)
     split_range
     (parens (group s1 (op |.|) s) (group s2 (op |.|) s)))
    (group
     let
     values
     (parens (group x_overlap) (group x_non_overlap))
     (op =)
     split_range
     (parens (group s1 (op |.|) x) (group s2 (op |.|) x)))
    (group
     let
     s_with_a_non_overlap
     (block
      (group
       for
       List
       (parens (group a (block (group a_non_overlap))))
       (block
        (group
         each
         m
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group m_overlap) (group m_non_overlap)))))
        (group
         each
         s
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group s_overlap) (group s_non_overlap)))))
        (group
         each
         x
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group x_overlap) (group x_non_overlap)))))
        (group State (parens (group a) (group m) (group s) (group x)))))))
    (group
     let
     s_with_m_non_overlap
     (block
      (group
       for
       List
       (block
        (group each m (block (group m_non_overlap)))
        (group
         each
         s
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group s_overlap) (group s_non_overlap)))))
        (group
         each
         x
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group x_overlap) (group x_non_overlap)))))
        (group
         State
         (parens (group a_overlap) (group m) (group s) (group x)))))))
    (group
     let
     s_with_s_non_overlap
     (block
      (group
       for
       List
       (block
        (group each s (block (group s_non_overlap)))
        (group
         each
         x
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group x_overlap) (group x_non_overlap)))))
        (group
         State
         (parens (group a_overlap) (group m_overlap) (group s) (group x)))))))
    (group
     let
     s_with_x_non_overlap
     (block
      (group
       for
       List
       (block
        (group each x (block (group x_non_overlap)))
        (group
         State
         (parens
          (group a_overlap)
          (group m_overlap)
          (group s_overlap)
          (group x)))))))
    (group
     let
     result
     (block
      (group
       (brackets
        (group
         State
         (parens
          (group a_overlap)
          (group m_overlap)
          (group s_overlap)
          (group x_overlap))))
       (op ++)
       (parens (group s_with_a_non_overlap))
       (op ++)
       (parens (group s_with_m_non_overlap))
       (op ++)
       (parens (group s_with_s_non_overlap))
       (op ++)
       (parens (group s_with_x_non_overlap)))))
    (group result)))
  (group
   class
   Condition
   (parens (group var (op ::) String) (group number (op ::) Int))
   (block
    (group nonfinal)
    (group
     abstract
     method
     evaluate
     (parens
      (group map (op ::) Map (op |.|) of (parens (group String) (group Int))))
     (op ::)
     Boolean)
    (group
     abstract
     method
     evaluate_abstract
     (parens (group state (op ::) State))
     (op ::)
     Pair
     (op |.|)
     of
     (parens (group State) (group State))
     (op \|\|)
     False)
    (group
     constructor
     (parens (group var (op ::) ReadableString) (group number))
     (block
      (group
       super
       (parens
        (group var (op |.|) to_string (parens))
        (group String (op |.|) to_number (parens (group number)))))))))
  (group
   class
   Lt
   (parens)
   (block
    (group extends Condition)
    (group
     override
     method
     evaluate
     (parens (group map))
     (block (group map (brackets (group var)) (op <) number)))
    (group
     override
     method
     evaluate_abstract
     (parens (group map))
     (block
      (group let var_range (op =) map (brackets (group var)))
      (group
       if
       var_range
       (op |.|)
       start
       (op <)
       number
       (op &&)
       number
       (op <=)
       var_range
       (op |.|)
       stop
       (alts
        (block
         (group
          Pair
          (parens
           (group
            map
            (brackets
             (group
              (brackets
               (group var)
               (group
                Range
                (parens (group var_range (op |.|) start) (group number)))))))
           (group
            map
            (brackets
             (group
              (brackets
               (group var)
               (group
                Range
                (parens (group number) (group var_range (op |.|) stop))))))))))
        (block (group #f))))))))
  (group
   class
   Gt
   (parens)
   (block
    (group extends Condition)
    (group
     override
     method
     evaluate
     (parens (group map))
     (block (group map (brackets (group var)) (op >) number)))
    (group
     override
     method
     evaluate_abstract
     (parens (group map))
     (block
      (group let var_range (op =) map (brackets (group var)))
      (group
       if
       var_range
       (op |.|)
       start
       (op <=)
       number
       (op &&)
       number
       (op <)
       var_range
       (op |.|)
       stop
       (alts
        (block
         (group
          Pair
          (parens
           (group
            map
            (brackets
             (group
              (brackets
               (group var)
               (group
                Range
                (parens
                 (group number (op +) 1)
                 (group var_range (op |.|) stop)))))))
           (group
            map
            (brackets
             (group
              (brackets
               (group var)
               (group
                Range
                (parens
                 (group var_range (op |.|) start)
                 (group number (op +) 1))))))))))
        (block (group #f))))))))
  (group
   class
   Workflow
   (parens
    (group name (op ::) String)
    (group
     cases
     (op ::)
     List
     (op |.|)
     of
     (parens
      (group Pair (op |.|) of (parens (group Condition) (group String)))))
    (group default (op ::) String))
   (block
    (group
     method
     evaluate
     (parens (group map))
     (block
      (group
       recur
       loop
       (parens (group cases (op =) cases))
       (block
        (group
         match
         cases
         (alts
          (block (group (brackets) (block (group default))))
          (block
           (group
            List
            (op |.|)
            cons
            (parens
             (group Pair (parens (group cond) (group result)))
             (group cases))
            (block
             (group
              if
              cond
              (op |.|)
              evaluate
              (parens (group map))
              (alts
               (block (group result))
               (block (group loop (parens (group cases)))))))))))))))
    (group
     method
     evaluate_abstract
     (parens (group state) (group states (op =) (brackets)))
     (block
      (group
       recur
       loop
       (parens
        (group cases (op =) cases)
        (group states (op =) states)
        (group current_state (op =) state))
       (block
        (group
         match
         cases
         (alts
          (block
           (group
            (brackets)
            (block
             (group
              List
              (op |.|)
              cons
              (parens
               (group Pair (parens (group default) (group current_state)))
               (group states))))))
          (block
           (group
            List
            (op |.|)
            cons
            (parens
             (group Pair (parens (group cond) (group result)))
             (group cases))
            (block
             (group
              let
              cond_result
              (op =)
              cond
              (op |.|)
              evaluate_abstract
              (parens (group current_state)))
             (group
              if
              (op !)
              cond_result
              (alts
               (block
                (group
                 loop
                 (parens (group cases) (group states) (group current_state))))
               (block
                (group
                 let
                 Pair
                 (parens (group matched_state) (group remain_state))
                 (op =)
                 cond_result)
                (group
                 loop
                 (parens
                  (group cases)
                  (group
                   List
                   (op |.|)
                   cons
                   (parens
                    (group Pair (parens (group result) (group matched_state)))
                    (group states)))
                  (group remain_state)))))))))))))))))
  (group
   fun
   parse_inputs
   (parens (group inputs))
   (block
    (group
     for
     List
     (parens
      (group
       input
       (block
        (group
         utils
         (op |.|)
         string
         (op |.|)
         split_lines
         (parens (group inputs))))))
     (block
      (group
       let
       input
       (block
        (group
         racket
         (op |.|)
         substring
         (parens
          (group input)
          (group 1)
          (group input (op |.|) length (parens) (op -) 1)))))
      (group
       for
       Map
       (parens
        (group
         assignment
         (block
          (group
           utils
           (op |.|)
           string
           (op |.|)
           split
           (parens (group input) (group ","))))))
       (block
        (group
         let
         (brackets (group var (op ::) ReadableString) (group target))
         (block
          (group
           utils
           (op |.|)
           string
           (op |.|)
           split
           (parens (group assignment) (group "=")))))
        (group
         values
         (parens
          (group var (op |.|) to_string (parens))
          (group String (op |.|) to_number (parens (group target)))))))))))
  (group
   fun
   parse_workflows
   (parens (group workflows (op ::) ReadableString))
   (op ::)
   Map
   (op |.|)
   of
   (parens (group String) (group Workflow))
   (block
    (group
     for
     Map
     (parens
      (group
       workflow
       (block
        (group
         utils
         (op |.|)
         string
         (op |.|)
         split_lines
         (parens (group workflows))))))
     (block
      (group
       let
       (brackets (group name (op ::) ReadableString) (group contents))
       (op =)
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group workflow) (group "{")))
      (group
       let
       contents
       (op =)
       racket
       (op |.|)
       substring
       (parens
        (group contents)
        (group 0)
        (group contents (op |.|) length (parens) (op -) 1)))
      (group
       let
       values
       (parens (group contents) (group final_value))
       (block
        (group
         for
         values
         (parens
          (group contents (op =) (brackets))
          (group final_value (op =) #f))
         (parens
          (group
           operation
           (block
            (group
             utils
             (op |.|)
             string
             (op |.|)
             split
             (parens (group contents) (group ","))))))
         (block
          (group
           match
           utils
           (op |.|)
           string
           (op |.|)
           split
           (parens (group operation) (group ":"))
           (alts
            (block
             (group
              (brackets (group fv (op ::) ReadableString))
              (block
               (group
                values
                (parens
                 (group contents)
                 (group fv (op |.|) to_string (parens)))))))
            (block
             (group
              (brackets
               (group cond_expr)
               (group target (op ::) ReadableString))
              (block
               (group
                let
                cond_expr
                (block
                 (group
                  cond
                  (alts
                   (block
                    (group
                     racket
                     (op |.|)
                     string-contains?
                     (parens (group cond_expr) (group "<"))
                     (block
                      (group
                       let
                       (brackets (group var) (group number))
                       (block
                        (group
                         utils
                         (op |.|)
                         string
                         (op |.|)
                         split
                         (parens (group cond_expr) (group "<")))))
                      (group Lt (parens (group var) (group number))))))
                   (block
                    (group
                     racket
                     (op |.|)
                     string-contains?
                     (parens (group cond_expr) (group ">"))
                     (block
                      (group
                       let
                       (brackets (group var) (group number))
                       (block
                        (group
                         utils
                         (op |.|)
                         string
                         (op |.|)
                         split
                         (parens (group cond_expr) (group ">")))))
                      (group Gt (parens (group var) (group number))))))))))
               (group
                let
                contents
                (block
                 (group
                  List
                  (op |.|)
                  cons
                  (parens
                   (group
                    Pair
                    (parens
                     (group cond_expr)
                     (group target (op |.|) to_string (parens))))
                   (group contents)))))
               (group
                values
                (parens (group contents) (group final_value))))))))))))
      (group
       values
       (parens
        (group name)
        (group
         Workflow
         (parens
          (group name)
          (group contents (op |.|) reverse (parens))
          (group final_value)))))))))
  (group
   fun
   parse_input
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     (brackets (group workflows) (group inputs))
     (op =)
     utils
     (op |.|)
     string
     (op |.|)
     split
     (parens (group raw_input) (group "\n\n")))
    (group let workflows (op =) parse_workflows (parens (group workflows)))
    (group let inputs (op =) parse_inputs (parens (group inputs)))
    (group values (parens (group workflows) (group inputs)))))
  (group
   fun
   evaluate
   (parens
    (group
     pipeline
     (op ::)
     Map
     (op |.|)
     of
     (parens (group String) (group Workflow)))
    (group
     input
     (op ::)
     Map
     (op |.|)
     of
     (parens (group String) (group Number))))
   (block
    (group
     recur
     loop
     (parens (group state (op =) "in"))
     (block
      (group
       cond
       (alts
        (block (group state (op ==) "A" (block (group #t))))
        (block (group state (op ==) "R" (block (group #f))))
        (block
         (group
          #:else
          (block
           (group
            loop
            (parens
             (group
              pipeline
              (brackets (group state))
              (op |.|)
              evaluate
              (parens (group input))))))))))))))
  (group
   fun
   score
   (parens
    (group
     input
     (op ::)
     Map
     (op |.|)
     of
     (parens (group String) (group Number))))
   (block
    (group
     input
     (brackets (group "a"))
     (op +)
     input
     (brackets (group "m"))
     (op +)
     input
     (brackets (group "s"))
     (op +)
     input
     (brackets (group "x")))))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group
     let
     values
     (parens (group pipeline) (group inputs))
     (op =)
     parse_input
     (parens (group raw_input)))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (parens (group input (block (group inputs))))
     (block
      (group keep_when evaluate (parens (group pipeline) (group input)))
      (group sum (op +) score (parens (group input)))))))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input)))
    (group #:is 19114)))
  (group def result1 (block (group solve_for_part1 (parens (group input)))))
  (group
   fun
   add_to_state_values
   (parens (group state_values) (group key) (group state))
   (block
    (group
     cond
     (alts
      (block
       (group
        state_values
        (op |.|)
        has_key
        (parens (group key))
        (op &&)
        (op !)
        state_values
        (brackets (group key))
        (brackets (group state))
        (block
         (group
          state_values
          (op ++)
          (braces
           (group
            key
            (block
             (group
              state_values
              (brackets (group key))
              (op |.|)
              union
              (parens (group Set (parens (group state))))))))))))
      (block
       (group
        (op !)
        state_values
        (op |.|)
        has_key
        (parens (group key))
        (block
         (group
          state_values
          (op ++)
          (braces (group key (block (group Set (parens (group state))))))))))
      (block (group #:else (block (group state_values))))))))
  (group
   def
   initial_state
   (op =)
   State
   (parens
    (group Range (parens (group 1) (group 4001)))
    (group Range (parens (group 1) (group 4001)))
    (group Range (parens (group 1) (group 4001)))
    (group Range (parens (group 1) (group 4001)))))
  (group
   fun
   evaluate_abstract
   (parens
    (group
     pipeline
     (op ::)
     Map
     (op |.|)
     of
     (parens (group String) (group Workflow))))
   (block
    (group
     recur
     loop
     (parens
      (group
       state_values
       (op =)
       Map
       (braces
        (group "in" (block (group Set (braces (group initial_state)))))))
      (group
       keys
       (op =)
       (brackets (group Pair (parens (group "in") (group initial_state))))))
     (block
      (group
       let
       values
       (parens (group state_values) (group keys))
       (block
        (group
         for
         values
         (parens
          (group state_values (op =) state_values)
          (group states (op =) (brackets)))
         (parens
          (group Pair (parens (group key) (group state)) (block (group keys))))
         (block
          (group
           cond
           (alts
            (block
             (group
              key
              (op ==)
              "A"
              (block
               (group
                values
                (parens
                 (group
                  add_to_state_values
                  (parens (group state_values) (group "A") (group state)))
                 (group states))))))
            (block
             (group
              key
              (op ==)
              "R"
              (block
               (group
                values
                (parens
                 (group
                  add_to_state_values
                  (parens (group state_values) (group "R") (group state)))
                 (group states))))))
            (block
             (group
              #:else
              (block
               (group
                values
                (parens
                 (group state_values)
                 (group
                  pipeline
                  (brackets (group key))
                  (op |.|)
                  evaluate_abstract
                  (parens (group state) (group states))))))))))))))
      (group
       if
       keys
       (op ==)
       (brackets)
       (alts
        (block (group state_values))
        (block (group loop (parens (group state_values) (group keys))))))))))
  (group
   fun
   Set
   (op |.|)
   remove_all
   (parens (group s (op ::) Set) (group elts (op ::) List))
   (block
    (group
     for
     values
     (parens (group s (op =) s))
     (block
      (group each elt (block (group elts)))
      (group s (op |.|) remove (parens (group elt)))))))
  (group
   fun
   Set
   (op |.|)
   add_all
   (parens (group s (op ::) Set) (group elts (op ::) List))
   (block
    (group let (brackets (group elt) (group (op ...))) (block (group elts)))
    (group
     s
     (op |.|)
     union
     (parens (group Set (parens (group elt) (group (op ...))))))))
  (group
   fun
   simplify_states
   (parens (group states (op ::) Set (op |.|) of (parens (group State))))
   (block
    (group
     let
     values
     (parens (group states_to_remove) (group states_to_add))
     (block
      (group
       for
       values
       (parens
        (group states_to_remove (op =) #f)
        (group states_to_add (op =) #f))
       (block
        (group each s1 (block (group states)))
        (group each s2 (block (group states)))
        (group skip_when s1 (op ==) s2)
        (group keep_when (op !) disjoint_states (parens (group s1) (group s2)))
        (group final_when #t)
        (group
         values
         (parens
          (group (brackets (group s1) (group s2)))
          (group split_state (parens (group s1) (group s2)))))))))
    (group
     if
     states_to_remove
     (op &&)
     states_to_add
     (alts
      (block
       (group
        simplify_states
        (parens
         (group
          Set
          (op |.|)
          add_all
          (parens
           (group
            Set
            (op |.|)
            remove_all
            (parens (group states) (group states_to_remove)))
           (group states_to_add))))))
      (block (group states))))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input))
   (block
    (group
     let
     values
     (parens (group pipeline) (group inputs))
     (op =)
     parse_input
     (parens (group raw_input)))
    (group
     for
     values
     (parens (group sum (op =) 0))
     (parens
      (group
       state
       (block
        (group
         simplify_states
         (parens
          (group
           evaluate_abstract
           (parens (group pipeline))
           (brackets (group "A"))))))))
     (block (group sum (op +) state (op |.|) count (parens))))))
  (group
   check
   (block
    (group solve_for_part2 (parens (group test_input)))
    (group #:is 167409079868000))))
