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
    (group test_input)
    (group
     (brackets
      (group "seeds: 79 14 55 13")
      (group "\n")
      (group "\n")
      (group "seed-to-soil map:")
      (group "\n")
      (group "50 98 2")
      (group "\n")
      (group "52 50 48")
      (group "\n")
      (group "\n")
      (group "soil-to-fertilizer map:")
      (group "\n")
      (group "0 15 37")
      (group "\n")
      (group "37 52 2")
      (group "\n")
      (group "39 0 15")
      (group "\n")
      (group "\n")
      (group "fertilizer-to-water map:")
      (group "\n")
      (group "49 53 8")
      (group "\n")
      (group "0 11 42")
      (group "\n")
      (group "42 0 7")
      (group "\n")
      (group "57 7 4")
      (group "\n")
      (group "\n")
      (group "water-to-light map:")
      (group "\n")
      (group "88 18 7")
      (group "\n")
      (group "18 25 70")
      (group "\n")
      (group "\n")
      (group "light-to-temperature map:")
      (group "\n")
      (group "45 77 23")
      (group "\n")
      (group "81 45 19")
      (group "\n")
      (group "68 64 13")
      (group "\n")
      (group "\n")
      (group "temperature-to-humidity map:")
      (group "\n")
      (group "0 69 1")
      (group "\n")
      (group "1 0 69")
      (group "\n")
      (group "\n")
      (group "humidity-to-location map:")
      (group "\n")
      (group "60 56 37")
      (group "\n")
      (group "56 93 4")))))
  (group
   class
   Span
   (parens (group start (op ::) NonnegInt) (group end (op ::) PosInt))
   (block
    (group
     constructor
     (parens (group start (op ::) NonnegInt) (group end (op ::) PosInt))
     (block
      (group
       unless
       start
       (op <=)
       end
       (alts
        (block
         (group
          error
          (parens
           (group (op |#'|) Span)
           (group
            util
            (op |.|)
            fmt
            (parens
             (group
              (brackets
               (group "invalid span: start: ")
               (group start)
               (group " > end: ")
               (group end))))))))))
      (group super (parens (group start) (group end)))))
    (group
     method
     less
     (parens (group other (op ::) Span))
     (op ::)
     Boolean
     (block (group start (op <) other (op |.|) start)))
    (group
     method
     add_delta
     (parens (group amount (op ::) Int))
     (op ::)
     Span
     (block
      (group
       Span
       (parens (group start (op +) amount) (group end (op +) amount)))))))
  (group
   fun
   Span
   (op |.|)
   from_parse
   (parens
    (group #:start (block (group start (op ::) NonnegInt)))
    (group #:length (block (group length (op ::) PosInt (op =) 1))))
   (op ::)
   Span
   (block
    (group Span (parens (group start) (group start (op +) length (op -) 1)))))
  (group
   class
   MapEntry
   (parens
    (group start (op ::) NonnegInt)
    (group end (op ::) PosInt)
    (group dest (op ::) NonnegInt))
   (block
    (group property delta (op :~) Int (block (group dest (op -) start)))
    (group
     method
     less
     (parens (group other (op ::) MapEntry))
     (op :~)
     Boolean
     (block (group start (op <) other (op |.|) start)))
    (group
     method
     split
     (parens (group span (op ::) Span))
     (op ::)
     values
     (parens
      (group List (op |.|) of (parens (group Span)))
      (group Span (op \|\|) False))
     (block
      (group
       cond
       (alts
        (block
         (group
          (parens
           (group
            span
            (op |.|)
            start
            (op <)
            start
            (op &&)
            span
            (op |.|)
            end
            (op <)
            start))
          (op \|\|)
          (parens
           (group
            span
            (op |.|)
            start
            (op >=)
            start
            (op &&)
            span
            (op |.|)
            end
            (op <=)
            end))
          (block
           (group
            values
            (parens (group (brackets (group span))) (group #f))))))
        (block
         (group
          span
          (op |.|)
          start
          (op <)
          start
          (block
           (group
            def
            span1
            (op =)
            Span
            (parens (group span (op |.|) start) (group start (op -) 1)))
           (group
            def
            span2
            (op =)
            Span
            (parens (group start) (group span (op |.|) end)))
           (group
            def
            values
            (parens (group more_spans) (group remainder_span))
            (op =)
            split
            (parens (group span2)))
           (group
            values
            (parens
             (group
              List
              (op |.|)
              cons
              (parens (group span1) (group more_spans)))
             (group remainder_span))))))
        (block
         (group
          span
          (op |.|)
          start
          (op <=)
          end
          (block
           (group
            def
            span1
            (op =)
            Span
            (parens (group span (op |.|) start) (group end)))
           (group
            def
            span2
            (op =)
            Span
            (parens (group end (op +) 1) (group span (op |.|) end)))
           (group
            values
            (parens (group (brackets (group span1))) (group span2))))))
        (block
         (group
          span
          (op |.|)
          start
          (op >)
          end
          (block (group values (parens (group (brackets)) (group span))))))))))
    (group
     method
     lookup
     (parens (group span (op ::) Span))
     (op ::)
     Span
     (op \|\|)
     False
     (block
      (group
       cond
       (alts
        (block
         (group
          span
          (op |.|)
          start
          (op >=)
          start
          (op &&)
          span
          (op |.|)
          end
          (op <=)
          end
          (block (group span (op |.|) add_delta (parens (group delta))))))
        (block (group #:else (block (group #f))))))))))
  (group
   fun
   MapEntry
   (op |.|)
   from_parse
   (parens
    (group #:src (block (group src (op ::) NonnegInt)))
    (group #:dest (block (group dest (op ::) NonnegInt)))
    (group #:length (block (group length (op ::) PosInt))))
   (op ::)
   MapEntry
   (block
    (group
     MapEntry
     (parens (group src) (group src (op +) length (op -) 1) (group dest)))))
  (group
   check
   (block
    (group
     MapEntry
     (parens (group 5) (group 100) (group 5))
     (op |.|)
     split
     (parens (group Span (parens (group 0) (group 4))))
     #:is
     (block
      (group
       values
       (parens
        (group (brackets (group Span (parens (group 0) (group 4)))))
        (group #f)))))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     split
     (parens (group Span (parens (group 0) (group 7))))
     #:is
     (block
      (group
       values
       (parens
        (group
         (brackets
          (group Span (parens (group 0) (group 4)))
          (group Span (parens (group 5) (group 7)))))
        (group #f)))))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     split
     (parens (group Span (parens (group 6) (group 9))))
     #:is
     (block
      (group
       values
       (parens
        (group (brackets (group Span (parens (group 6) (group 9)))))
        (group #f)))))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     split
     (parens (group Span (parens (group 5) (group 10))))
     #:is
     (block
      (group
       values
       (parens
        (group (brackets (group Span (parens (group 5) (group 10)))))
        (group #f)))))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     split
     (parens (group Span (parens (group 11) (group 20))))
     #:is
     (block
      (group
       values
       (parens
        (group (brackets))
        (group Span (parens (group 11) (group 20)))))))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     split
     (parens (group Span (parens (group 9) (group 20))))
     #:is
     (block
      (group
       values
       (parens
        (group (brackets (group Span (parens (group 9) (group 10)))))
        (group Span (parens (group 11) (group 20)))))))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     split
     (parens (group Span (parens (group 0) (group 20))))
     #:is
     (block
      (group
       values
       (parens
        (group
         (brackets
          (group Span (parens (group 0) (group 4)))
          (group Span (parens (group 5) (group 10)))))
        (group Span (parens (group 11) (group 20)))))))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     lookup
     (parens (group Span (parens (group 5) (group 10))))
     #:is
     Span
     (parens (group 100) (group 105)))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     lookup
     (parens (group Span (parens (group 7) (group 10))))
     #:is
     Span
     (parens (group 102) (group 105)))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     lookup
     (parens (group Span (parens (group 7) (group 8))))
     #:is
     Span
     (parens (group 102) (group 103)))
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     lookup
     (parens (group Span (parens (group 0) (group 4))))
     #:is
     #f)
    (group
     MapEntry
     (parens (group 5) (group 10) (group 100))
     (op |.|)
     lookup
     (parens (group Span (parens (group 11) (group 20))))
     #:is
     #f)))
  (group
   class
   AlmanacMap
   (parens (group entries (op ::) List (op |.|) of (parens (group MapEntry))))
   (block
    (group
     constructor
     (parens
      (group entries (op ::) List (op |.|) of (parens (group MapEntry))))
     (block
      (group
       let
       entries
       (op =)
       entries
       (op |.|)
       sort
       (parens (group MapEntry (op |.|) less)))
      (group super (parens (group entries)))))
    (group
     method
     split_all
     (parens (group spans (op ::) List (op |.|) of (parens (group Span))))
     (op ::)
     List
     (op |.|)
     of
     (parens (group Span))
     (block
      (group
       fun
       do_splits
       (parens
        (group spans (op ::) List (op |.|) of (parens (group Span)))
        (group entries (op ::) List (op |.|) of (parens (group MapEntry))))
       (op ::)
       List
       (op |.|)
       of
       (parens (group Span))
       (block
        (group
         cond
         (alts
          (block (group spans (op ==) (brackets) (block (group (brackets)))))
          (block (group entries (op ==) (brackets) (block (group spans))))
          (block
           (group
            #:else
            (block
             (group def span (op =) spans (brackets (group 0)))
             (group def entry (op =) entries (brackets (group 0)))
             (group
              cond
              (alts
               (block
                (group
                 span
                 (op |.|)
                 start
                 (op >)
                 entry
                 (op |.|)
                 end
                 (block
                  (group
                   do_splits
                   (parens (group spans) (group entries (op |.|) rest))))))
               (block
                (group
                 #:else
                 (block
                  (group
                   def
                   values
                   (parens (group pending) (group remainder))
                   (block (group entry (op |.|) split (parens (group span)))))
                  (group
                   let
                   spans
                   (block
                    (group
                     if
                     remainder
                     (alts
                      (block
                       (group
                        List
                        (op |.|)
                        cons
                        (parens
                         (group remainder)
                         (group spans (op |.|) rest))))
                      (block (group spans (op |.|) rest))))))
                  (group
                   match
                   pending
                   (alts
                    (block
                     (group
                      (brackets)
                      (block
                       (group
                        do_splits
                        (parens
                         (group spans)
                         (group entries (op |.|) rest))))))
                    (block
                     (group
                      (brackets (group a))
                      (block
                       (group
                        List
                        (op |.|)
                        cons
                        (parens
                         (group a)
                         (group
                          do_splits
                          (parens (group spans) (group entries))))))))
                    (block
                     (group
                      (brackets (group a) (group b))
                      (block
                       (group
                        List
                        (op |.|)
                        cons
                        (parens
                         (group a)
                         (group
                          do_splits
                          (parens
                           (group
                            List
                            (op |.|)
                            cons
                            (parens (group b) (group spans)))
                           (group entries))))))))))))))))))))))
      (group do_splits (parens (group spans) (group entries)))))
    (group
     method
     lookup
     (parens (group spans (op ::) List (op |.|) of (parens (group Span))))
     (op ::)
     List
     (op |.|)
     of
     (parens (group Span))
     (block
      (group
       fun
       do_lookup
       (parens
        (group spans (op ::) List (op |.|) of (parens (group Span)))
        (group entries (op ::) List (op |.|) of (parens (group MapEntry))))
       (block
        (group
         cond
         (alts
          (block (group spans (op ==) (brackets) (block (group (brackets)))))
          (block (group entries (op ==) (brackets) (block (group spans))))
          (block
           (group
            #:else
            (block
             (group def span (op =) spans (brackets (group 0)))
             (group def entry (op =) entries (brackets (group 0)))
             (group
              cond
              (alts
               (block
                (group
                 span
                 (op |.|)
                 end
                 (op <)
                 entry
                 (op |.|)
                 start
                 (block
                  (group
                   List
                   (op |.|)
                   cons
                   (parens
                    (group span)
                    (group
                     do_lookup
                     (parens (group spans (op |.|) rest) (group entries))))))))
               (block
                (group
                 span
                 (op |.|)
                 end
                 (op <=)
                 entry
                 (op |.|)
                 end
                 (block
                  (group
                   List
                   (op |.|)
                   cons
                   (parens
                    (group entry (op |.|) lookup (parens (group span)))
                    (group
                     do_lookup
                     (parens (group spans (op |.|) rest) (group entries))))))))
               (block
                (group
                 span
                 (op |.|)
                 start
                 (op >)
                 entry
                 (op |.|)
                 end
                 (block
                  (group
                   do_lookup
                   (parens
                    (group spans)
                    (group entries (op |.|) rest)))))))))))))))
      (group do_lookup (parens (group spans) (group entries)))))))
  (group
   def
   map_name_order
   (block
    (group
     (brackets
      (group "seed")
      (group "soil")
      (group "fertilizer")
      (group "water")
      (group "light")
      (group "temperature")
      (group "humidity")
      (group "location")))))
  (group
   def
   map_order
   (block
    (group
     for
     List
     (block
      (group
       each
       (block
        (group src (block (group map_name_order)))
        (group dest (block (group map_name_order (op |.|) rest)))))
      (group (brackets (group src) (group dest)))))))
  (group
   class
   Almanac
   (parens
    (group seeds (op ::) List (op |.|) of (parens (group Span)))
    (group
     maps
     (op ::)
     Map
     (op |.|)
     of
     (parens
      (group List (op |.|) of (parens (group String)))
      (group AlmanacMap))))
   (block
    (group
     method
     find_min_location
     (parens)
     (block
      (group
       def
       spans
       (op :~)
       List
       (op |.|)
       of
       (parens (group Span))
       (block
        (group
         for
         values
         (parens (group spans (op =) seeds))
         (block
          (group each map_name (block (group map_order)))
          (group def this_map (op =) maps (brackets (group map_name)))
          (group
           let
           spans
           (op =)
           this_map
           (op |.|)
           split_all
           (parens (group spans)))
          (group
           this_map
           (op |.|)
           lookup
           (parens (group spans))
           (op |.|)
           sort
           (parens (group Span (op |.|) less)))))))
      (group spans (brackets (group 0)) (op |.|) start)))))
  (group
   fun
   Almanac
   (op |.|)
   from_parse
   (parens
    (group seeds (op ::) List (op |.|) of (parens (group Span)))
    (group maps (op ::) List))
   (op ::)
   Almanac
   (block
    (group
     let
     maps
     (block
      (group
       for
       Map
       (block
        (group
         each
         (brackets (group src) (group dest) (group entries (op ::) AlmanacMap))
         (block (group maps)))
        (group
         values
         (parens
          (group (brackets (group src) (group dest)))
          (group entries)))))))
    (group
     let
     seeds
     (op =)
     seeds
     (op |.|)
     sort
     (parens (group Span (op |.|) less)))
    (group Almanac (parens (group seeds) (group maps)))))
  (group
   def
   integer_list_p
   (block
    (group
     p
     (op |.|)
     many1
     (parens
      (group
       p
       (op |.|)
       try
       (parens
        (group
         p
         (op |.|)
         parse_sequence
         (block (group p (op |.|) spaces) (group p (op |.|) integer)))))))))
  (group
   def
   name_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group
       cs
       (op =)
       p
       (op |.|)
       many1
       (parens
        (group
         p
         (op |.|)
         satisfy
         (parens (group Char (op |.|) is_alphabetic)))))
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         (parens
          (group
           base
           (op |.|)
           list->string
           (parens (group cs))
           (op :~)
           ReadableString))
         (op |.|)
         to_string
         (parens))))))))
  (group
   def
   initial_seeds1_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group p (op |.|) string (parens (group "seeds:")))
      (group seeds (op =) integer_list_p)
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         for
         List
         (block
          (group each s (block (group seeds (op :~) List)))
          (group
           Span
           (op |.|)
           from_parse
           (parens (group #:start (block (group s)))))))))))))
  (group
   def
   initial_seeds2_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group p (op |.|) string (parens (group "seeds:")))
      (group seeds (op =) integer_list_p)
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         block
         (block
          (group let seeds (op :~) List (block (group seeds)))
          (group
           for
           List
           (block
            (group
             each
             i
             (block
              (group
               0
               (op ..)
               (parens
                (group
                 (parens (group seeds (op :~) List))
                 (op |.|)
                 length
                 (parens)
                 (op /)
                 2)))))
            (group
             Span
             (op |.|)
             from_parse
             (parens
              (group
               #:start
               (block (group seeds (brackets (group i (op *) 2)))))
              (group
               #:length
               (block
                (group
                 seeds
                 (brackets (group i (op *) 2 (op +) 1)))))))))))))))))
  (group
   def
   mapping_entry_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group p (op |.|) spaces)
      (group dest (op =) p (op |.|) integer)
      (group p (op |.|) spaces)
      (group src (op =) p (op |.|) integer)
      (group p (op |.|) spaces)
      (group length (op =) p (op |.|) integer)
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         MapEntry
         (op |.|)
         from_parse
         (parens
          (group #:src (block (group src)))
          (group #:dest (block (group dest)))
          (group #:length (block (group length)))))))))))
  (group
   def
   map_p
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group p (op |.|) spaces)
      (group src (op =) name_p)
      (group p (op |.|) string (parens (group "-to-")))
      (group dest (op =) name_p)
      (group p (op |.|) string (parens (group " map:")))
      (group
       mapping_entries
       (op =)
       p
       (op |.|)
       many1
       (parens (group p (op |.|) try (parens (group mapping_entry_p)))))
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         (brackets
          (group src)
          (group dest)
          (group AlmanacMap (parens (group mapping_entries)))))))))))
  (group
   fun
   seed_maps_p
   (parens (group seeds_p))
   (block
    (group
     p
     (op |.|)
     parse_sequence
     (block
      (group seeds (op =) seeds_p)
      (group
       maps
       (op =)
       p
       (op |.|)
       many1
       (parens (group p (op |.|) try (parens (group map_p)))))
      (group
       p
       (op |.|)
       choice
       (parens
        (group p (op |.|) try (parens (group p (op |.|) spaces)))
        (group p (op |.|) pure (parens (group #t)))))
      (group
       p
       (op |.|)
       pure
       (parens
        (group
         Almanac
         (op |.|)
         from_parse
         (parens (group seeds) (group maps)))))))))
  (group
   fun
   run1
   (parens (group input))
   (block
    (group
     def
     values
     (parens (group config (op :~) Almanac) (group (brackets)))
     (block
      (group
       p
       (op |.|)
       parse
       (parens
        (group seed_maps_p (parens (group initial_seeds1_p)))
        (group p (op |.|) string_to_list (parens (group input)))))))
    (group config (op |.|) find_min_location (parens))))
  (group check (block (group run1 (parens (group test_input)) #:is 35)))
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
        (group 5)))))))
  (group
   fun
   run2
   (parens (group input))
   (block
    (group
     def
     values
     (parens (group config (op :~) Almanac) (group (brackets)))
     (block
      (group
       p
       (op |.|)
       parse
       (parens
        (group seed_maps_p (parens (group initial_seeds2_p)))
        (group p (op |.|) string_to_list (parens (group input)))))))
    (group config (op |.|) find_min_location (parens))))
  (group check (block (group run2 (parens (group test_input)) #:is 46)))
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
        (group 5))))))))
