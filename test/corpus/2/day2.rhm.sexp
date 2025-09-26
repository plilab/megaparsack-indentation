'(multi
  (group
   import
   (block
    (group file (parens (group "./utils/aoc_api.rhm")))
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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 2)))))
  (group
   class
   GameResult
   (parens
    (group red (op ::) Int)
    (group green (op ::) Int)
    (group blue (op ::) Int)))
  (group
   fun
   parse_game_transcript
   (parens (group t))
   (op ::)
   GameResult
   (block
    (group
     let
     values
     (parens (group r) (group g) (group b))
     (block
      (group
       for
       values
       (parens
        (group red (op =) 0)
        (group green (op =) 0)
        (group blue (op =) 0))
       (parens
        (group
         entry
         (block (group string (op |.|) split (parens (group t) (group ","))))))
       (block
        (group
         let
         (brackets (group raw_count) (group raw_color))
         (block
          (group string (op |.|) split (parens (group entry) (group " ")))))
        (group
         let
         count
         (block (group String (op |.|) to_number (parens (group raw_count)))))
        (group
         let
         color
         (block
          (group (parens (group raw_color)) (op |.|) to_string (parens))))
        (group
         match
         color
         (alts
          (block
           (group
            "red"
            (block
             (group
              values
              (parens (group red (op +) count) (group green) (group blue))))))
          (block
           (group
            "green"
            (block
             (group
              values
              (parens (group red) (group green (op +) count) (group blue))))))
          (block
           (group
            "blue"
            (block
             (group
              values
              (parens
               (group red)
               (group green)
               (group blue (op +) count))))))))))))
    (group GameResult (parens (group r) (group g) (group b)))))
  (group
   class
   GameLog
   (parens
    (group id (op ::) Int)
    (group results (op ::) List (op |.|) of (parens (group GameResult)))))
  (group
   fun
   parse_line
   (parens (group line))
   (op ::)
   GameLog
   (block
    (group
     let
     (brackets (group game_id) (group game_log))
     (op =)
     string
     (op |.|)
     split
     (parens (group line) (group ":")))
    (group
     let
     (brackets (group _) (group raw_id))
     (op =)
     string
     (op |.|)
     split
     (parens (group game_id) (group " ")))
    (group let id (op =) String (op |.|) to_number (parens (group raw_id)))
    (group
     let
     raw_game_list
     (op =)
     string
     (op |.|)
     trim
     (op |.|)
     map
     (parens
      (group string (op |.|) split (parens (group game_log) (group ";")))))
    (group
     let
     game_list
     (op =)
     parse_game_transcript
     (op |.|)
     map
     (parens (group raw_game_list)))
    (group GameLog (parens (group id) (group game_list)))))
  (group
   fun
   parse_input
   (parens (group input))
   (op ::)
   List
   (op |.|)
   of
   (parens (group GameLog))
   (block
    (group
     for
     List
     (block
      (group
       each
       line
       (block
        (group string (op |.|) split (parens (group input) (group "\n")))))
      (group parse_line (parens (group line)))))))
  (group def parsed_input (block (group parse_input (parens (group input)))))
  (group def MAX_RED (block (group 12)))
  (group def MAX_GREEN (block (group 13)))
  (group def MAX_BLUE (block (group 14)))
  (group
   def
   test_input
   (block
    (group
     "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\n"
     (op +&)
     "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\n"
     (op +&)
     "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\n"
     (op +&)
     "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\n"
     (op +&)
     "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green")))
  (group
   fun
   calculate_solution_for_part1
   (parens (group input))
   (block
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each game_log (block (group parse_input (parens (group input)))))
      (group
       let
       values
       (parens (group m_red) (group m_green) (group m_blue))
       (block
        (group
         for
         values
         (parens
          (group m_red (op =) 0)
          (group m_green (op =) 0)
          (group m_blue (op =) 0))
         (block
          (group each game_result (block (group game_log (op |.|) results)))
          (group
           values
           (parens
            (group
             racket
             (op |.|)
             max
             (parens (group game_result (op |.|) red) (group m_red)))
            (group
             racket
             (op |.|)
             max
             (parens (group game_result (op |.|) green) (group m_green)))
            (group
             racket
             (op |.|)
             max
             (parens (group game_result (op |.|) blue) (group m_blue)))))))))
      (group
       if
       m_red
       (op >)
       MAX_RED
       (op \|\|)
       m_green
       (op >)
       MAX_GREEN
       (op \|\|)
       m_blue
       (op >)
       MAX_BLUE
       (alts
        (block (group sum))
        (block (group sum (op +) game_log (op |.|) id))))))))
  (group
   check
   (block
    (group calculate_solution_for_part1 (parens (group test_input)))
    (group #:is 8)))
  (group
   def
   result1
   (block (group calculate_solution_for_part1 (parens (group input)))))
  (group
   fun
   calculate_solution_for_part2
   (parens (group input))
   (block
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each game_log (block (group parse_input (parens (group input)))))
      (group
       let
       values
       (parens (group m_red) (group m_green) (group m_blue))
       (block
        (group
         for
         values
         (parens
          (group m_red (op =) 0)
          (group m_green (op =) 0)
          (group m_blue (op =) 0))
         (block
          (group each game_result (block (group game_log (op |.|) results)))
          (group
           values
           (parens
            (group
             racket
             (op |.|)
             max
             (parens (group game_result (op |.|) red) (group m_red)))
            (group
             racket
             (op |.|)
             max
             (parens (group game_result (op |.|) green) (group m_green)))
            (group
             racket
             (op |.|)
             max
             (parens (group game_result (op |.|) blue) (group m_blue)))))))))
      (group sum (op +) m_red (op *) m_green (op *) m_blue)))))
  (group
   check
   (block
    (group calculate_solution_for_part2 (parens (group test_input)))
    (group #:is 2286)))
  (group
   def
   result2
   (block (group calculate_solution_for_part2 (parens (group input))))))
