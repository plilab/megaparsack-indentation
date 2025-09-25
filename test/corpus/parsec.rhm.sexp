'(multi
  (group
   import
   (block
    (group lib (parens (group "racket/base.rkt")))
    (group rhombus (op /) compat (op /) stream open)))
  (group
   export
   (block
    (group string_to_list)
    (group parse)
    (group parse_string)
    (group pure)
    (group sequence)
    (group choice)
    (group try)
    (group satisfy)
    (group any)
    (group label)
    (group char)
    (group string)
    (group digit)
    (group integer)
    (group spaces)
    (group many1)
    (group parse_sequence)))
  (group namespace R (block (group export to_string)))
  (group
   fun
   string_to_list
   (parens (group string (op ::) String))
   (op :~)
   List
   (op |.|)
   of
   (parens (group Char))
   (block
    (group
     for
     List
     (block
      (group each i (block (group 0 (op ..) string (op |.|) length (parens))))
      (group string (brackets (group i)))))))
  (group
   class
   Message
   (parens
    (group token)
    (group expected (op ::) List (op |.|) of (parens (group String))))
   (block
    (group
     method
     replace_expected
     (parens (group label (op ::) String))
     (op ::)
     Message
     (block
      (group
       this
       with
       (parens (group expected (op =) (brackets (group label)))))))
    (group
     method
     to_string
     (parens)
     (block
      (group
       "got "
       (op ++)
       format_token
       (parens)
       (op ++)
       " expected "
       (op ++)
       format_expected
       (parens))))
    (group
     method
     merge
     (parens (group other (op ::) Message))
     (op ::)
     Message
     (block
      (group
       this
       with
       (parens
        (group expected (op =) expected (op ++) other (op |.|) expected)))))
    (group
     private
     method
     format_token
     (parens)
     (op ::)
     String
     (block
      (group
       match
       token
       (alts
        (block (group (brackets) (block (group "<empty>"))))
        (block
         (group
          _
          (block
           (group
            R
            (op |.|)
            to_string
            (parens
             (group token)
             (group #:mode (block (group (op |#'|) expr))))))))))))
    (group
     private
     method
     format_expected
     (parens)
     (op ::)
     String
     (block
      (group
       match
       expected
       (alts
        (block (group (brackets) (block (group "<empty>"))))
        (block (group (brackets (group e)) (block (group e))))
        (block
         (group
          es
          (block (group format_expected_long (parens (group es))))))))))
    (group
     private
     method
     (alts
      (block
       (group
        format_expected_long
        (parens (group (brackets (group e0) (group e1))))
        (block
         (group use_dynamic)
         (group
          e0
          (op |.|)
          to_string
          (parens)
          (op ++)
          " or "
          (op ++)
          e1
          (op |.|)
          to_string
          (parens)))))
      (block
       (group
        format_expected_long
        (parens (group (brackets (group e) (group (op &) erest))))
        (block
         (group use_dynamic)
         (group
          e
          (op |.|)
          to_string
          (parens)
          (op ++)
          ", "
          (op ++)
          format_expected_long
          (parens (group erest))))))))))
  (group
   class
   Ok
   (parens
    (group value)
    (group stream (op ::) Stream)
    (group message (op ::) Message)))
  (group class Error (parens (group message (op ::) Message)))
  (group
   annot
   (op |.|)
   macro
   (quotes (group Result))
   (block (group (quotes (group Ok (op \|\|) Error)))))
  (group
   class
   Parsed
   (parens
    (group result (op ::) Result)
    (group is_empty (op ::) Boolean (op =) #f)))
  (group
   fun
   pure
   (parens (group v))
   (block
    (group
     fun
     (parens (group stream (op ::) Stream))
     (block
      (group
       Parsed
       (parens
        (group
         Ok
         (parens
          (group v)
          (group stream)
          (group Message (parens (group #f) (group (brackets))))))))))))
  (group
   fun
   sequence
   (parens (group p) (group f))
   (block
    (group
     fun
     (parens (group stream0 (op ::) Stream))
     (block
      (group
       match
       p
       (parens (group stream0))
       (alts
        (block
         (group
          Parsed
          (parens
           (group Ok (parens (group v) (group stream1) (group _)))
           (group #t))
          (block (group f (parens (group v)) (parens (group stream1))))))
        (block
         (group
          Parsed
          (parens (group _) (group #t))
          (op &&)
          p
          (block (group p))))
        (block
         (group
          Parsed
          (parens
           (group Ok (parens (group v) (group stream1) (group _)))
           (group #f))
          (block
           (group
            match
            f
            (parens (group v))
            (parens (group stream1))
            (alts
             (block
              (group
               Parsed
               (parens (group _) (group #t))
               (op &&)
               p
               (block (group p with (parens (group is_empty (op =) #f))))))
             (block (group p (block (group p)))))))))
        (block (group p (block (group p))))))))))
  (group
   fun
   choice
   (parens (group a_p) (group b_p))
   (block
    (group
     fun
     merge_ok
     (parens
      (group v)
      (group stream)
      (group message0 (op ::) Message)
      (group message1 (op ::) Message))
     (block
      (group
       Parsed
       (parens
        (group
         Ok
         (parens
          (group v)
          (group stream)
          (group message0 (op |.|) merge (parens (group message1)))))
        (group #t)))))
    (group
     fun
     merge_error
     (parens (group message0 (op ::) Message) (group message1 (op ::) Message))
     (block
      (group
       Parsed
       (parens
        (group
         Error
         (parens (group message0 (op |.|) merge (parens (group message1)))))
        (group #t)))))
    (group
     fun
     (parens (group stream0 (op ::) Stream))
     (block
      (group
       match
       a_p
       (parens (group stream0))
       (alts
        (block
         (group
          Parsed
          (parens (group Error (parens (group message0))) (group #t))
          (block
           (group
            match
            b_p
            (parens (group stream0))
            (alts
             (block
              (group
               Parsed
               (parens (group Error (parens (group message1))) (group #t))
               (block
                (group
                 merge_error
                 (parens (group message0) (group message1))))))
             (block
              (group
               Parsed
               (parens
                (group Ok (parens (group v) (group stream1) (group message1)))
                (group #f))
               (block
                (group
                 merge_ok
                 (parens
                  (group v)
                  (group stream1)
                  (group message0)
                  (group message1))))))
             (block (group parsed (block (group parsed)))))))))
        (block
         (group
          Parsed
          (parens
           (group Ok (parens (group v) (group stream1) (group message0)))
           (group #t))
          (block
           (group
            match
            b_p
            (parens (group stream0))
            (alts
             (block
              (group
               Parsed
               (parens (group Error (parens (group message1))) (group #t))
               (block
                (group
                 merge_ok
                 (parens
                  (group v)
                  (group stream1)
                  (group message0)
                  (group message1))))))
             (block
              (group
               Parsed
               (parens
                (group Ok (parens (group _) (group _) (group message1)))
                (group #t))
               (block
                (group
                 merge_ok
                 (parens
                  (group v)
                  (group stream1)
                  (group message0)
                  (group message1))))))
             (block (group parsed (block (group parsed)))))))))
        (block (group parsed (block (group parsed))))))))))
  (group
   fun
   satisfy
   (parens (group is_satisfied))
   (block
    (group
     fun
     (parens (group stream (op ::) Stream))
     (block
      (group
       if
       stream
       (op |.|)
       is_empty
       (parens)
       (alts
        (block
         (group
          Parsed
          (parens
           (group
            Error
            (parens
             (group Message (parens (group stream) (group (brackets))))))
           (group #t))))
        (block
         (group def tok (op =) stream (op |.|) first)
         (group
          if
          is_satisfied
          (parens (group tok))
          (alts
           (block
            (group
             Parsed
             (parens
              (group
               Ok
               (parens
                (group tok)
                (group stream (op |.|) rest)
                (group Message (parens (group #f) (group (brackets))))))
              (group #f))))
           (block
            (group
             Parsed
             (parens
              (group
               Error
               (parens
                (group Message (parens (group tok) (group (brackets))))))
              (group #t)))))))))))))
  (group
   fun
   any
   (parens (group stream (op ::) Stream))
   (block
    (group
     if
     stream
     (op |.|)
     is_empty
     (parens)
     (alts
      (block
       (group
        Parsed
        (parens
         (group
          Error
          (parens (group Message (parens (group stream) (group (brackets))))))
         (group #t))))
      (block
       (group def tok (op =) stream (op |.|) first)
       (group
        Parsed
        (parens
         (group
          Ok
          (parens
           (group tok)
           (group stream (op |.|) rest)
           (group Message (parens (group #f) (group (brackets))))))
         (group #f))))))))
  (group
   fun
   label
   (parens (group name (op ::) String) (group p))
   (block
    (group
     fun
     (parens (group stream (op ::) Stream))
     (block
      (group
       match
       p
       (parens (group stream))
       (alts
        (block
         (group
          Parsed
          (parens (group Error (parens (group message))) (group #t))
          (block
           (group
            Parsed
            (parens
             (group
              Error
              (parens
               (group
                message
                (op |.|)
                replace_expected
                (parens (group name)))))
             (group #t))))))
        (block
         (group
          Parsed
          (parens
           (group Ok (parens (group _) (group _) (group message)) (op &&) ok)
           (group #t))
          (block
           (group
            Parsed
            (parens
             (group
              ok
              with
              (parens
               (group
                message
                (op =)
                message
                (op |.|)
                replace_expected
                (parens (group name)))))
             (group #t))))))
        (block (group parsed (block (group parsed))))))))))
  (group
   fun
   try
   (parens (group p))
   (block
    (group
     fun
     (parens (group stream (op ::) Stream))
     (block
      (group
       match
       p
       (parens (group stream))
       (alts
        (block
         (group
          Parsed
          (parens (group Error (parens (group _)) (op &&) err) (group #f))
          (op &&)
          parsed
          (block (group parsed with (parens (group is_empty (op =) #t))))))
        (block (group parsed (block (group parsed))))))))))
  (group
   fun
   char
   (parens (group char (op ::) Char))
   (block
    (group
     label
     (parens
      (group
       "'"
       (op ++)
       to_string
       (parens (group char) (group #:mode (block (group (op |#'|) expr))))
       (op ++)
       "'")
      (group
       satisfy
       (parens
        (group
         fun
         (parens (group schar))
         (block (group char (op ==) schar)))))))))
  (group
   fun
   string
   (parens (group string (op ::) String))
   (block
    (group def size (op =) string (op |.|) length (parens))
    (group
     for
     values
     (parens (group cont_p (op =) pure (parens (group string))))
     (block
      (group each i (block (group 0 (op ..) size)))
      (group
       sequence
       (parens
        (group
         char
         (parens (group string (brackets (group size (op -) i (op -) 1)))))
        (group fun (parens (group _ignore)) (block (group cont_p)))))))))
  (group
   meta
   (block
    (group
     syntax_class
     ParseStep
     (alts
      (block
       (group
        (quotes
         (group
          (op $)
          (parens (group var (op ::) Identifier))
          (op =)
          (op $)
          parse
          (op ...)))))
      (block
       (group
        (quotes (group (op $) parse (op ...)))
        (block
         (group
          field
          var
          (block (group Syntax (op |.|) make_temp_id (parens)))))))))))
  (group
   expr
   (op |.|)
   macro
   (alts
    (block
     (group
      (quotes
       (group
        parse_sequence
        (block (group (op $) (parens (group step (op ::) ParseStep))))))
      (block (group (quotes (group (op $) step (op |.|) parse (op ...)))))))
    (block
     (group
      (quotes
       (group
        parse_sequence
        (block
         (group (op $) (parens (group step0 (op ::) ParseStep)))
         (group (op $) steps)
         (group (op ...)))))
      (block
       (group
        (quotes
         (group
          sequence
          (parens
           (group (op $) step0 (op |.|) parse (op ...))
           (group
            fun
            (parens (group (op $) step0 (op |.|) var))
            (block
             (group
              parse_sequence
              (block (group (op $) steps) (group (op ...)))))))))))))))
  (group
   fun
   many1
   (parens (group p))
   (block
    (group
     def
     rec
     (block
      (group
       parse_sequence
       (block
        (group v (op =) p)
        (group
         vs
         (op =)
         choice
         (parens (group rec) (group pure (parens (group (brackets))))))
        (group
         pure
         (parens (group List (op |.|) cons (parens (group v) (group vs)))))))))
    (group rec)))
  (group
   def
   digit
   (block
    (group
     label
     (parens
      (group "<digit>")
      (group satisfy (parens (group Char (op |.|) is_numeric)))))))
  (group
   fun
   chars_to_number
   (parens (group sign) (group chars))
   (block
    (group
     def
     do_sign
     (block
      (group
       if
       sign
       (alts
        (block (group values))
        (block (group fun (parens (group x)) (block (group x (op *) -1))))))))
    (group
     do_sign
     (parens
      (group
       String
       (op |.|)
       to_int
       (parens (group base (op |.|) list->string (parens (group chars)))))))))
  (group
   def
   integer
   (block
    (group
     parse_sequence
     (block
      (group
       sign
       (op =)
       choice
       (parens
        (group
         parse_sequence
         (block
          (group try (parens (group char (parens (group #\-)))))
          (group pure (parens (group #f)))))
        (group pure (parens (group #t)))))
      (group ds (op =) many1 (parens (group digit)))
      (group
       pure
       (parens (group chars_to_number (parens (group sign) (group ds)))))))))
  (group
   def
   spaces
   (block
    (group
     label
     (parens
      (group "<whitespace>")
      (group
       many1
       (parens
        (group satisfy (parens (group Char (op |.|) is_whitespace)))))))))
  (group
   fun
   parse
   (parens (group p) (group s))
   (block
    (group
     match
     p
     (parens (group s))
     (alts
      (block
       (group
        Parsed
        (parens (group Ok (parens (group v) (group s) (group _))) (group _))
        (block (group values (parens (group v) (group s))))))
      (block
       (group
        Parsed
        (parens (group Error (parens (group message))) (group _))
        (block
         (group
          throw
          Exn
          (op |.|)
          Fail
          (parens
           (group message (op |.|) to_string (parens))
           (group Continuation (op |.|) current_marks (parens)))))))))))
  (group
   fun
   parse_string
   (parens (group p) (group s (op ::) String))
   (block
    (group
     parse
     (parens (group p) (group string_to_list (parens (group s)))))))
  (group
   check
   (block
    (group
     def
     values
     (parens (group results) (group stream))
     (op =)
     parse
     (parens (group pure (parens (group 42))) (group (brackets))))
    (group (brackets (group results) (group stream)))
    (group #:is (brackets (group 42) (group (brackets))))))
  (group
   check
   (block
    (group
     def
     values
     (parens (group results) (group stream))
     (op =)
     parse
     (parens
      (group pure (parens (group 42)))
      (group (brackets (group "abc")))))
    (group (brackets (group results) (group stream)))
    (group #:is (brackets (group 42) (group (brackets (group "abc")))))))
  (group
   check
   (block
    (group
     fun
     (alts
      (block (group x (parens (group y (op ::) Int)) (block (group #t))))
      (block (group x (parens (group y)) (block (group #f))))))
    (group
     def
     values
     (parens (group results) (group stream))
     (op =)
     parse
     (parens
      (group satisfy (parens (group x)))
      (group (brackets (group 123)))))
    (group (brackets (group results) (group stream)))
    (group #:is (brackets (group 123) (group (brackets))))))
  (group
   check
   (block
    (group
     fun
     (alts
      (block (group x (parens (group y (op ::) Int)) (block (group #t))))
      (block (group x (parens (group y)) (block (group #f))))))
    (group
     parse
     (parens
      (group satisfy (parens (group x)))
      (group (brackets (group "asdasd")))))
    (group #:raises "asdasd")))
  (group
   check
   (block
    (group
     def
     p
     (block (group parse_sequence (block (group pure (parens (group 42)))))))
    (group
     def
     values
     (parens (group results) (group stream))
     (op =)
     parse
     (parens (group p) (group (brackets))))
    (group (brackets (group results) (group stream)))
    (group #:is (brackets (group 42) (group (brackets))))))
  (group
   check
   (block
    (group
     def
     values
     (parens (group results) (group stream))
     (op =)
     parse
     (parens
      (group string (parens (group "red")))
      (group string_to_list (parens (group "red")))))
    (group (brackets (group results) (group stream)))
    (group #:is (brackets (group "red") (group (brackets))))))
  (group
   check
   (block
    (group
     parse
     (parens
      (group string (parens (group "red")))
      (group (brackets (group #\r) (group #\e)))))
    (group #:raises "got <empty> expected '#{#\\d}'"))))
