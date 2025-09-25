'(multi
  (group
   import
   (block
    (group
     lib
     (parens (group "racket/base.rkt"))
     (block
      (group
       rename
       (block (group in-lines as in_lines) (group in-string as in_string)))))
    (group lib (parens (group "racket/port.rkt")))
    (group
     lib
     (parens (group "racket/sequence.rkt"))
     (block (group rename (block (group sequence-map as map)))))))
  (group
   export
   (block
    (group call_with_input_string)
    (group example_input)
    (group fmt)
    (group in_lines)
    (group in_string)
    (group list_to_string)
    (group string_index)))
  (group
   expr
   (op |.|)
   macro
   (quotes (group call_with_input_string (op $) s (block (group (op $) body))))
   (block
    (group
     (quotes
      (group
       port
       (op |.|)
       call-with-input-string
       (parens (group (op $) s) (group (op $) body)))))))
  (group
   defn
   (op |.|)
   macro
   (quotes
    (group
     example_input
     (parens
      (group (op $) (parens (group name (op ::) Identifier)))
      (group (brackets (group (op $) s) (group (op ...)))))))
   (block
    (group
     (quotes
      (group
       def
       (op $)
       name
       (block
        (group
         String
         (op |.|)
         append
         (parens (group (op $) s) (group (op ...))))))))))
  (group
   fun
   fmt
   (parens (group vs (op ::) List))
   (block
    (group
     def
     ss
     (block
      (group
       for
       List
       (block
        (group each v (block (group vs)))
        (group to_string (parens (group v)))))))
    (group String (op |.|) append (parens (group (op &) ss)))))
  (group
   fun
   in_lines
   (parens (group inp (op ::) Port (op |.|) Input))
   (op :~)
   Sequence
   (block
    (group
     sequence
     (op |.|)
     map
     (parens
      (group
       fun
       (parens (group s (op :~) ReadableString))
       (block (group s (op |.|) to_string (parens))))
      (group base (op |.|) in_lines (parens (group inp)))))))
  (group
   fun
   in_string
   (parens (group s (op ::) String))
   (op :~)
   Sequence
   (block (group base (op |.|) in_string (parens (group s)))))
  (group
   fun
   list_to_string
   (parens (group cs (op ::) List (op |.|) of (parens (group Char))))
   (block
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
     (parens))))
  (group
   fun
   string_index
   (parens (group string (op ::) String) (group char (op ::) Char))
   (op ::)
   NonnegInt
   (op \|\|)
   False
   (block
    (group
     def
     i
     (block
      (group
       for
       values
       (parens (group w (op =) #f))
       (block
        (group
         each
         j
         (block (group 0 (op ..) string (op |.|) length (parens))))
        (group def s_char (op =) string (brackets (group j)))
        (group final_when s_char (op ==) char)
        (group j)))))
    (group i (op &&) string (brackets (group i)) (op ==) char (op &&) i))))
