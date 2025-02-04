PROJ=multicycle
TOP_MODULE=top

# Directories
RTL_DIR     = ../rtl
MODULE_DIRS = $(wildcard $(RTL_DIR)/*)

# Specify hardware revision of your OrangeCrab: `r0.1` or `r0.2`
VERSION:=r0.2


VERILOG_FILES += $(foreach dir,$(MODULE_DIRS),$(wildcard $(dir)/*.sv))
VERILOG_FILES += $(wildcard *.sv)

INCLUDE_DIRS = $(MODULE_DIRS)
INCLUDE_FLAGS = $(addprefix -I,$(INCLUDE_DIRS))

RM         = rm -rf
COPY       = cp -a
PATH_SEP   = /

# We don't actually need to do anything to verilog files.
# This explicitly empty recipe is merely referenced from
# the %.ys recipe below. Since it depends on those files,
# make will check them for modifications to know if it needs to rebuild.
%.sv: ;

# Build the yosys script.
# This recipe depends on the actual verilog files (defined in $(VERILOG_FILES))
# Also, this recipe will generate the whole script as an intermediate file.
# The script will call read_verilog for each file listed in $(VERILOG_FILES),
# Then, the script will execute synth_ecp5, looking for the top module named $(TOP_MODULE)
# Lastly, it will write the json output for nextpnr-ecp5 to use as input.
%.ys: $(VERILOG_FILES)
	$(file >$@)
	$(foreach V,$(VERILOG_FILES),$(file >>$@,read_verilog -sv $(INCLUDE_FLAGS) $V))
	$(file >>$@,synth_ecp5 -top $(TOP_MODULE))
	$(file >>$@,write_json "$(basename $@).json")

# Run the yosys script to synthasize the logic and netlist (in json format)
# to provide for nextpnr-ecp5.
%.json: %.ys
	yosys -s "$<"

# Run nextpnr-ecp5 to place the logic components and route the nets to pins.
%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --25k --package CSFBGA285 --lpf uart.pcf

# Generate the final bitstream from the pnr output.
%.bit: %_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

flash: $(PROJ).bit
	openFPGALoader -d /dev/ttyUSB0 -f $(PROJ).bit

clean:
	$(RM) -f $(PROJ).bit $(PROJ)_out.config $(PROJ).json

all: flash

.PHONY: clean all
