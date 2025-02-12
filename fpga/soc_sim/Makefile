# Makefile based off of Verilator examples

VERILATOR = verilator

# Enable SystemVerilog parsing
VERILATOR_FLAGS += -sv

# Generate makefile dependencies
VERILATOR_FLAGS += -MMD

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe

# Optimize
VERILATOR_FLAGS += -x-assign 0

# Warn about lint issues
# VERILATOR_FLAGS += -Wall

# Make waveforms
VERILATOR_FLAGS += --trace-fst

# Have Verilator build
VERILATOR_FLAGS += --build

# Add plusargs to scan for additional file extensions
VERILATOR_FLAGS += +librescan +libext+.v+.sv+.vh+.svh

# Where to search for modules
VERILATOR_FLAGS += $(addprefix -y , ../ ../../rtl $(wildcard ../../rtl/*))

# Top level input files
VERILATOR_INPUT = tb_soc.sv testbench.cpp

default: build

.PHONY: build
build:
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

.PHONY: clean
clean:
	-rm -rf obj_dir
	-rm -rf mem.dump trace.fst
