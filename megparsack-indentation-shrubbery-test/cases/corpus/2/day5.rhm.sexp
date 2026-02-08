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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 5)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block
      (group "seeds: 79 14 55 13")
      (group "")
      (group "seed-to-soil map:")
      (group "50 98 2")
      (group "52 50 48")
      (group "")
      (group "soil-to-fertilizer map:")
      (group "0 15 37")
      (group "37 52 2")
      (group "39 0 15")
      (group "")
      (group "fertilizer-to-water map:")
      (group "49 53 8")
      (group "0 11 42")
      (group "42 0 7")
      (group "57 7 4")
      (group "")
      (group "water-to-light map:")
      (group "88 18 7")
      (group "18 25 70")
      (group "")
      (group "light-to-temperature map:")
      (group "45 77 23")
      (group "81 45 19")
      (group "68 64 13")
      (group "")
      (group "temperature-to-humidity map:")
      (group "0 69 1")
      (group "1 0 69")
      (group "")
      (group "humidity-to-location map:")
      (group "60 56 37")
      (group "56 93 4")))))
  (group
   fun
   parse_seed_list
   (parens (group raw_seed_list (op ::) ReadableString))
   (op ::)
   List
   (op |.|)
   of
   (parens (group Int))
   (block
    (group
     let
     (brackets (group "seeds") (group components))
     (op =)
     utils
     (op |.|)
     string
     (op |.|)
     split
     (parens (group raw_seed_list) (group ":")))
    (group
     let
     (brackets (group num_str) (group (op ...)))
     (op =)
     utils
     (op |.|)
     string
     (op |.|)
     split
     (parens (group components) (group " ")))
    (group
     (brackets
      (group String (op |.|) to_number (parens (group num_str)))
      (group (op ...))))))
  (group
   fun
   parse_map_spec
   (parens (group map_spec (op ::) ReadableString))
   (block
    (group
     let
     (brackets (group mapping_str) (group "map:"))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group map_spec) (group " ")))))
    (group
     let
     (brackets (group from) (group to))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group mapping_str) (group "-to-")))))
    (group Pair (parens (group from) (group to)))))
  (group
   class
   Range
   (parens (group start (op ::) Int) (group len (op ::) Int))
   (block (group method is_empty (parens) (block (group len (op ==) 0)))))
  (group
   class
   SourceMapping
   (parens
    (group dest_start (op ::) Int)
    (group source_start (op ::) Int)
    (group len (op ::) Int))
   (block
    (group
     method
     map_range_internal
     (parens (group range (op ::) Range))
     (block
      (group
       cond
       (alts
        (block
         (group
          source_start
          (op <=)
          range
          (op |.|)
          start
          (op &&)
          range
          (op |.|)
          start
          (op +)
          range
          (op |.|)
          len
          (op <=)
          source_start
          (op +)
          len
          (block
           (group
            let
            diff
            (block (group range (op |.|) start (op -) source_start)))
           (group
            let
            range
            (block
             (group
              Range
              (parens
               (group dest_start (op +) diff)
               (group range (op |.|) len)))))
           (group Pair (parens (group range) (group (brackets)))))))
        (block
         (group
          range
          (op |.|)
          start
          (op <=)
          source_start
          (op &&)
          source_start
          (op +)
          len
          (op <=)
          range
          (op |.|)
          start
          (op +)
          range
          (op |.|)
          len
          (block
           (group
            let
            new_range
            (block (group Range (parens (group dest_start) (group len)))))
           (group
            let
            range_before
            (block
             (group
              Range
              (parens
               (group range (op |.|) start)
               (group source_start (op -) range (op |.|) start)))))
           (group
            let
            range_after
            (block
             (group
              Range
              (parens
               (group source_start (op +) len)
               (group
                range
                (op |.|)
                start
                (op +)
                range
                (op |.|)
                len
                (op -)
                source_start
                (op -)
                len)))))
           (group
            Pair
            (parens
             (group new_range)
             (group (brackets (group range_before) (group range_after))))))))
        (block
         (group
          source_start
          (op <=)
          range
          (op |.|)
          start
          (op &&)
          range
          (op |.|)
          start
          (op <)
          source_start
          (op +)
          len
          (block
           (group
            let
            diff
            (block (group range (op |.|) start (op -) source_start)))
           (group
            let
            len
            (block
             (group source_start (op +) len (op -) range (op |.|) start)))
           (group
            let
            new_range
            (block
             (group
              Range
              (parens (group dest_start (op +) diff) (group len)))))
           (group
            Pair
            (parens
             (group new_range)
             (group
              (brackets
               (group
                Range
                (parens
                 (group range (op |.|) start (op +) new_range (op |.|) len)
                 (group
                  range
                  (op |.|)
                  len
                  (op -)
                  new_range
                  (op |.|)
                  len))))))))))
        (block
         (group
          source_start
          (op <)
          range
          (op |.|)
          start
          (op +)
          range
          (op |.|)
          len
          (op &&)
          range
          (op |.|)
          start
          (op +)
          range
          (op |.|)
          len
          (op <=)
          source_start
          (op +)
          len
          (block
           (group
            let
            diff
            (block
             (group
              range
              (op |.|)
              start
              (op +)
              range
              (op |.|)
              len
              (op -)
              source_start)))
           (group
            let
            new_range
            (block (group Range (parens (group dest_start) (group diff)))))
           (group
            Pair
            (parens
             (group new_range)
             (group
              (brackets
               (group
                Range
                (parens
                 (group range (op |.|) start)
                 (group
                  range
                  (op |.|)
                  len
                  (op -)
                  new_range
                  (op |.|)
                  len))))))))))
        (block (group #:else (block (group #f))))))))
    (group
     method
     map_range
     (parens (group range (op ::) Range))
     (block
      (group
       let
       mapped_range
       (block (group map_range_internal (parens (group range)))))
      (group
       if
       (op !)
       mapped_range
       (alts
        (block (group #f))
        (block
         (group
          let
          Pair
          (parens (group range) (group unchanged_elts))
          (op =)
          mapped_range)
         (group
          let
          unchanged_nonempty
          (block
           (group
            for
            List
            (block
             (group each base_range (block (group unchanged_elts)))
             (group skip_when base_range (op |.|) is_empty (parens))
             (group base_range)))))
         (group Pair (parens (group range) (group unchanged_nonempty))))))))
    (group
     method
     map
     (parens (group input (op ::) Int))
     (block
      (group let diff (op =) input (op -) source_start)
      (group
       if
       0
       (op <=)
       diff
       (op &&)
       diff
       (op <)
       len
       (alts (block (group dest_start (op +) diff)) (block (group #f))))))))
  (group
   check
   (block
    (group
     SourceMapping
     (parens (group 10) (group 5) (group 5))
     (op |.|)
     map_range
     (parens (group Range (parens (group 6) (group 2)))))
    (group
     #:is
     Pair
     (parens (group Range (parens (group 11) (group 2))) (group (brackets))))))
  (group
   check
   (block
    (group
     SourceMapping
     (parens (group 10) (group 5) (group 5))
     (op |.|)
     map_range
     (parens (group Range (parens (group 8) (group 4)))))
    (group
     #:is
     Pair
     (parens
      (group Range (parens (group 13) (group 2)))
      (group (brackets (group Range (parens (group 10) (group 2)))))))))
  (group
   check
   (block
    (group
     SourceMapping
     (parens (group 10) (group 5) (group 5))
     (op |.|)
     map_range
     (parens (group Range (parens (group 2) (group 4)))))
    (group
     #:is
     Pair
     (parens
      (group Range (parens (group 10) (group 1)))
      (group (brackets (group Range (parens (group 2) (group 3)))))))))
  (group
   check
   (block
    (group
     SourceMapping
     (parens (group 10) (group 5) (group 5))
     (op |.|)
     map_range
     (parens (group Range (parens (group 9) (group 1)))))
    (group
     #:is
     Pair
     (parens (group Range (parens (group 14) (group 1))) (group (brackets))))))
  (group
   class
   Mapping
   (parens
    (group from (op ::) String)
    (group to (op ::) String)
    (group mappings (op ::) List (op |.|) of (parens (group SourceMapping))))
   (block
    (group
     method
     map_range
     (parens (group range (op ::) Range))
     (block
      (group
       for
       values
       (parens (group result (op =) #f))
       (block
        (group each mapping (block (group mappings)))
        (group
         def
         mapped_range
         (block (group mapping (op |.|) map_range (parens (group range)))))
        (group skip_when (parens (group (op !) mapped_range)))
        (group final_when mapped_range)
        (group mapped_range)))))
    (group
     method
     map_ranges
     (parens (group ranges (op ::) List (op |.|) of (parens (group Range))))
     (block
      (group
       fun
       loop
       (parens (group unmapped_ranges) (group mapped_ranges))
       (block
        (group
         match
         unmapped_ranges
         (alts
          (block
           (group
            (brackets)
            (block (group mapped_ranges (op |.|) reverse (parens)))))
          (block
           (group
            List
            (op |.|)
            cons
            (parens (group range) (group unmapped_ranges))
            (block
             (group
              let
              mapped_range
              (block (group map_range (parens (group range)))))
             (group
              if
              (op !)
              mapped_range
              (alts
               (block
                (group
                 loop
                 (parens
                  (group unmapped_ranges)
                  (group
                   List
                   (op |.|)
                   cons
                   (parens (group range) (group mapped_ranges))))))
               (block
                (group
                 let
                 Pair
                 (parens (group new_range) (group remaining_ranges))
                 (block (group mapped_range)))
                (group
                 loop
                 (parens
                  (group remaining_ranges (op ++) unmapped_ranges)
                  (group
                   List
                   (op |.|)
                   cons
                   (parens
                    (group new_range)
                    (group mapped_ranges)))))))))))))))
      (group loop (parens (group ranges) (group (brackets))))))
    (group
     method
     map
     (parens (group input (op ::) Int))
     (op ::)
     Int
     (block
      (group
       for
       values
       (parens (group result (op =) input))
       (block
        (group each mapping (block (group mappings)))
        (group
         def
         mapped_input
         (block (group mapping (op |.|) map (parens (group input)))))
        (group skip_when (parens (group (op !) mapped_input)))
        (group final_when mapped_input)
        (group mapped_input)))))))
  (group
   check
   (block
    (group
     Mapping
     (parens
      (group "seed")
      (group "soil")
      (group
       (brackets
        (group SourceMapping (parens (group 100) (group 0) (group 5)))
        (group SourceMapping (parens (group 207) (group 7) (group 2)))
        (group SourceMapping (parens (group 110) (group 10) (group 5))))))
     (op |.|)
     map_ranges
     (parens (group (brackets (group Range (parens (group 0) (group 10)))))))
    (group
     #:is
     (brackets
      (group Range (parens (group 100) (group 5)))
      (group Range (parens (group 207) (group 2)))
      (group Range (parens (group 5) (group 2)))
      (group Range (parens (group 9) (group 1)))))))
  (group
   fun
   parse_conversion_range
   (parens (group range (op ::) ReadableString))
   (op ::)
   SourceMapping
   (block
    (group
     let
     (brackets (group dest_start) (group source_start) (group len))
     (block
      (group
       utils
       (op |.|)
       string
       (op |.|)
       split
       (parens (group range) (group " ")))))
    (group
     SourceMapping
     (parens
      (group String (op |.|) to_number (parens (group dest_start)))
      (group String (op |.|) to_number (parens (group source_start)))
      (group String (op |.|) to_number (parens (group len)))))))
  (group
   fun
   parse_map
   (parens
    (group raw_map (op ::) List (op |.|) of (parens (group ReadableString))))
   (block
    (group
     let
     (brackets (group raw_map_spec) (group component) (group (op ...)))
     (block (group raw_map)))
    (group
     let
     Pair
     (parens (group from) (group to))
     (block (group parse_map_spec (parens (group raw_map_spec)))))
    (group
     let
     mappings
     (block
      (group
       (brackets
        (group parse_conversion_range (parens (group component)))
        (group (op ...))))))
    (group
     values
     (parens
      (group from)
      (group to)
      (group Mapping (parens (group from) (group to) (group mappings)))))))
  (group
   fun
   construct_mapping
   (parens (group raw_maps (op ::) List))
   (op ::)
   Map
   (op |.|)
   of
   (parens
    (group String)
    (group Pair (op |.|) of (parens (group String) (group Mapping))))
   (block
    (group let map (block (group MutableMap (parens))))
    (group
     fun
     insert_mapping
     (parens (group from) (group to) (group mapping))
     (block
      (group
       if
       map
       (op |.|)
       has_key
       (parens (group from))
       (alts
        (block
         (group
          error
          (parens (group "found duplicate mapping!!!") (group from))))
        (block
         (group
          map
          (brackets (group from))
          (op :=)
          Pair
          (parens (group to) (group mapping))))))))
    (group
     for
     (parens (group raw_map (block (group raw_maps))))
     (block
      (group
       let
       values
       (parens (group from) (group to) (group mapping))
       (block (group parse_map (parens (group raw_map)))))
      (group insert_mapping (parens (group from) (group to) (group mapping)))))
    (group map (op |.|) snapshot (parens))))
  (group
   fun
   resolve_input
   (parens
    (group source (op :~) Pair (op |.|) of (parens (group String) (group Int)))
    (group
     ctx
     (op :~)
     Map
     (op |.|)
     of
     (parens
      (group String)
      (group Pair (op |.|) of (parens (group String) (group Mapping))))))
   (block
    (group let Pair (parens (group space) (group vl)) (op =) source)
    (group
     if
     ctx
     (op |.|)
     has_key
     (parens (group space))
     (alts
      (block
       (group
        let
        Pair
        (parens (group new_space) (group mapping))
        (block (group ctx (brackets (group space)))))
       (group
        let
        new_vl
        (block (group mapping (op |.|) map (parens (group vl)))))
       (group
        let
        new_source
        (block (group Pair (parens (group new_space) (group new_vl)))))
       (group resolve_input (parens (group new_source) (group ctx))))
      (block (group source))))))
  (group
   fun
   resolve_inputs
   (parens
    (group space (op :~) String)
    (group vls (op :~) List (op |.|) of (parens (group Int)))
    (group
     ctx
     (op :~)
     Map
     (op |.|)
     of
     (parens
      (group String)
      (group Pair (op |.|) of (parens (group String) (group Mapping))))))
   (block
    (group
     if
     ctx
     (op |.|)
     has_key
     (parens (group space))
     (alts
      (block
       (group
        let
        Pair
        (parens (group new_space) (group mapping))
        (block (group ctx (brackets (group space)))))
       (group
        let
        new_vls
        (block (group mapping (op |.|) map (op |.|) map (parens (group vls)))))
       (group
        resolve_inputs
        (parens (group new_space) (group new_vls) (group ctx))))
      (block (group vls))))))
  (group
   fun
   resolve_input_ranges
   (parens
    (group space (op :~) String)
    (group ranges (op :~) List (op |.|) of (parens (group Range)))
    (group
     ctx
     (op :~)
     Map
     (op |.|)
     of
     (parens
      (group String)
      (group Pair (op |.|) of (parens (group String) (group Mapping))))))
   (block
    (group
     if
     ctx
     (op |.|)
     has_key
     (parens (group space))
     (alts
      (block
       (group
        let
        Pair
        (parens (group new_space) (group mapping))
        (block (group ctx (brackets (group space)))))
       (group
        let
        new_ranges
        (block (group mapping (op |.|) map_ranges (parens (group ranges)))))
       (group
        resolve_input_ranges
        (parens (group new_space) (group new_ranges) (group ctx))))
      (block (group ranges))))))
  (group
   fun
   parse_input
   (parens (group raw_input (op :~) ReadableString))
   (block
    (group
     let
     input
     (op =)
     utils
     (op |.|)
     string
     (op |.|)
     split
     (parens
      (group raw_input)
      (group "\n")
      (group #:keep_blank (block (group #t)))))
    (group
     let
     (brackets
      (group (brackets (group raw_seed_list)))
      (group raw_map)
      (group (op ...)))
     (block
      (group
       utils
       (op |.|)
       list
       (op |.|)
       partition
       (parens (group input) (group "")))))
    (group
     let
     seed_list
     (block (group parse_seed_list (parens (group raw_seed_list)))))
    (group
     let
     maps
     (block
      (group
       construct_mapping
       (parens (group (brackets (group raw_map) (group (op ...))))))))
    (group Pair (parens (group seed_list) (group maps)))))
  (group
   fun
   solve_part1
   (parens (group raw_input (op :~) ReadableString))
   (block
    (group
     let
     Pair
     (parens (group seeds) (group ctx))
     (block (group parse_input (parens (group raw_input)))))
    (group
     let
     (brackets
      (group Pair (parens (group "location") (group vl)))
      (group (op ...)))
     (block
      (group
       for
       List
       (block
        (group each seed (block (group seeds)))
        (group
         resolve_input
         (parens
          (group Pair (parens (group "seed") (group seed)))
          (group ctx)))))))
    (group racket (op |.|) min (parens (group vl) (group (op ...))))))
  (group
   check
   (block (group solve_part1 (parens (group test_input))) (group #:is 35)))
  (group
   fun
   calculate_seeds
   (parens (group seed_ranges))
   (op :~)
   List
   (op |.|)
   of
   (parens (group Int))
   (block
    (group
     match
     seed_ranges
     (alts
      (block
       (group
        (brackets (group start) (group len) (group rest) (group (op ...)))
        (block
         (group
          let
          current
          (block (group Range (parens (group start) (group len)))))
         (group
          let
          rest
          (block
           (group
            calculate_seeds
            (parens (group (brackets (group rest) (group (op ...))))))))
         (group List (op |.|) cons (parens (group current) (group rest))))))
      (block (group (brackets) (block (group (brackets)))))))))
  (group
   fun
   solve_part2
   (parens (group raw_input (op :~) ReadableString))
   (block
    (group
     let
     Pair
     (parens (group seed_ranges) (group ctx))
     (block (group parse_input (parens (group raw_input)))))
    (group
     let
     seed_ranges
     (block (group calculate_seeds (parens (group seed_ranges)))))
    (group
     let
     ranges
     (block
      (group
       resolve_input_ranges
       (parens (group "seed") (group seed_ranges) (group ctx)))))
    (group
     let
     (brackets (group Range (parens (group vl) (group _))) (group (op ...)))
     (block (group ranges)))
    (group racket (op |.|) min (parens (group vl) (group (op ...))))))
  (group
   check
   (block (group solve_part2 (parens (group test_input))) (group #:is 46)))
  (group let result2 (block (group solve_part2 (parens (group input))))))
