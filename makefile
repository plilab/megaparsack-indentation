RACO=raco
RACT=racket
TESTFILE=./test/main.rkt
RANPRINT=./test/sexp-generator/utils/gen_helper.rkt
RANGEN=./test/sexp-generator/sexp_generator.rkt
RANTEST=./test/rand_sexp_test.rkt
PEXP=./test/utils/sexp_string.rkt

.PHONY: test random_print random_gen print_sexp help quickcheck

help:
	@echo "Available make targets:"
	@echo "  test           - Run the test harness on $(TESTFILES)"
	@echo "  random_print   - Print a randomly generated program"
	@echo "  random_gen     - Generate S-expressions and save the default pretty-print shrubbery notation"
	@echo "  quickcheck     - Run the Quickcheck test"
	@echo "  print_sexp     - Print S-expression of the corpus (specify corpus in $(PEXP))"
	@echo "  help           - Show this help message"

# Command to test harness
test:
	$(RACO) test $(TESTFILE)

# Command to compare behavior of parsers on randomly generated code
quickcheck:
	$(RACO) test $(RANTEST)

# Command to print randomly generated quickcheck program
random_print:
	$(RACT) $(RANPRINT)

# Command to generate sexp and save the default pretty print shrubbery notation
random_gen:
	$(RACT) $(RANGEN)

# Print sexp of the corpus, need to specify the corpus in the designated position of $PEXP
print_sexp:
	$(RACT) $(PEXP)

