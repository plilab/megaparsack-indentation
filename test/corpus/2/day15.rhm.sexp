'(multi
  (group
   import
   (block
    (group file (parens (group "./utils/aoc_api.rhm")))
    (group file (parens (group "./utils/utils.rhm")))
    (group file (parens (group "./utils/lang.rhm")) open)
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
   (block (group aoc_api (op |.|) retrieve_input_for_day (parens (group 15)))))
  (group
   def
   test_input
   (block
    (group
     multiline
     (block (group "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7")))))
  (group
   fun
   hash
   (parens (group s (op ::) ReadableString))
   (block
    (group let mutable current_value (op =) 0)
    (group
     for
     (parens (group c (block (group s))))
     (block
      (group
       current_value
       (op :=)
       current_value
       (op +)
       Char
       (op |.|)
       to_int
       (parens (group c)))
      (group current_value (op :=) current_value (op *) 17)
      (group current_value (op :=) current_value mod 256)))
    (group current_value)))
  (group check (block (group hash (parens (group "HASH"))) (group #:is 52)))
  (group
   fun
   parse_input
   (parens (group s (op ::) ReadableString))
   (block
    (group
     utils
     (op |.|)
     string
     (op |.|)
     split
     (parens (group s) (group ",")))))
  (group
   fun
   solve_for_part1
   (parens (group s (op ::) ReadableString))
   (block
    (group
     for
     values
     (parens (group sum (op =) 0))
     (block
      (group each instr (block (group parse_input (parens (group s)))))
      (group sum (op +) hash (parens (group instr)))))))
  (group
   check
   (block
    (group solve_for_part1 (parens (group test_input)))
    (group #:is 1320)))
  (group def result1 (block (group solve_for_part1 (parens (group input)))))
  (group
   fun
   (alts
    (block
     (group
      update_assoc
      (parens (group label) (group vl) (group (brackets)))
      (block
       (group
        error
        (parens (group "key " (op +&) label (op +&) " does not exist"))))))
    (block
     (group
      update_assoc
      (parens
       (group label)
       (group vl)
       (group
        List
        (op |.|)
        cons
        (parens (group (brackets (group olabel) (group ovl))) (group rest))))
      (block
       (group
        if
        racket
        (op |.|)
        equal?
        (parens (group label) (group olabel))
        (alts
         (block
          (group
           List
           (op |.|)
           cons
           (parens (group (brackets (group olabel) (group vl))) (group rest))))
         (block
          (group
           List
           (op |.|)
           cons
           (parens
            (group (brackets (group olabel) (group ovl)))
            (group
             update_assoc
             (parens (group label) (group vl) (group rest)))))))))))))
  (group
   fun
   (alts
    (block
     (group
      remove_assoc
      (parens (group label) (group (brackets)))
      (block
       (group
        error
        (parens (group "key " (op +&) label (op +&) " does not exist"))))))
    (block
     (group
      remove_assoc
      (parens
       (group label)
       (group
        List
        (op |.|)
        cons
        (parens (group (brackets (group olabel) (group ovl))) (group rest))))
      (block
       (group
        if
        racket
        (op |.|)
        equal?
        (parens (group label) (group olabel))
        (alts
         (block (group rest))
         (block
          (group
           List
           (op |.|)
           cons
           (parens
            (group (brackets (group olabel) (group ovl)))
            (group remove_assoc (parens (group label) (group rest)))))))))))))
  (group
   class
   BoxList
   (parens
    (group
     box_contents_set
     (op ::)
     Array
     (op |.|)
     of
     (parens (group MutableSet)))
    (group
     box_contents
     (op ::)
     Array
     (op |.|)
     of
     (parens (group List (op |.|) of (parens (group List))))))
   (block
    (group
     constructor
     (parens)
     (block
      (group
       def
       box_contents_set
       (op =)
       Array
       (op |.|)
       make
       (parens (group 256) (group #f)))
      (group
       def
       box_contents
       (op =)
       Array
       (op |.|)
       make
       (parens (group 256) (group #f)))
      (group
       for
       (parens (group i (block (group 0 (op ..) 256))))
       (block
        (group
         box_contents_set
         (brackets (group i))
         (op :=)
         MutableSet
         (parens))
        (group box_contents (brackets (group i)) (op :=) (brackets))))
      (group super (parens (group box_contents_set) (group box_contents)))))
    (group
     method
     add_label
     (parens (group label) (group vl))
     (block
      (group let ind (op =) hash (parens (group label)))
      (group
       if
       box_contents_set
       (brackets (group ind))
       (brackets (group label))
       (alts
        (block
         (group
          box_contents
          (brackets (group ind))
          (op :=)
          update_assoc
          (parens
           (group label)
           (group vl)
           (group box_contents (brackets (group ind))))))
        (block
         (group
          box_contents_set
          (brackets (group ind))
          (brackets (group label))
          (op :=)
          #t)
         (group
          box_contents
          (brackets (group ind))
          (op :=)
          List
          (op |.|)
          cons
          (parens
           (group (brackets (group label) (group vl)))
           (group box_contents (brackets (group ind))))))))))
    (group
     method
     remove_label
     (parens (group label))
     (block
      (group let ind (op =) hash (parens (group label)))
      (group
       when
       box_contents_set
       (brackets (group ind))
       (brackets (group label))
       (alts
        (block
         (group
          box_contents_set
          (brackets (group ind))
          (brackets (group label))
          (op :=)
          #f)
         (group
          box_contents
          (brackets (group ind))
          (op :=)
          remove_assoc
          (parens
           (group label)
           (group box_contents (brackets (group ind))))))))))
    (group
     method
     score
     (parens)
     (block
      (group
       for
       values
       (parens (group sum (op =) 0))
       (parens (group i (block (group 0 (op ..) 256))))
       (block
        (group
         skip_when
         box_contents_set
         (brackets (group i))
         (op |.|)
         length
         (parens)
         (op ==)
         0)
        (group
         sum
         (op +)
         (parens (group i (op +) 1))
         (op *)
         for
         values
         (parens (group result (op =) 0))
         (block
          (group
           each
           (block
            (group
             (brackets (group _) (group elt))
             (block
              (group
               (parens
                (group
                 box_contents
                 (brackets (group i))
                 (op |.|)
                 reverse
                 (parens))))))
            (group i (block (group 1 (op ..))))))
          (group result (op +) elt (op *) i)))))))))
  (group
   fun
   handle_instruction
   (parens (group boxes (op ::) BoxList) (group line (op ::) ReadableString))
   (block
    (group
     cond
     (alts
      (block
       (group
        racket
        (op |.|)
        string-contains?
        (parens (group line) (group "="))
        (block
         (group
          let
          (brackets (group label) (group vl))
          (op =)
          utils
          (op |.|)
          string
          (op |.|)
          split
          (parens (group line) (group "=")))
         (group
          boxes
          (op |.|)
          add_label
          (parens
           (group label)
           (group String (op |.|) to_number (parens (group vl))))))))
      (block
       (group
        racket
        (op |.|)
        string-contains?
        (parens (group line) (group "-"))
        (block
         (group
          let
          (brackets (group label))
          (op =)
          utils
          (op |.|)
          string
          (op |.|)
          split
          (parens (group line) (group "-")))
         (group boxes (op |.|) remove_label (parens (group label))))))))))
  (group
   fun
   solve_for_part2
   (parens (group raw_input (op ::) ReadableString))
   (block
    (group def data (op =) parse_input (parens (group raw_input)))
    (group def boxes (op =) BoxList (parens))
    (group
     for
     (parens (group ins (block (group data))))
     (block (group handle_instruction (parens (group boxes) (group ins)))))
    (group boxes (op |.|) score (parens))))
  (group
   check
   (block
    (group solve_for_part2 (parens (group test_input)))
    (group #:is 145)))
  (group def result2 (op =) solve_for_part2 (parens (group input)))
  (group result2))
