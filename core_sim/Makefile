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

VERILATOR_INPUT = -f input.vc tb_top.sv testbench.cpp

# Directories
SW_DIR = ../sw

default: build

build:
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

clean:
	-rm -rf obj_dir trace.fst* otter.signature
	