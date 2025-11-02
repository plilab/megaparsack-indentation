RACO=raco
RACT=racket
TESTFILES=./test/main.rkt
RANPRINT=./test/sexp-generator/utils/gen_helper.rkt
RANGEN=./test/sexp-generator/sexp_generator.rkt
PEXP=./test/utils/sexp_string.rkt

.PHONY: test random_print random_gen print_sexp

test:
	$(RACO) test $(TESTFILES)

random_print:
	$(RACT) $(RANPRINT)

random_gen:
	$(RACT) $(RANGEN)

print_sexp:
	$(RACT) $(PEXP)