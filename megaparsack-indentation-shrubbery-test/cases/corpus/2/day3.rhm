#lang rhombus/and_meta

import:
  file("./utils/aoc_api.rhm")
  file("./utils/lang.rhm") open
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

def input: aoc_api.retrieve_input_for_day(3)

def test_input:
  "467..114..\n" +& \
  "...*......\n" +& \
  "..35..633.\n" +& \
  "......#...\n" +& \
  "617*......\n" +& \
  ".....+.58.\n" +& \
  "..592.....\n" +& \
  "......755.\n" +& \
  "...$.*....\n" +& \
  ".664.598.." 

def input_text: test_input

fun skip_numeric(str :: String, ind):
  if ind < str.length() && Char.is_numeric(str[ind])
  | skip_numeric(str, ind + 1)
  | ind
  
fun skip_till_numeric(str :: String, ind :: Int):
  if (ind < str.length() && !Char.is_numeric(str[ind]))
  | skip_till_numeric(str, ind + 1)
  | ind

fun is_symbol(c::Char):
  cond 
  | c == #{#\.}: #false
  | Char.is_numeric(c): #false
  | ~else: #true

fun check_for_symbol(str :: String, st :: Int, end :: Int):
  if st == end
  | #false
  | def c: str[st]
    if is_symbol(c)
    | st
    | check_for_symbol(str, st + 1, end)

fun collect_symbol_inds(str :: String, st :: Int, end :: Int) :: List.of(Int):
  if st == end
  | []
  | def c: str[st]
    if is_symbol(c)
    | List.cons(st, collect_symbol_inds(str, st + 1, end))
    | collect_symbol_inds(str, st + 1, end)


fun split_numbers(line :: String) :: List.of(Pair.of(Int, List.of(Int))):
  def mutable ind: 0
  def mutable lines: []
  while (ind < line.length()):
    let start: skip_till_numeric(line, ind)
    let end: skip_numeric(line, start)
    let number_str: String.substring(line, start, end)
    let number: String.to_number(number_str)
    when number
    | lines := List.cons(Pair(number, [start,end]), lines)
    ind := end
  List.reverse(lines)

fun solve_part1(input_text :: ReadableString):
   def [line,...] :: List.of(ReadableString) : string.split(input_text, "\n")
   def data: Array(line.to_string(), ...)
   def mutable sum: 0
   for:
     each i: 0 .. data.length()
     let prev_line: if i > 0 | data[i-1] | #false
     let next_line: if i < data.length() - 1 | data[i+1] | #false
     let line = data[i]
     let total:
       for values(lsum=0):
         each Pair(number, [start, end]) : split_numbers(line)
         let start_diagonal: racket.max(0, start - 1)
         let end_diagonal: racket.min(end + 1, line.length())
         cond:
         | is_symbol(line[start_diagonal]): lsum + number
         | end < line.length() && is_symbol(line[end]): lsum + number
         | prev_line && check_for_symbol(prev_line, start_diagonal, end_diagonal): lsum + number
         | next_line && check_for_symbol(next_line, start_diagonal, end_diagonal): lsum + number
         | ~else: lsum
     sum := sum + total
   sum

check:
  solve_part1(test_input)
  ~is 4361

// solve_part1(input)

fun solve_part2(input_text):
  def [line,...] :: List.of(ReadableString) : string.split(input_text, "\n")
  def data: Array(line.to_string(), ...)

  def map: MutableMap()
  fun insert_into_map(line, col, number):
    let pair: Pair(line,col)
    if map.has_key(pair)
    | map[pair] := List.cons(number, map[pair])
    | map[pair] := [number]

  for:
    each i: 0 .. data.length()
    let prev_line: if i > 0 | data[i-1] | #false
    let next_line: if i < data.length() - 1 | data[i+1] | #false
    let line = data[i]
    for:
      each Pair(number, [start, end]) : split_numbers(line)
      let start_diagonal: racket.max(0, start - 1)
      let end_diagonal: racket.min(end + 1, line.length())
      when is_symbol(line[start_diagonal])
      | insert_into_map(i, start_diagonal, number)
      when end < line.length() && is_symbol(line[end])
      | insert_into_map(i, end, number)

      when prev_line
      | for(sym_ind: collect_symbol_inds(prev_line, start_diagonal, end_diagonal)):
          insert_into_map(i - 1, sym_ind, number)
      when next_line
      | for(sym_ind: collect_symbol_inds(next_line, start_diagonal, end_diagonal)):
          insert_into_map(i + 1, sym_ind, number)

  for values(sum=0):
    each values(loc,nums) : map
    if nums.length() == 2
    | sum + nums[0] * nums[1]
    | sum

check:
  solve_part2(test_input)
  ~is 467835

// solve_part2(input)
