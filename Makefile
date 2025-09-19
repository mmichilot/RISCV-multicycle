SIM_BUILD    = ./sim-build
RISCOF_BUILD = ./riscof-build

.PHONY: default
default: riscof

.PHONY: sim_binary
sim_binary:
	@echo "\n\
	------------------------------------------------------\n\
	----- Building simulation binary using FuseSoC -----\n\
	------------------------------------------------------\n"

	fusesoc --cores-root . run --target build --work-root $(SIM_BUILD) multicycle

.PHONY: riscof
riscof: sim_binary
	@echo "\n\
	--------------------------------\n\
	----- Testing using RISCOF -----\n\
	--------------------------------\n"
	if [ ! -d "./riscv-arch-test" ]; then riscof arch-test --clone; fi
	riscof run --suite=./riscv-arch-test/riscv-test-suite --env=./riscv-arch-test/riscv-test-suite/env \
	--work-dir=$(RISCOF_BUILD) --no-browser

.PHONY: clean
clean:
	@rm -rf $(SIM_BUILD) $(RISCOF_BUILD)

.PHONY: clean-all
clean-all: clean
	@rm -rf ./riscv-arch-test