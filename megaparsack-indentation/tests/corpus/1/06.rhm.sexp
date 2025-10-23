'(multi
  (group
   fun
   calculate_first
   (parens (group max_time) (group min_distance))
   (block
    (group
     for
     values
     (parens (group n (op =) 0))
     (block
      (group each i (block (group 1 (op ..) max_time)))
      (group def remaining_time (op =) max_time (op -) i)
      (group def distance (op =) remaining_time (op *) i)
      (group break_when distance (op >) min_distance)
      (group i)))))
  (group
   fun
   calculate_last
   (parens (group max_time) (group min_distance))
   (block
    (group
     for
     values
     (parens (group n (op =) 0))
     (block
      (group each i (block (group 1 (op ..) max_time)))
      (group def remaining_time (op =) i)
      (group
       def
       distance
       (op =)
       remaining_time
       (op *)
       (parens (group max_time (op -) i)))
      (group break_when distance (op >) min_distance)
      (group i)))))
  (group
   fun
   calculate_choices
   (parens (group max_time) (group min_distance))
   (block
    (group
     def
     losing
     (block
      (group
       calculate_first
       (parens (group max_time) (group min_distance))
       (op +)
       calculate_last
       (parens (group max_time) (group min_distance)))))
    (group max_time (op -) 1 (op -) losing)))
  (group
   check
   (block
    (group calculate_choices (parens (group 7) (group 9)) #:is 4)
    (group calculate_choices (parens (group 15) (group 40)) #:is 8)
    (group calculate_choices (parens (group 30) (group 200)) #:is 9)))
  (group
   module
   part1
   (block
    (group
     calculate_choices
     (parens (group 46) (group 208))
     (op *)
     calculate_choices
     (parens (group 85) (group 1412))
     (op *)
     calculate_choices
     (parens (group 75) (group 1257))
     (op *)
     calculate_choices
     (parens (group 82) (group 1410)))))
  (group
   check
   (block
    (group
     calculate_choices
     (parens (group 71530) (group 940200))
     #:is
     71503)))
  (group
   module
   part2
   (block
    (group
     calculate_choices
     (parens (group 46857582) (group 208141212571410))))))
