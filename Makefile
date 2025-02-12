SIM_DIR      = ./sim
RISCOF_DIR   = ./riscof
FPGA_DIR     = ./fpga
FIRMWARE_DIR = ./firmware

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

.PHONY: firmware
firmware:
	@echo "\n\
	-----------------------------\n\
	----- Building Firmware -----\n\
	-----------------------------\n"
	make -C $(FIRMWARE_DIR)

.PHONY: fpga
fpga: riscof firmware
	@echo "\n\
	------------------------------------\n\
	----- Building design for FPGA -----\n\
	-------------------------------------\n"

	make -C $(FPGA_DIR)

.PHONY: clean
clean:
	@make -C $(SIM_DIR) clean
	@make -C $(RISCOF_DIR) clean
	@make -C $(FIRMWARE_DIR) clean
	@make -C $(FPGA_DIR) clean