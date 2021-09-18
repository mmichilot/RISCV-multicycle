# Makefile based off of Verilator examples

VERILATOR = verilator

# Enable SystemVerilog parsing
VERILATOR_FLAGS += -sv

# Generate makefile dependencies
VERILATOR_FLAGS += -MMD

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe

# Optimize
VERILATOR_FLAGS += -Os -x-assign 0

# Warn about lint issues
VERILATOR_FLAGS += -Wall

# Make waveforms
VERILATOR_FLAGS += --trace

VERILATOR_INPUT = -f input.vc top.sv testbench.cpp

# Directories
SW_DIR = ../sw
INCLUDE_DIRS = ../bus ../core ../memory
INCLUDE_FLAGS = $(addprefix -I,$(INCLUDE_DIRS))

default: run

run:
	@echo
	@echo "-- CPU Testbench and Simulation --"

	@echo
	@echo "-- Compiling software --"
	$(MAKE) -j -C $(SW_DIR)

	@echo
	@echo "-- Copying memory file --"
	cp $(SW_DIR)/build/mem.txt .

	@echo
	@echo "-- Verilating --"
	$(VERILATOR) $(INCLUDE_FLAGS) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

	@echo
	@echo "-- Building --"
	$(MAKE) -j -C obj_dir -f Vtop.mk

	@echo
	@echo "-- Running --"
	@rm -rf logs
	@mkdir -p logs
	obj_dir/Vtop +trace

ifeq ($(SIM),yes)
	@echo
	@echo "-- Opening Waveforms --"
	gtkwave logs/vlt_dump.vcd
endif

clean:
	-rm -rf obj_dir logs *.log *.dmp *.vpd core
	