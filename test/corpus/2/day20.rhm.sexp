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
   annot
   (op |.|)
   macro
   (quotes (group Pulse))
   (block
    (group
     (quotes
      (group
       matching
       (parens (group (op |#'|) low (op \|\|) (op |#'|) high)))))))
  (group
   annot
   (op |.|)
   macro
   (quotes (group Configuration))
   (block
    (group
     (quotes
      (group
       Map
       (op |.|)
       of
       (parens
        (group String)
        (group
         Pair
         (op |.|)
         of
         (parens
          (group Module)
          (group List (op |.|) of (parens (group String)))))))))))
  (group
   def
   input
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 20)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "broadcaster -> a, b, c")
      (group "%a -> b")
      (group "%b -> c")
      (group "%c -> inv")
      (group "&inv -> a")))))
  (group
   def
   test_input2
   (block
    (group
     multiline
     (block
      (group "broadcaster -> a")
      (group "%a -> inv, con")
      (group "&inv -> b")
      (group "%b -> con")
      (group "&con -> output")))))
  (group
   class
   Module
   (parens)
   (block
    (group nonfinal)
    (group
     abstract
     method
     process
     (parens (group from (op ::) String) (group pulse (op ::) Pulse))
     (op ::)
     Pair
     (op |.|)
     of
     (parens (group Pulse) (group Module))
     (op \|\|)
     False)))
  (group
   class
   FlipFlop
   (parens (group is_on (op ::) Boolean))
   (block
    (group extends Module)
    (group
     override
     method
     process
     (parens (group from (op ::) String) (group pulse (op ::) Pulse))
     (block
      (group
       match
       pulse
       (alts
        (block (group (op |#'|) high (block (group #f))))
        (block
         (group
          (op |#'|)
          low
          (block
           (group
            if
            is_on
            (alts
             (block
              (group
               Pair
               (parens
                (group (op |#'|) low)
                (group FlipFlop (parens (group #f))))))
             (block
              (group
               Pair
               (parens
                (group (op |#'|) high)
                (group FlipFlop (parens (group #t)))))))))))))))))
  (group
   class
   Conjunction
   (parens
    (group
     input_memory
     (op ::)
     Map
     (op |.|)
     of
     (parens (group String) (group Pulse))))
   (block
    (group extends Module)
    (group
     override
     method
     process
     (parens (group from (op ::) String) (group pulse (op ::) Pulse))
     (block
      (group
       let
       new_input_memory
       (block
        (group
         input_memory
         (op ++)
         Map
         (braces (group from (block (group pulse)))))))
      (group
       let
       all_high
       (block
        (group
         for
         values
         (parens (group result (op =) #t))
         (parens
          (group
           values
           (parens (group k) (group v))
           (block (group new_input_memory))))
         (block
          (group break_when (op !) result)
          (group
           match
           v
           (alts
            (block (group (op |#'|) low (block (group #f))))
            (block (group (op |#'|) high (block (group #t))))))))))
      (group
       if
       all_high
       (alts
        (block
         (group
          Pair
          (parens
           (group (op |#'|) low)
           (group Conjunction (parens (group new_input_memory))))))
        (block
         (group
          Pair
          (parens
           (group (op |#'|) high)
           (group Conjunction (parens (group new_input_memory))))))))))))
  (group
   class
   Broadcast
   (parens)
   (block
    (group extends Module)
    (group
     override
     method
     process
     (parens (group from (op ::) String) (group pulse (op ::) Pulse))
     (block (group Pair (parens (group pulse) (group Broadcast (parens))))))))
  (group
   fun
   parse_input
   (parens (group raw_input (op ::) ReadableString))
   (op ::)
   Configuration
   (block
    (group let component_map (block (group MutableMap (braces))))
    (group let output_map (block (group MutableMap (braces))))
    (group
     for
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
       (brackets (group spec (op ::) ReadableString) (group targets))
       (op =)
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group line) (group " -> ")))
      (group
       let
       targets
       (op =)
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
         split
         (parens (group targets) (group ", ")))))
      (group
       cond
       (alts
        (block
         (group
          spec
          (brackets (group 0))
          (op ==)
          #\%
          (block
           (group
            let
            name
            (op ::)
            ReadableString
            (op =)
            racket
            (op |.|)
            substring
            (parens
             (group spec)
             (group 1)
             (group spec (op |.|) length (parens))))
           (group
            component_map
            (brackets (group name (op |.|) to_string (parens)))
            (op :=)
            FlipFlop
            (parens (group #f)))
           (group
            output_map
            (brackets (group name (op |.|) to_string (parens)))
            (op :=)
            targets))))
        (block
         (group
          spec
          (brackets (group 0))
          (op ==)
          #\&
          (block
           (group
            let
            name
            (op ::)
            ReadableString
            (op =)
            racket
            (op |.|)
            substring
            (parens
             (group spec)
             (group 1)
             (group spec (op |.|) length (parens))))
           (group
            component_map
            (brackets (group name (op |.|) to_string (parens)))
            (op :=)
            Conjunction
            (parens (group Map (braces))))
           (group
            output_map
            (brackets (group name (op |.|) to_string (parens)))
            (op :=)
            targets))))
        (block
         (group
          #:else
          (block
           (group
            component_map
            (brackets (group spec (op |.|) to_string (parens)))
            (op :=)
            Broadcast
            (parens))
           (group
            output_map
            (brackets (group spec (op |.|) to_string (parens)))
            (op :=)
            targets))))))))
    (group
     for
     (parens (group key (block (group output_map (op |.|) keys (parens)))))
     (block
      (group each output (block (group output_map (brackets (group key)))))
      (group
       when
       component_map
       (op |.|)
       has_key
       (parens (group output))
       (alts
        (block
         (group
          match
          component_map
          (brackets (group output))
          (alts
           (block
            (group
             c
             (op ::)
             Conjunction
             (block
              (group
               component_map
               (brackets (group output))
               (op :=)
               Conjunction
               (parens
                (group
                 c
                 (op |.|)
                 input_memory
                 (op ++)
                 Map
                 (braces (group key (block (group (op |#'|) low))))))))))
           (block (group _ (block (group #<void>)))))))))))
    (group
     for
     Map
     (parens (group key (block (group component_map (op |.|) keys (parens)))))
     (block
      (group
       values
       (parens
        (group key)
        (group
         Pair
         (parens
          (group component_map (brackets (group key)))
          (group output_map (brackets (group key)))))))))))
  (group
   fun
   evaluate
   (parens
    (group
     queue
     (op ::)
     List
     (op |.|)
     of
     (parens
      (group
       Pair
       (op |.|)
       of
       (parens
        (group Pair (op |.|) of (parens (group String) (group String)))
        (group Pulse)))))
    (group configuration (op ::) Configuration))
   (block
    (group
     let
     values
     (parens (group new_queue) (group new_configuration))
     (block
      (group
       for
       values
       (parens
        (group new_queue (op =) (brackets))
        (group configuration (op =) configuration))
       (parens
        (group
         Pair
         (parens
          (group Pair (parens (group author) (group target)))
          (group pulse))
         (block (group queue))))
       (block
        (group
         skip_when
         (op !)
         configuration
         (op |.|)
         has_key
         (parens (group target)))
        (group
         let
         Pair
         (parens (group module) (group outputs))
         (block (group configuration (brackets (group target)))))
        (group
         let
         process_result
         (op =)
         module
         (op |.|)
         process
         (parens (group author) (group pulse)))
        (group
         if
         process_result
         (alts
          (block
           (group
            let
            Pair
            (parens (group pulse) (group new_module))
            (block (group process_result)))
           (group
            let
            new_pulses
            (block
             (group
              for
              List
              (parens (group output (block (group outputs))))
              (block
               (group
                Pair
                (parens
                 (group Pair (parens (group target) (group output)))
                 (group pulse)))))))
           (group
            let
            new_configuration
            (op =)
            configuration
            (op ++)
            (braces
             (group
              target
              (block
               (group Pair (parens (group new_module) (group outputs)))))))
           (group
            values
            (parens
             (group new_pulses (op |.|) reverse (parens) (op ++) new_queue)
             (group new_configuration))))
          (block
           (group
            values
            (parens (group new_queue) (group configuration))))))))))
    (group
     values
     (parens
      (group new_queue (op |.|) reverse (parens))
      (group new_configuration)))))
  (group
   fun
   fold_over_evaluate
   (parens
    (group acc)
    (group f)
    (group queue)
    (group config)
    (group
     #:pred
     (block
      (group
       pred
       (op =)
       fun
       (parens (group acc) (group queue) (group config))
       (block (group queue (op ==) (brackets)))))))
   (block
    (group
     if
     pred
     (parens (group acc) (group queue) (group config))
     (alts
      (block (group values (parens (group acc) (group config))))
      (block
       (group
        let
        acc
        (op =)
        f
        (parens (group acc) (group queue) (group config)))
       (group
        let
        values
        (parens (group queue) (group config))
        (op =)
        evaluate
        (parens (group queue) (group config)))
       (group
        fold_over_evaluate
        (parens
         (group acc)
         (group f)
         (group queue)
         (group config)
         (group #:pred (block (group pred))))))))))
  (group
   let
   init_queue
   (op =)
   (brackets
    (group
     Pair
     (parens
      (group Pair (parens (group "input") (group "broadcaster")))
      (group (op |#'|) low)))))
  (group
   class
   SignalCount
   (parens (group no_low (op ::) Int) (group no_high (op ::) Int))
   (block
    (group
     constructor
     (alts
      (block
       (group (parens) (block (group super (parens (group 0) (group 0))))))
      (block
       (group
        (parens (group low) (group high))
        (block (group super (parens (group low) (group high))))))))
    (group
     method
     process
     (parens
      (group
       ls
       (op ::)
       List
       (op |.|)
       of
       (parens
        (group
         Pair
         (op |.|)
         of
         (parens
          (group Pair (op |.|) of (parens (group String) (group String)))
          (group Pulse))))))
     (block
      (group
       for
       values
       (parens (group acc (op =) this))
       (parens
        (group Pair (parens (group _) (group pulse)) (block (group ls))))
       (block
        (group
         match
         pulse
         (alts
          (block
           (group
            (op |#'|)
            low
            (block
             (group
              SignalCount
              (parens
               (group acc (op |.|) no_low (op +) 1)
               (group acc (op |.|) no_high))))))
          (block
           (group
            (op |#'|)
            high
            (block
             (group
              SignalCount
              (parens
               (group acc (op |.|) no_low)
               (group acc (op |.|) no_high (op +) 1))))))))))))))
  (group
   fun
   run_cycle
   (parens (group config))
   (op ::)
   values
   (parens (group SignalCount) (group Configuration))
   (block
    (group
     fold_over_evaluate
     (parens
      (group SignalCount (parens))
      (group
       fun
       (parens (group acc) (group queue) (group config))
       (block (group acc (op |.|) process (parens (group queue)))))
      (group init_queue)
      (group config)))))
  (group
   fun
   run_cycle_w_single_rx
   (parens (group config))
   (op ::)
   Configuration
   (op \|\|)
   False
   (block
    (group let mutable rx_found (op =) #f)
    (group
     fun
     check_for_single_rx
     (parens (group acc) (group queue) (group config))
     (block
      (group
       let
       rx_targets
       (block
        (group
         for
         List
         (parens
          (group
           Pair
           (parens
            (group Pair (parens (group _) (group target)))
            (group pulse))
           (block (group queue))))
         (block (group keep_when target (op ==) "rx") (group pulse)))))
      (group
       match
       rx_targets
       (alts
        (block
         (group
          (brackets (group (op |#'|) low))
          (block (group rx_found (op :=) #t) (group #t))))
        (block (group _ (block (group queue (op ==) (brackets)))))))))
    (group
     let
     values
     (parens (group _) (group new_config))
     (block
      (group
       fold_over_evaluate
       (parens
        (group #<void>)
        (group
         fun
         (parens (group #<void>) (group queue) (group config))
         (block (group #<void>)))
        (group init_queue)
        (group config)
        (group #:pred (block (group check_for_single_rx)))))))
    (group if rx_found (alts (block (group #f)) (block (group new_config))))))
  (group
   fun
   repeat_and_count
   (parens (group config) (group #:till (block (group till (op =) 1000))))
   (block
    (group let mutable no_low (block (group 0)))
    (group let mutable no_high (block (group 0)))
    (group
     for
     values
     (parens (group config (op =) config))
     (parens (group i (block (group 0 (op ..) till))))
     (block
      (group
       let
       values
       (parens (group count) (group config))
       (op =)
       run_cycle
       (parens (group config)))
      (group no_low (op :=) no_low (op +) count (op |.|) no_low)
      (group no_high (op :=) no_high (op +) count (op |.|) no_high)
      (group config)))
    (group no_low (op *) no_high)))
  (group
   fun
   repeat_till_rx
   (parens (group config))
   (block
    (group
     recur
     loop
     (parens (group config (op =) config) (group step (op =) 1))
     (block
      (group
       let
       new_config
       (op =)
       run_cycle_w_single_rx
       (parens (group config)))
      (group
       if
       new_config
       (alts
        (block (group loop (parens (group new_config) (group step (op +) 1))))
        (block (group step))))))))
  (group
   fun
   repeat_till_cycle
   (parens (group config))
   (block
    (group let seen_states (block (group MutableMap (braces))))
    (group let signal_counts_at_step (block (group MutableMap (braces))))
    (group
     let
     values
     (parens (group final_step) (group loop_back))
     (block
      (group
       recur
       loop
       (parens (group config (op =) config) (group step (op =) 1))
       (block
        (group
         let
         values
         (parens (group signal_count) (group config))
         (block (group run_cycle (parens (group config)))))
        (group
         if
         seen_states
         (op |.|)
         has_key
         (parens (group config))
         (alts
          (block
           (group
            values
            (parens
             (group step)
             (group seen_states (brackets (group config))))))
          (block
           (group
            signal_counts_at_step
            (brackets (group step))
            (op :=)
            signal_count)
           (group seen_states (brackets (group config)) (op :=) step)
           (group loop (parens (group config) (group step (op +) 1))))))))))
    (group
     values
     (parens
      (group loop_back)
      (group final_step (op -) loop_back)
      (group signal_counts_at_step (op |.|) snapshot (parens))))))
  (group
   fun
   find_total_in_repeat
   (parens (group config) (group #:till (block (group till (op =) 1000))))
   (block
    (group
     let
     values
     (parens
      (group cycle_start)
      (group cycle_len)
      (group signal_counts_at_step))
     (block (group repeat_till_cycle (parens (group config)))))
    (group let mutable no_low (op =) 0)
    (group let mutable no_high (op =) 0)
    (group
     for
     (parens (group i (block (group 1 (op ..) cycle_start))))
     (block
      (group
       no_low
       (op :=)
       no_low
       (op +)
       signal_counts_at_step
       (brackets (group i))
       (op |.|)
       no_low)
      (group
       no_high
       (op :=)
       no_high
       (op +)
       signal_counts_at_step
       (brackets (group i))
       (op |.|)
       no_high)))
    (group
     let
     no_repeats
     (op =)
     (parens (group till (op -) cycle_start (op +) 1))
     div
     cycle_len)
    (group
     for
     (parens
      (group
       i
       (block (group cycle_start (op ..) cycle_start (op +) cycle_len))))
     (block
      (group
       no_low
       (op :=)
       no_low
       (op +)
       signal_counts_at_step
       (brackets (group i))
       (op |.|)
       no_low
       (op *)
       no_repeats)
      (group
       no_high
       (op :=)
       no_high
       (op +)
       signal_counts_at_step
       (brackets (group i))
       (op |.|)
       no_high
       (op *)
       no_repeats)))
    (group
     let
     remaining
     (op =)
     (parens (group till (op -) cycle_start (op +) 1))
     mod
     cycle_len)
    (group
     for
     (parens
      (group
       i
       (block (group cycle_start (op ..) cycle_start (op +) remaining))))
     (block
      (group
       no_low
       (op :=)
       no_low
       (op +)
       signal_counts_at_step
       (brackets (group i))
       (op |.|)
       no_low)
      (group
       no_high
       (op :=)
       no_high
       (op +)
       signal_counts_at_step
       (brackets (group i))
       (op |.|)
       no_high)))
    (group no_low (op *) no_high)))
  (group
   fun
   solve_for_part1
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group let config (op =) parse_input (parens (group raw_input)))
    (group
     repeat_and_count
     (parens (group config) (group #:till (block (group 1000)))))))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input)))
    (group #:is 32000000)))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input2)))
    (group #:is 11687500)))
  (group
   fun
   solve_for_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group let config (op =) parse_input (parens (group raw_input)))
    (group repeat_till_rx (parens (group config)))))
  (group solve_for_part2 (parens (group input))))
