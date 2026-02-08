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

def input: aoc_api.retrieve_input_for_day(1)
def lines: string.split(input, "\n")

fun String.index_of_first_digit(str):
    for values(res=#false, digit=#false):
      each:
         i: 0 ..
         char: str
      final_when Char.is_numeric(char)
      values(i,char)

fun String.first_digit(str):
    for values(res=#false):
      each char: str
      final_when Char.is_numeric(char)
      char

fun String.index_of_last_digit(str):
   for values(res=#false, digit=#false):
     each i: 0 .. str.length()
     def ind: str.length() - i - 1
     def char: str[ind]
     final_when Char.is_numeric(char)
     values(ind, char)

fun String.last_digit(str):
   for values(res=#false):
     each i: 0 .. str.length()
     def char: str[str.length() - i - 1]
     final_when Char.is_numeric(char)
     char


def result_day1:
  for values(sum=0) (line: lines):
    def first_char: String.first_digit(line)
    def last_char: String.last_digit(line)

    sum + String.to_number(first_char +& last_char)

// aoc_api.submit_result_for_day(1, result_day1)

fun
| numeric_digit_to_string("one"): 1
| numeric_digit_to_string("two"): 2
| numeric_digit_to_string("three"): 3
| numeric_digit_to_string("four"): 4
| numeric_digit_to_string("five"): 5
| numeric_digit_to_string("six"): 6
| numeric_digit_to_string("seven"): 7
| numeric_digit_to_string("eight"): 8
| numeric_digit_to_string("nine"): 9
| numeric_digit_to_string("twone"): Pair(3, [2,1])
| numeric_digit_to_string("oneight"): Pair(3, [1,8])
| numeric_digit_to_string("threeight"): Pair(5, [3,8])
| numeric_digit_to_string("fiveight"): Pair(4, [5,8])
| numeric_digit_to_string("nineight"): Pair(4, [9,8])
| numeric_digit_to_string("sevenine"): Pair(5, [7,9])
| numeric_digit_to_string("eightwo"): Pair(5, [8,2])

def numeric_digit:
  "twone|oneight|threeight|fiveight|nineight|sevenine|eightwo|one|two|three|four|five|six|seven|eight|nine"


fun String.numeric_digits(str):
  for List:
    each Pair(st, end):
      racket.#{regexp-match-positions*}(
        racket.regexp(numeric_digit),
        str
      )
    def digit: numeric_digit_to_string(String.substring(str, st, end))
    each pair:
      match digit
      | n :: Number: [Pair(st, digit)]
      | Pair(offset, [d1, d2]) :: Pair :
          [Pair(st, d1), Pair(st + offset, d2)]
    pair

def lines2:
  ["fiveightjlkfmtwoseventhreeoneightbsr"]

def result_day2:
  for values(sum=0) (str: lines):
    def digits: String.numeric_digits(str)
    def first_digit:
       def values(i, digit): String.index_of_first_digit(str)
       for values(min_digit=digit):
           each Pair(st, digit): digits
           break_when i < st
           final_when st < i
           values(digit)

    def last_digit:
       def values(i, digit): String.index_of_last_digit(str)
       for values(max_digit=digit):
           each Pair(st, digit): digits
           skip_when st < i
           values(digit)

    sum + String.to_number(first_digit +& last_digit)

// aoc_api.submit_result_for_day(1, result_day2, ~level: 2)

