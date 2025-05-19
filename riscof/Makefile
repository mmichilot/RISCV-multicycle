# Directory tests are cloned to
RISCOF_ARCH_TEST = ./riscv-arch-test

# Directory containing tests
RISCOF_FLAGS += --suite=$(RISCOF_ARCH_TEST)/riscv-test-suite/

# Directory containing necessary header files
RISCOF_FLAGS += --env=$(RISCOF_ARCH_TEST)/riscv-test-suite/env

# Disable launching browser on test complete
RISCOF_FLAGS += --no-browser

run: | $(RISCOF_ARCH_TEST)
	riscof run $(RISCOF_FLAGS)

$(RISCOF_ARCH_TEST):
	riscof --verbose info arch-test --clone 

.PHONY: clean
clean:
	-rm -rf riscof_work
