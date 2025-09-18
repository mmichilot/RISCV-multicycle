BUILD_DIR    = ./build
RISCOF_DIR   = ./riscof

.PHONY: default
default: riscof

.PHONY: sim_binary
sim_binary:
	@echo "\n\
	------------------------------------------------------\n\
	----- Building simulation binary using FuseSoC -----\n\
	------------------------------------------------------\n"

	fusesoc --cores-root . run --target build --work-root $(BUILD_DIR) multicycle

.PHONY: riscof
riscof: sim_binary
	@echo "\n\
	--------------------------------\n\
	----- Testing using RISCOF -----\n\
	--------------------------------\n"

	make -C $(RISCOF_DIR)

.PHONY: clean
clean:
	@rm -r $(BUILD_DIR)
	@make -C $(RISCOF_DIR) clean