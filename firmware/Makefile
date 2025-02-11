TARGET_BIN = firmware

BUILD_DIR := ./build
SRC_DIR := ./

SRCS := $(wildcard $(SRC_DIR)/*.S)
OBJS := $(patsubst $(SRC_DIR)/%.S,$(BUILD_DIR)/%.o,$(SRCS))

INC_DIR := ./includes
INC_FLAGS := $(addprefix -I,$(INC_DIR))

# Tools
RISCV_PREFIX := riscv64-unknown-elf-
CC := $(RISCV_PREFIX)gcc
LD := $(RISCV_PREFIX)ld
OBJCOPY := $(RISCV_PREFIX)objcopy
OBJDUMP := $(RISCV_PREFIX)objdump
NM := $(RISCV_PREFIX)nm

TARGET_ARCH := -march=rv32i_zicsr -mabi=ilp32 -mcmodel=medany
CCFLAGS := $(INC_FLAGS) -O0 $(TARGET_ARCH) -g -static -fvisibility=hidden
LDFLAGS := -T./link.ld $(TARGET_ARCH) -nostdlib -nostartfiles -mno-relax

# Lists of rules: the name of a file, followed by the files it depends on.
# When typing 'make' not followed by a rule name, the first rule is followed.  This rule depends on
# everything, causing all the parts to be built

all: dump memory symbols

.PHONY: build
build: $(BUILD_DIR)/$(TARGET_BIN).elf

$(BUILD_DIR)/$(TARGET_BIN).elf: $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.o: $(SRCS)
	mkdir -p $(BUILD_DIR)
	$(CC) $(CCFLAGS) -c $< -o $@

# dump binary
.PHONY: dump
dump: $(BUILD_DIR)/$(TARGET_BIN).dump

$(BUILD_DIR)/$(TARGET_BIN).dump: $(BUILD_DIR)/$(TARGET_BIN).elf
	$(OBJDUMP) -S -s $< > $@

# create ASCII hex file for OTTER memory
.PHONY: memory
memory: $(BUILD_DIR)/$(TARGET_BIN).hex

$(BUILD_DIR)/$(TARGET_BIN).bin: $(BUILD_DIR)/$(TARGET_BIN).elf
	$(OBJCOPY) -O binary --only-section=.text $< $@

$(BUILD_DIR)/$(TARGET_BIN).hex: $(BUILD_DIR)/$(TARGET_BIN).bin
	hexdump -v -e '1/4 "%08x\n"' $< > $@

.PHONY: symbols
symbols: $(BUILD_DIR)/$(TARGET_BIN).symbols

$(BUILD_DIR)/$(TARGET_BIN).symbols: $(BUILD_DIR)/$(TARGET_BIN).elf
	$(NM) -g -B -n $< > $@

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)