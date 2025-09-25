'(multi
  (group
   import
   (block
    (group lib (parens (group "racket/main.rkt")) as racket)
    (group
     lib
     (parens (group "racket/string.rkt"))
     as
     racket_string
     (block
      (group
       rename
       (block
        (group string-split as split)
        (group non-empty-string? as string_is_not_empty)))))))
  (group
   export
   (block
    (group string)
    (group set)
    (group array)
    (group list)
    (group List)
    (group Point)))
  (group
   namespace
   array
   (block
    (group export (block (group sum)))
    (group
     fun
     sum
     (parens (group arr (op ::) Array))
     (op ::)
     Number
     (block
      (group
       for
       values
       (parens (group sum (op =) 0))
       (block (group each elt (block (group arr))) (group sum (op +) elt)))))))
  (group
   namespace
   set
   (block
    (group export (block (group of_list)))
    (group
     fun
     of_list
     (parens (group xs (op ::) List))
     (op ::)
     Set
     (block
      (group
       for
       Set
       (parens (group x (block (group xs))))
       (block (group x)))))))
  (group
   namespace
   string
   (block
    (group
     export
     (block (group split_lines) (group split) (group join) (group trim)))
    (group
     fun
     trim
     (parens (group s (op ::) ReadableString))
     (op ::)
     String
     (block
      (group
       (parens
        (group
         racket_string
         (op |.|)
         string-trim
         (parens (group s))
         (op ::)
         ReadableString))
       (op |.|)
       to_string
       (parens))))
    (group
     fun
     join
     (parens
      (group #:join_by (block (group join (op =) "")))
      (group s (op ::) ReadableString)
      (group (op ...)))
     (op ::)
     String
     (block
      (group
       (parens
        (group
         racket_string
         (op |.|)
         string-join
         (parens (group (brackets (group s) (group (op ...)))) (group join))
         (op ::)
         ReadableString))
       (op |.|)
       to_string
       (parens))))
    (group
     fun
     split_lines
     (parens (group s (op ::) ReadableString))
     (op ::)
     List
     (op |.|)
     of
     (parens (group ReadableString))
     (block
      (group racket_string (op |.|) split (parens (group s) (group "\n")))))
    (group
     fun
     split
     (parens
      (group s (op ::) ReadableString)
      (group on (op ::) ReadableString)
      (group #:keep_blank (block (group keep_blank (op =) #f))))
     (op ::)
     List
     (op |.|)
     of
     (parens (group String))
     (block
      (group
       let
       segments
       (op =)
       racket_string
       (op |.|)
       split
       (parens (group s) (group on)))
      (group
       for
       List
       (block
        (group each seg (block (group segments)))
        (group
         keep_when
         keep_blank
         (op \|\|)
         racket_string
         (op |.|)
         string_is_not_empty
         (parens (group seg)))
        (group seg (op |.|) to_string (parens))))))))
  (group
   namespace
   list
   (block
    (group
     export
     (block (group is_empty) (group partition) (group insert_into_sorted)))
    (group
     fun
     insert_into_sorted
     (parens
      (group elt)
      (group ls (op ::) List)
      (group #:key (block (group keyf))))
     (block
      (group
       match
       ls
       (alts
        (block
         (group
          (brackets (group hd) (group tl) (group (op ...)))
          when
          keyf
          (parens (group hd))
          (op <=)
          keyf
          (parens (group elt))
          (block
           (group
            (brackets (group elt) (group hd) (group tl) (group (op ...)))))))
        (block
         (group
          List
          (op |.|)
          cons
          (parens (group hd) (group tl))
          (block
           (group
            List
            (op |.|)
            cons
            (parens
             (group hd)
             (group
              insert_into_sorted
              (parens
               (group elt)
               (group tl)
               (group #:key (block (group keyf))))))))))
        (block (group (brackets) (block (group (brackets (group elt))))))))))
    (group
     fun
     is_empty
     (parens (group ls (op ::) List))
     (op ::)
     Boolean
     (block
      (group
       match
       ls
       (alts
        (block (group (brackets) (block (group #t))))
        (block
         (group
          List
          (op |.|)
          cons
          (parens (group _) (group _))
          (block (group #f))))))))
    (group
     fun
     partition
     (parens (group input_ls (op ::) List) (group by))
     (op ::)
     List
     (block
      (group
       fun
       loop
       (parens (group acc) (group current_ls) (group tail))
       (block
        (group
         match
         tail
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
               (group current_ls (op |.|) reverse (parens))
               (group acc))))))
          (block
           (group
            List
            (op |.|)
            cons
            (parens (group hd) (group tail))
            (block
             (group
              if
              hd
              (op ==)
              by
              (alts
               (block
                (group
                 loop
                 (parens
                  (group
                   List
                   (op |.|)
                   cons
                   (parens
                    (group current_ls (op |.|) reverse (parens))
                    (group acc)))
                  (group (brackets))
                  (group tail))))
               (block
                (group
                 loop
                 (parens
                  (group acc)
                  (group
                   List
                   (op |.|)
                   cons
                   (parens (group hd) (group current_ls)))
                  (group tail)))))))))))))
      (group
       let
       result
       (block
        (group
         loop
         (parens (group (brackets)) (group (brackets)) (group input_ls)))))
      (group result (op |.|) reverse (parens))))))
  (group
   fun
   List
   (op |.|)
   all
   (parens (group pred (op ::) Function) (group ls))
   (block
    (group
     for
     values
     (parens (group result (op =) #t))
     (block
      (group each elt (block (group ls)))
      (group skip_when pred (parens (group elt)))
      (group final_when #t)
      (group #f)))))
  (group
   fun
   List
   (op |.|)
   nth
   (parens (group ls) (group ind))
   (block
    (group
     if
     ind
     (op <)
     0
     (alts
      (block (group #f))
      (block
       (group
        for
        values
        (parens (group result (op =) #f))
        (block
         (group
          each
          (block
           (group elt (block (group ls)))
           (group i (block (group 0 (op ..))))))
         (group final_when i (op ==) ind)
         (group
          if
          i
          (op ==)
          ind
          (alts (block (group result)) (block (group #f)))))))))))
  (group
   fun
   List
   (op |.|)
   set_nth
   (parens (group ls) (group ind) (group vl))
   (block
    (group
     match
     (brackets (group ls) (group ind))
     (alts
      (block
       (group
        (brackets
         (group List (op |.|) cons (parens (group _) (group tail)))
         (group 0))
        (block (group List (op |.|) cons (parens (group vl) (group tail))))))
      (block
       (group
        (brackets
         (group List (op |.|) cons (parens (group hd) (group tail)))
         (group n))
        (block
         (group
          List
          (op |.|)
          cons
          (parens
           (group hd)
           (group
            List
            (op |.|)
            set_nth
            (parens (group tail) (group n (op -) 1) (group vl))))))))))))
  (group
   fun
   (alts
    (block
     (group
      List
      (op |.|)
      find_index
      (parens (group ls) (group pred))
      (block
       (group
        List
        (op |.|)
        find_index
        (parens (group ls) (group pred) (group 0))))))
    (block
     (group
      List
      (op |.|)
      find_index
      (parens (group (brackets)) (group pred) (group ind))
      (block (group #f))))
    (block
     (group
      List
      (op |.|)
      find_index
      (parens
       (group List (op |.|) cons (parens (group hd) (group tail)))
       (group pred)
       (group ind))
      (block
       (group
        if
        pred
        (parens (group hd))
        (alts
         (block (group ind))
         (block
          (group
           List
           (op |.|)
           find_index
           (parens (group tail) (group pred) (group ind (op +) 1)))))))))))
  (group
   class
   Point
   (parens (group x (op ::) Int) (group y (op ::) Int))
   (block
    (group
     method
     abs_manhatten_distance
     (parens (group other (op ::) Point))
     (block
      (group
       math
       (op |.|)
       abs
       (parens (group x (op -) other (op |.|) x))
       (op +)
       math
       (op |.|)
       abs
       (parens (group y (op -) other (op |.|) y)))))
    (group method sum (parens) (block (group x (op +) y)))
    (group
     method
     add
     (parens (group other))
     (block
      (group
       Point
       (parens
        (group x (op +) other (op |.|) x)
        (group y (op +) other (op |.|) y)))))
    (group
     method
     sub
     (parens (group other))
     (block
      (group
       Point
       (parens
        (group x (op -) other (op |.|) x)
        (group y (op -) other (op |.|) y)))))
    (group
     method
     mul
     (parens (group by))
     (block (group Point (parens (group x (op *) by) (group y (op *) by)))))
    (group
     method
     div
     (parens (group by))
     (block (group Point (parens (group x (op /) by) (group y (op /) by)))))
    (group
     method
     north
     (parens (group #:delta (block (group delta (op =) 1))))
     (op ::)
     Point
     (block (group Point (parens (group x) (group y (op -) delta)))))
    (group
     method
     east
     (parens (group #:delta (block (group delta (op =) 1))))
     (op ::)
     Point
     (block (group Point (parens (group x (op +) delta) (group y)))))
    (group
     method
     south
     (parens (group #:delta (block (group delta (op =) 1))))
     (op ::)
     Point
     (block (group Point (parens (group x) (group y (op +) delta)))))
    (group
     method
     west
     (parens (group #:delta (block (group delta (op =) 1))))
     (op ::)
     Point
     (block (group Point (parens (group x (op -) delta) (group y))))))))
