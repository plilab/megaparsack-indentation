RACO=raco
RACT=racket
TESTFILE=./megaparsack-indentation-shrubbery-test/main.rkt
RANPRINT=./megaparsack-indentation-shrubbery-test/sexp-generator/utils/gen_helper.rkt
RANGEN=./megaparsack-indentation-shrubbery-test/sexp-generator/sexp_generator.rkt
RANTEST=./megaparsack-indentation-shrubbery-test/rand_sexp_test.rkt
PEXP=./megaparsack-indentation-shrubbery-test/utils/sexp_string.rkt

.PHONY: test random_print random_gen print_sexp help quickcheck

help:
	@echo "Available make targets:"
	@echo "  test           - Run the test harness on $(TESTFILE)"
	@echo "  random_print   - Print a randomly generated program using $(RANPRINT)"
	@echo "  random_gen     - Generate S-expressions and save the default pretty-print shrubbery notation using $(RANGEN)"
	@echo "  quickcheck     - Run the Quickcheck test on $(RANTEST)"
	@echo "  print_sexp     - Print S-expression of the corpus (specify corpus in $(PEXP))"
	@echo "  help           - Show this help message"

# Command to test harness
test:
	$(RACO) test --errortrace $(TESTFILE)

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

