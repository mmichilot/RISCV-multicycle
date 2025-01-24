# Directory containing tests
RISCOF_FLAGS += --suite=riscv-arch-test/riscv-test-suite/

# Directory containing necessary header files
RISCOF_FLAGS += --env=riscv-arch-test/riscv-test-suite/env

# Disable launching browser on test complete
RISCOF_FLAGS += --no-browser

.PHONY: run
run: 
	riscof run $(RISCOF_FLAGS)

.PHONY: clean
clean:
	-rm -rf riscof_work
