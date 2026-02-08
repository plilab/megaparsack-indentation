'(multi
  (group
   import
   (block
    (group
     lib
     (parens (group "net/http-client.rkt"))
     as
     http_client
     (block (group rename (block (group http-sendrecv as sendrecv)))))
    (group
     rhombus
     (op /)
     runtime_path
     open
     (block (group rename (block (group def as def_runtime_path)))))
    (group
     lib
     (parens (group "racket/main.rkt"))
     as
     racket
     (block
      (group
       rename
       (block
        (group with-input-from-file as with_input_from_file)
        (group with-output-to-file as with_output_to_file)
        (group file-exists? as exists_file)))))
    (group
     lib
     (parens (group "racket/string.rkt"))
     as
     String
     (block
      (group rename (block (group string-prefix? as is_string_prefix)))))))
  (group
   export
   (block (group retrieve_input_for_day) (group submit_result_for_day)))
  (group def_runtime_path cookie_path (block (group "../cookie")))
  (group def_runtime_path inputs_dir (block (group "../inputs")))
  (group
   def
   cookie
   (block
    (group
     racket
     (op |.|)
     with_input_from_file
     (parens (group cookie_path) (group racket (op |.|) read-line)))))
  (group
   fun
   download_input_for_day
   (parens (group day (op ::) Int))
   (block
    (group println (parens (group "making request")))
    (group
     def
     uri
     (block
      (group
       racket
       (op |.|)
       format
       (parens (group "/2023/day/~a/input") (group day)))))
    (group
     def
     values
     (parens (group resp) (group resp_headers) (group inp))
     (block
      (group
       http_client
       (op |.|)
       sendrecv
       (parens
        (group "adventofcode.com")
        (group uri)
        (group
         #:headers
         (block
          (group
           (brackets
            (group "Accept: text/html")
            (group
             racket
             (op |.|)
             format
             (parens (group "Cookie: session=~a") (group cookie)))))))
        (group #:ssl? (block (group #t)))))))
    (group racket (op |.|) port->string (parens (group inp)))))
  (group
   fun
   path_to_input_file_for_day
   (parens (group day (op ::) Int))
   (block
    (group
     racket
     (op |.|)
     build-path
     (parens
      (group inputs_dir)
      (group racket (op |.|) format (parens (group "~a") (group day)))))))
  (group
   fun
   retrieve_input_for_day
   (parens (group day (op ::) Int))
   (block
    (group
     def
     input_file_path
     (block (group path_to_input_file_for_day (parens (group day)))))
    (group
     if
     (op !)
     racket
     (op |.|)
     exists_file
     (parens (group input_file_path))
     (alts
      (block
       (group
        def
        input_for_day
        (block (group download_input_for_day (parens (group day)))))
       (group
        racket
        (op |.|)
        with_output_to_file
        (parens
         (group input_file_path)
         (group
          fun
          (parens)
          (block (group print (parens (group input_for_day)))))))
       (group input_for_day))
      (block
       (group
        racket
        (op |.|)
        with_input_from_file
        (parens
         (group input_file_path)
         (group racket (op |.|) port->string))))))))
  (group
   fun
   submit_result_for_day
   (parens
    (group day (op ::) Int)
    (group result)
    (group #:level (block (group level (op ::) Int (op =) 1))))
   (block
    (group
     def
     values
     (parens (group resp) (group resp_output) (group outp))
     (block
      (group
       http_client
       (op |.|)
       sendrecv
       (parens
        (group "adventofcode.com")
        (group
         racket
         (op |.|)
         format
         (parens (group "/2023/day/~a/answer") (group day)))
        (group #:method (block (group "POST")))
        (group
         #:headers
         (block
          (group
           (brackets
            (group "Accept: text/html")
            (group "Content-Type: application/x-www-form-urlencoded")
            (group
             racket
             (op |.|)
             format
             (parens (group "Cookie: session=~a") (group cookie)))))))
        (group #:ssl? (block (group #t)))
        (group
         #:data
         (block
          (group
           racket
           (op |.|)
           format
           (parens
            (group "level=~a&answer=~a")
            (group level)
            (group result)))))))))
    (group
     def
     response
     (block (group racket (op |.|) port->string (parens (group outp)))))
    (group
     racket
     (op |.|)
     string-contains?
     (parens (group response) (group "day-success"))))))
