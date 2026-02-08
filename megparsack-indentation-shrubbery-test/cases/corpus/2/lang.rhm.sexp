'(multi
  (group
   import
   (block
    (group
     lib
     (parens (group "racket/string.rkt"))
     as
     string
     (block (group rename (block (group string-join as concat)))))))
  (group export (block (group unless) (group while) (group multiline)))
  (group
   expr
   (op |.|)
   macro
   (quotes
    (group
     unless
     (op $)
     expr
     (op ...)
     (alts (block (group (op $) body) (group (op ...))))))
   (block
    (group
     (quotes
      (group
       if
       (op $)
       expr
       (op ...)
       (alts
        (block (group #<void>))
        (block (group (op $) body) (group (op ...)))))))))
  (group
   expr
   (op |.|)
   macro
   (quotes
    (group
     while
     (op $)
     expr
     (op ...)
     (block (group (op $) body) (group (op ...)))))
   (block
    (group
     (quotes
      (group
       block
       (block
        (group
         fun
         loop
         (parens)
         (block
          (group
           when
           (op $)
           expr
           (op ...)
           (alts
            (block
             (group (op $) body)
             (group (op ...))
             (group loop (parens)))))))
        (group loop (parens))))))))
  (group
   expr
   (op |.|)
   macro
   (quotes (group multiline (block (group (op $) line) (group (op ...)))))
   (block
    (group
     (quotes
      (group
       (parens
        (group
         string
         (op |.|)
         concat
         (parens
          (group (brackets (group (op $) line) (group (op ...))))
          (group "\n"))
         (op :~)
         ReadableString))
       (op |.|)
       to_string
       (parens)))))))
