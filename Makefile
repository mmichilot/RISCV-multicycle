SIM_DIR    = ./sim
RISCOF_DIR = ./riscof
FPGA_DIR   = ./fpga

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

ifdef SKIP_TEST
.PHONY: fpga
fpga: 
	@echo "\n\
	------------------------------------\n\
	----- Building design for FPGA -----\n\
	-------------------------------------\n"

	make -C $(FPGA_DIR) all
else
.PHONY: fpga
fpga: riscof
	@echo "\n\
	------------------------------------\n\
	----- Building design for FPGA -----\n\
	-------------------------------------\n"

	make -C $(FPGA_DIR) all
endif

.PHONY: clean
clean:
	@make -C $(SIM_DIR) clean
	@make -C $(RISCOF_DIR) clean
	@make -C $(FPGA_DIR) clean