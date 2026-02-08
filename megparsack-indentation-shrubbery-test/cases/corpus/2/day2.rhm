#lang rhombus/and_meta

import:
  file("./utils/aoc_api.rhm")
  lib("racket/main.rkt") as racket:
    rename:
      #{char-numeric?} as is_numeric_char
      #{char->integer} as char_to_int
      #{with-input-from-file} as with_input_from_file
      #{with-output-to-file} as with_output_to_file
      #{file-exists?} as exists_file

  lib("racket/string.rkt") as string:
    rename:
      #{string-prefix?} as is_string_prefix
      #{string-split} as split
      #{string-trim} as trim

def input: aoc_api.retrieve_input_for_day(2)

class GameResult(red :: Int, green :: Int, blue :: Int)

fun parse_game_transcript(t) :: GameResult:
  let values(r, g, b):
    for values(red=0,green=0,blue=0) (entry: string.split(t, ",")):
      let [raw_count, raw_color]: string.split(entry, " ")
      let count : String.to_number(raw_count)
      let color : (raw_color).to_string()
      match color
      | "red": values(red + count, green, blue)
      | "green": values(red, green + count, blue)
      | "blue": values(red, green, blue + count)
  GameResult(r,g,b)

class GameLog(id :: Int, results :: List.of(GameResult))

fun parse_line(line) :: GameLog:
  let [game_id, game_log] = string.split(line, ":")
  let [_, raw_id] = string.split(game_id, " ")
  let id = String.to_number(raw_id)
  let raw_game_list = string.trim.map(string.split(game_log, ";"))
  let game_list = parse_game_transcript.map(raw_game_list)
  GameLog(id, game_list)  


fun parse_input(input) :: List.of(GameLog):
  for List:
    each line: string.split(input, "\n")
    parse_line(line)    

def parsed_input : parse_input(input)

def MAX_RED: 12
def MAX_GREEN: 13
def MAX_BLUE: 14

def test_input:
  "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\n" +& \
  "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\n" +& \
  "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\n" +& \
  "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\n" +& \
  "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"

fun calculate_solution_for_part1(input):
  for values(sum=0):
    each game_log: parse_input(input)
    let values(m_red, m_green, m_blue):
      for values(m_red=0,m_green=0,m_blue=0):
       each game_result: game_log.results
       values(
         racket.max(game_result.red, m_red),
         racket.max(game_result.green, m_green),
         racket.max(game_result.blue, m_blue),
       )
    if m_red > MAX_RED || m_green > MAX_GREEN || m_blue > MAX_BLUE
    | sum
    | sum + game_log.id
      
check:
  calculate_solution_for_part1(test_input)
  ~is 8

def result1: calculate_solution_for_part1(input)
// aoc_api.submit_result_for_day(2, result1)


fun calculate_solution_for_part2(input):
  for values(sum=0):
    each game_log: parse_input(input)
    let values(m_red, m_green, m_blue):
      for values(m_red=0,m_green=0,m_blue=0):
       each game_result: game_log.results
       values(
         racket.max(game_result.red, m_red),
         racket.max(game_result.green, m_green),
         racket.max(game_result.blue, m_blue),
       )
    sum + m_red * m_green * m_blue 
check:
  calculate_solution_for_part2(test_input)
  ~is 2286

def result2: calculate_solution_for_part2(input)
// aoc_api.submit_result_for_day(2, result1, ~level: 2)
