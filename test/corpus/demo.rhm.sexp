'(multi
  (group import (block (group rhombus (op /) meta open)))
  (group use_static)
  (group "Basics: expressions, variables, and functions")
  (group 10 (op *) (parens (group -3)) (op +) 2)
  (group 10 (op +) (parens (group -3)) (op *) 2)
  (group #f (op \|\|) (op !) (parens (group #f (op \|\|) #f (op &&) #t)))
  (group "example: " (op +&) (parens (group 0 (op +) 1)) (op +&) " world ")
  (group (brackets (group 1) (group 2) (group 3)))
  (group
   List
   (op |.|)
   cons
   (parens (group 0) (group (brackets (group 1) (group 2) (group 3)))))
  (group
   (brackets
    (group 0)
    (group (op &) (brackets (group 1) (group 2) (group 3)))))
  (group
   (brackets (group 1) (group 2) (group 3))
   (op ++)
   (brackets (group 4) (group 5)))
  (group def π (op =) 3.14)
  (group π)
  (group
   def
   (brackets (group ca) (group _))
   (op =)
   List
   (op |.|)
   cons
   (parens
    (group 1)
    (group List (op |.|) cons (parens (group 2) (group List (op |.|) empty)))))
  (group ca)
  (group
   def
   (parens (group (parens (group (parens (group ππ))))))
   (op =)
   π
   (op *)
   π)
  (group ππ)
  (group
   def
   (parens (group _) (group mb) (group _))
   (block (group values (parens (group "1") (group "2") (group "3")))))
  (group mb)
  (group
   def
   values
   (parens (group _) (group also_mb) (group _))
   (block (group values (parens (group "1") (group "2") (group "3")))))
  (group also_mb)
  (group fun five (parens (group _)) (block (group 5)))
  (group five (parens (group "anything")))
  (group
   3
   (op *)
   five
   (parens (group #t (op &&) #f (op \|\|) 2 (op <) 3))
   (op -)
   2)
  (group def identity (op =) fun (parens (group x)) (block (group x)))
  (group identity (parens (group "hello")))
  (group
   identity
   (parens
    (group
     1
     (op +)
     (parens (group fun (parens (group x)) (block (group x))))
     (parens (group 99)))))
  (group def identity_short (op =) (parens (group _)))
  (group identity_short (parens (group "it works!")))
  (group
   identity_short
   (parens (group 1 (op +) (parens (group _)) (parens (group 42)))))
  (group "pipe it" (op \|>) identity_short (parens (group _)))
  (group 1 (op -) 2 (op \|>) (parens (group _ (op +) 1)))
  (group "Conditionals")
  (group
   if
   1
   (op ==)
   2
   (alts (block (group "oops")) (block (group "sensible"))))
  (group
   cond
   (alts
    (block (group 1 (op ==) 3 (block (group "oops"))))
    (block (group 1 (op ==) 2 (block (group "also oops"))))
    (block (group 1 (op ==) 1 (block (group "sensible"))))
    (block (group #:else (block (group "shouldn't get here"))))))
  (group
   match
   (brackets (group 1) (group 2))
   (alts
    (block
     (group (brackets (group _) (group _) (group _)) (block (group "oops"))))
    (block
     (group
      (brackets (group x) (group y))
      (block (group (brackets (group y) (group x))))))
    (block (group #:else (block (group "shouldn't get here, either"))))))
  (group "More functions")
  (group
   fun
   six
   (parens (group _) (group #:plus (block (group amt (op =) 0))))
   (block (group 6 (op +) amt)))
  (group six (parens (group "anything")))
  (group six (parens (group "anything") (group #:plus (block (group 7)))))
  (group
   fun
   seven
   (parens
    (group x)
    (group #:plus (block (group amt (op =) x)))
    (group y (op =) amt))
   (block (group 7 (op +) amt (op -) y)))
  (group seven (parens (group 12)))
  (group seven (parens (group "anything") (group #:plus (block (group 13)))))
  (group seven (parens (group 12) (group 10)))
  (group seven (parens (group 12) (group 10) (group #:plus (block (group 8)))))
  (group
   fun
   first_one
   (parens (group (brackets (group x) (group _))))
   (block (group x)))
  (group first_one (parens (group (brackets (group "alpha") (group "beta")))))
  (group
   fun
   also_first_one
   (parens (group x (op ::) List))
   (block (group List (op |.|) first (parens (group x)))))
  (group
   also_first_one
   (parens (group (brackets (group 1) (group 2) (group 3) (group 4)))))
  (group
   fun
   add1
   (parens (group x))
   (op ::)
   Int
   (block
    (group
     match
     x
     (alts
      (block (group _ (op ::) Int (block (group x (op +) 1))))
      (block (group #:else (block (group x))))))))
  (group add1 (parens (group 100)))
  (group
   fun
   (alts
    (block
     (group
      add_two
      (parens (group x))
      (op ::)
      Number
      (block (group x (op +) 2.0))))
    (block
     (group
      add_two
      (parens (group x) (group y))
      (op ::)
      String
      (block (group x (op +&) " and " (op +&) y))))))
  (group add_two (parens (group 7)) (op .=) 9.0)
  (group add_two (parens (group 6) (group 7)) (op ==) "6 and 7")
  (group "Defining operators")
  (group
   operator
   (parens (group a (op +*) b))
   (block (group (parens (group a (op +) b)) (op *) b)))
  (group 3 (op +*) 4)
  (group
   operator
   (parens (group x mod y))
   (block
    (group x (op -) math (op |.|) floor (parens (group x (op /) y)) (op *) y)))
  (group 10 mod 3)
  (group
   operator
   (parens (group a (op ++*) b))
   (block
    (group #:weaker_than (block (group (op *))))
    (group #:associativity (block (group #:right)))
    (group (parens (group a (op +) b)) (op *) b)))
  (group 3 (op ++*) 4 (op *) 2 (op ++*) 5)
  (group 3 (op ++*) (parens (group (parens (group 4 (op *) 2)) (op ++*) 5)))
  (group operator (parens (group (op !!) b)) (block (group (op !) (op !) b)))
  (group (op !!) #t)
  (group
   operator
   (alts
    (block
     (group
      (parens (group (op **) exponent))
      (block (group 2 (op **) exponent))))
    (block
     (group
      (parens (group base (op **) exponent))
      (block
       (group
        if
        exponent
        (op ==)
        0
        (alts
         (block (group 1))
         (block
          (group
           base
           (op *)
           (parens
            (group base (op **) (parens (group exponent (op -) 1)))))))))))))
  (group 3 (op **) 8)
  (group (op **) 10)
  (group "Lists, arrays, maps, sets, and repetitions")
  (group def nums (op =) (brackets (group 1) (group 2) (group 3)))
  (group def yes_nums (op ::) List (op =) nums)
  (group
   def
   yep_nums
   (op ::)
   List
   (op |.|)
   of
   (parens (group Int))
   (op =)
   nums)
  (group nums (brackets (group 1)))
  (group 3 in nums)
  (group "hi" in (brackets (group "hi") (group "bye")))
  (group
   block
   (block
    (group use_dynamic)
    (group
     def
     also_nums
     (op =)
     if
     #t
     (alts (block (group nums)) (block (group #f))))
    (group also_nums (brackets (group 1)))))
  (group def nums_a (op =) Array (parens (group 1) (group 2) (group 3)))
  (group def yes_nums_a (op ::) Array (block (group nums_a)))
  (group
   def
   yep_nums_a
   (op ::)
   Array
   (op |.|)
   now_of
   (parens (group Int))
   (block (group nums_a)))
  (group nums_a (brackets (group 1)))
  (group nums_a (brackets (group 2)) (op :=) 30)
  (group nums_a (brackets (group 2)))
  (group 30 in nums_a)
  (group
   def
   really_nums_a
   (op ::)
   Array
   (op |.|)
   later_of
   (parens (group Int))
   (block (group nums_a)))
  (group really_nums_a (brackets (group 1)))
  (group really_nums_a (brackets (group 2)) (op :=) 42)
  (group really_nums_a (brackets (group 2)))
  (group
   def
   map
   (op =)
   Map
   (braces
    (group 17 (block (group "hello")))
    (group 24 (block (group "goodbye")))))
  (group def yes_map (op ::) Map (op =) map)
  (group
   def
   yup_map
   (op ::)
   Map
   (op |.|)
   of
   (parens (group Int) (group String))
   (op =)
   map)
  (group map)
  (group map (brackets (group 17)))
  (group 17 in map)
  (group
   def
   also_map
   (op =)
   Map
   (parens
    (group (brackets (group 1) (group "one")))
    (group (brackets (group 2) (group "two")))))
  (group also_map (brackets (group 2)))
  (group
   def
   also_also_map
   (op =)
   (braces (group 1 (block (group "one"))) (group 2 (block (group "two")))))
  (group also_also_map (brackets (group 2)))
  (group
   def
   key_map
   (op =)
   (braces
    (group (op |#'|) a (block (group "ay")))
    (group (op |#'|) b (block (group "bee")))))
  (group key_map (brackets (group (op |#'|) a)))
  (group
   def
   mixed_map
   (op =)
   (braces
    (group (op |#'|) a (block (group 1)))
    (group "b" (block (group 2)))))
  (group
   mixed_map
   (brackets (group (op |#'|) a))
   (op +)
   mixed_map
   (brackets (group "b")))
  (group
   def
   mut_map
   (op =)
   MutableMap
   (braces (group 1 (block (group "mone")))))
  (group mut_map (brackets (group 1)))
  (group mut_map (brackets (group 2)) (op :=) "mtwo")
  (group mut_map (brackets (group 2)))
  (group
   def
   a_set
   (op =)
   (braces (group 1) (group 3) (group 5) (group 7) (group 9)))
  (group
   if
   1
   in
   a_set
   (op &&)
   2
   (op !)
   in
   a_set
   (alts
    (block (group "ok"))
    (block (group error (parens (group "no way!"))))))
  (group def (brackets (group x) (group y) (group (op ...))) (op =) nums)
  (group (brackets (group y) (group (op ...))))
  (group
   (brackets (group y) (group (op ...)) (group 0) (group y) (group (op ...))))
  (group (brackets (group 100) (group 1000) (group (op &) nums)))
  (group (brackets (group (op &) nums) (group 0) (group (op &) nums)))
  (group
   (braces (group (op &) also_also_map) (group 100 (block (group "hundred")))))
  (group
   (braces
    (group 100 (block (group "hundred")))
    (group (op &) also_also_map)
    (group (op &) map)))
  (group (braces (group (op &) a_set) (group 0)))
  (group
   block
   (block
    (group fun f (parens (group a) (group _)) (block (group a)))
    (group f (parens (group y) (group (op ...))))))
  (group
   fun
   (alts
    (block (group slow_add (parens) (block (group 0))))
    (block
     (group
      slow_add
      (parens (group x) (group y) (group (op ...)))
      (block (group x (op +) slow_add (parens (group y) (group (op ...)))))))))
  (group slow_add (parens (group 1) (group 2) (group 3)))
  (group
   fun
   (alts
    (block (group also_slow_add (parens) (block (group 0))))
    (block
     (group
      also_slow_add
      (parens (group x) (group (op &) y))
      (block (group x (op +) slow_add (parens (group (op &) y))))))))
  (group also_slow_add (parens (group 1) (group 2) (group 3)))
  (group
   fun
   (alts
    (block (group sum (parens (group (brackets))) (block (group 0))))
    (block
     (group
      sum
      (parens (group (brackets (group x) (group y) (group (op ...)))))
      (block
       (group
        x
        (op +)
        sum
        (parens (group (brackets (group y) (group (op ...)))))))))))
  (group sum (parens (group (brackets (group 1) (group 2) (group 3)))))
  (group
   fun
   (alts
    (block
     (group
      is_sorted
      (parens (group (brackets) (op \|\|) (brackets (group _))))
      (block (group #t))))
    (block
     (group
      is_sorted
      (parens
       (group
        (brackets (group head) (group next) (group tail) (group (op ...)))))
      (block
       (group
        head
        (op .<=)
        next
        (op &&)
        is_sorted
        (parens
         (group (brackets (group next) (group tail) (group (op ...)))))))))))
  (group
   is_sorted
   (parens
    (group (brackets (group 1) (group 2) (group 3) (group 4) (group 5)))))
  (group
   is_sorted
   (parens
    (group (brackets (group 1) (group 2) (group 30) (group 4) (group 5)))))
  (group "Classes as records")
  (group class Posn (parens (group x) (group y)))
  (group Posn (parens (group 1) (group 2)))
  (group Posn (parens (group 2) (group 3)) (op |.|) x)
  (group Posn (op |.|) x (parens (group Posn (parens (group 2) (group 3)))))
  (group
   fun
   md
   (parens (group p (op ::) Posn))
   (block (group p (op |.|) x (op +) p (op |.|) y)))
  (group md (parens (group Posn (parens (group 1) (group 4)))))
  (group
   fun
   md2
   (parens (group p))
   (block (group use_dynamic) (group p (op |.|) x (op +) p (op |.|) y)))
  (group md2 (parens (group Posn (parens (group 5) (group 6)))))
  (group
   block
   (block
    (group class Chromosomes (parens (group x) (group y) (group other)))
    (group
     md2
     (parens
      (group Chromosomes (parens (group 100) (group 200) (group 314)))))))
  (group
   fun
   md3
   (parens (group p (op :~) Posn))
   (block (group p (op |.|) x (op +) p (op |.|) y)))
  (group md3 (parens (group Posn (parens (group 7) (group 8)))))
  (group Posn (parens (group 1) (group 2)) is_a Posn)
  (group 5 is_a Posn)
  (group
   (parens (group Posn (parens (group 1) (group 2)) (op ::) Posn))
   (op |.|)
   x)
  (group
   fun
   (alts
    (block (group size (parens (group n (op ::) Int)) (block (group n))))
    (block
     (group
      size
      (parens (group p (op ::) Posn))
      (block (group p (op |.|) x (op +) p (op |.|) y))))
    (block
     (group size (parens (group a) (group b)) (block (group a (op +) b))))))
  (group size (parens (group Posn (parens (group 8) (group 6)))))
  (group size (parens (group 1) (group 2)))
  (group
   def
   Posn
   (parens (group px) (group py))
   (op =)
   Posn
   (parens (group 1) (group 2)))
  (group (brackets (group px) (group py)))
  (group class IPosn (parens (group x (op ::) Int) (group y (op ::) Int)))
  (group
   class
   ILine
   (parens (group p1 (op ::) IPosn) (group p2 (op ::) IPosn)))
  (group IPosn (parens (group 1) (group 2)) (op |.|) x)
  (group
   def
   l1
   (op =)
   ILine
   (parens
    (group IPosn (parens (group 1) (group 2)))
    (group IPosn (parens (group 3) (group 4)))))
  (group l1 (op |.|) p2 (op |.|) x)
  (group ILine (op |.|) p1 (parens (group l1)) (op |.|) x)
  (group (parens (group l1 (op |.|) p1 (op ::) IPosn)) (op |.|) x)
  (group
   block
   (block
    (group def ILine (parens (group p1) (group p2)) (op =) l1)
    (group p1 (op |.|) x (op +) p2 (op |.|) y)))
  (group "Classes and interfaces with methods")
  (group interface Shape (block (group method area (parens) (op ::) Real)))
  (group
   class
   Circle
   (parens (group radius))
   (block
    (group implements Shape)
    (group
     override
     area
     (parens)
     (block (group π (op *) radius (op *) radius)))))
  (group
   class
   Rectangle
   (parens (group width) (group height))
   (block
    (group implements Shape)
    (group nonfinal)
    (group override area (parens) (block (group width (op *) height)))))
  (group
   class
   Square
   (parens (group color))
   (block
    (group extends Rectangle)
    (group
     constructor
     (parens (group side))
     (block
      (group
       super
       (parens (group side) (group side))
       (parens (group "blue")))))))
  (group
   def
   s
   (op ::)
   Shape
   (block
    (group def pick (op =) 2)
    (group
     match
     pick
     (alts
      (block (group 0 (block (group Circle (parens (group 2))))))
      (block (group 1 (block (group Rectangle (parens (group 3) (group 4))))))
      (block (group 2 (block (group Square (parens (group 5))))))))))
  (group s (op |.|) area (parens))
  (group "Syntax objects and macros")
  (group (quotes (group 1 (op +) 2)))
  (group
   match
   (quotes (group 1 (op +) 2))
   (alts
    (block
     (group
      (quotes (group (op $) x (op +) (op $) y))
      (block (group (brackets (group x) (group y))))))))
  (group
   match
   (quotes (group 1 (op *) 2))
   (alts
    (block
     (group
      (quotes (group (op $) x (op +) (op $) y))
      (block (group (brackets (group x) (group y))))))
    (block
     (group
      (quotes (group x (op *) y))
      (block (group "matched literal x and y"))))
    (block
     (group
      (quotes (group (op $) x (op *) (op $) y))
      (block (group (brackets (group x) (group y))))))))
  (group
   match
   (quotes (group 1 (op +) 2))
   (alts
    (block
     (group
      (quotes (group (op $) x (op +) (op $) y))
      (block (group (quotes (group (op $) y (op +) (op $) x))))))))
  (group
   match
   (quotes (group 1 2 3))
   (alts
    (block
     (group
      (quotes (group (op $) n (op ...)))
      (block
       (group
        (quotes
         (group
          (parens (group (brackets (group (op $) n))) (group (op ...)))))))))))
  (group
   match
   (quotes
    (group (parens (group (brackets (group (braces (group 1 (op +) 2))))))))
   (alts
    (block
     (group
      (quotes
       (group (parens (group (brackets (group (braces (group (op $) g))))))))
      (block (group g))))))
  (group
   match
   (quotes
    (group
     (parens
      (group
       (brackets (group (braces (group 1 (op +) 2) (group 3 (op +) 4))))))))
   (alts
    (block
     (group
      (quotes
       (group
        (parens
         (group
          (brackets
           (group
            (braces (group (op $) (parens (group g (op ::) Multi))))))))))
      (block (group g))))))
  (group
   macro
   (quotes (group thunk (block (group (op $) body))))
   (block (group (quotes (group fun (parens) (block (group (op $) body)))))))
  (group
   def
   delayed_area
   (op =)
   thunk
   (block (group s (op |.|) area (parens))))
  (group delayed_area (parens))
  (group
   expr
   (op |.|)
   macro
   (quotes
    (group
     find_matching_name
     (op $)
     expr
     (op ...)
     (block (group (op $) id (op ...)))))
   (block
    (group
     let
     (brackets (group name) (group (op ...)))
     (op =)
     (brackets (group to_string (parens (group id))) (group (op ...))))
    (group
     (quotes
      (group
       block
       (block
        (group def val (op =) (op $) expr (op ...))
        (group
         cond
         (alts
          (block (group val (op ==) (op $) id (block (group (op $) name))))
          (block (group (op ...)))))))))))
  (group
   block
   (block
    (group def x (op =) 1)
    (group def y (op =) 2)
    (group def z (op =) 3)
    (group find_matching_name 1 (op +) 1 (block (group x y z)))))
  (group
   defn
   (op |.|)
   macro
   (quotes (group def_fives (block (group (op $) id (op ...)))))
   (block (group (quotes (group def (op $) id (op =) 5) (group (op ...))))))
  (group def_fives (block (group cinco wu lima)))
  (group wu (op +) lima (op +) cinco)
  (group "Potpourri")
  (group
   namespace
   Geometry
   (block
    (group
     fun
     combined_areas
     (parens (group s1 (op ::) Shape) (group s2 (op ::) Shape))
     (block
      (group s1 (op |.|) area (parens) (op +) s2 (op |.|) area (parens))))
    (group export (block (group combined_areas) (group Shape Circle Square)))))
  (group
   Geometry
   (op |.|)
   combined_areas
   (parens
    (group Geometry (op |.|) Square (parens (group 1)))
    (group Geometry (op |.|) Square (parens (group 2)))))
  (group fun check_later (parens) (block (group ok_later)))
  (group let accum (block (group 1)))
  (group let accum (block (group accum (op +) 1)))
  (group let accum (block (group accum (op +) 1)))
  (group accum)
  (group def ok_later (op =) "ok")
  (group check_later (parens))
  (group
   fun
   enumerate
   (parens (group l (op ::) List))
   (block
    (group
     for
     (parens (group v in l) (group i in 0 (op ..)))
     (block (group println (parens (group i (op +&) ". " (op +&) v)))))))
  (group
   enumerate
   (parens (group (brackets (group "a") (group "b") (group "c")))))
  (group
   fun
   grid
   (parens (group m) (group n))
   (block
    (group
     for
     List
     (block
      (group each i in 0 (op ..) m)
      (group each j in 0 (op ..) n)
      (group (brackets (group i) (group j)))))))
  (group grid (parens (group 2) (group 3)))
  (group
   fun
   loop_sum
   (parens (group l (op ::) List))
   (block
    (group
     for
     values
     (parens (group sum (op =) 0))
     (parens (group i in l))
     (block (group sum (op +) i)))))
  (group loop_sum (parens (group (brackets (group 2) (group 3) (group 4)))))
  (group def mutable count (op =) 0)
  (group count (op :=) count (op +) 1)
  (group count))
