SIM_DIR = ./sim
RISCOF_DIR = ./riscof

.PHONY: default
default: riscof

.PHONY: sim_binary
sim_binary:
	@echo "\n\
	------------------------------------------------------\n\
	----- Building simulation binary using Verilator -----\n\
	------------------------------------------------------\n"

	make -C $(SIM_DIR)

.PHONY: riscof
riscof: sim_binary
	@echo "\n\
	--------------------------------\n\
	----- Testing using RISCOF -----\n\
	--------------------------------\n"

	make -C $(RISCOF_DIR)

.PHONY: clean
clean:
	@make -C $(SIM_DIR) clean
	@make -C $(RISCOF_DIR) clean
