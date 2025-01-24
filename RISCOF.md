# Notes regarding implementing RISCOF
- Primarily adapted from ([VeeR](https://github.com/chipsalliance/Cores-VeeR-EL2/tree/main))
  - Added Memory "Mailbox" which monitors when a specific address (.tohost) is written to
    - Allows the core to specify when execution has completed
  - Added ability to pass symbols to simulation binary
    - Extracts 3 symbols from program binary
      1. begin_signature
      2. end_signature
      3. tohost
  - Added ability to specify hex file to load into SRAM
  - Added cycle timeout
  - Added dump_signature() task which dumps the memory region specified by begin_signature and end_signature
  - In general the process goes as follows:
    - Build simulation binary
    - Build software
      - Compile
      - Convert binary to hex
      - Extract symbols
    - Launch simulation
    - Wait for execution to finish (two outcomes)
      - Core writes to mailbox the value 0xFF signifying end of program -> Simulation passes
      - Max cycle count is reached -> Simulation failed

- Adapted testbench from ZipCPU's [TESTB](https://github.com/ZipCPU/zbasic/blob/master/sim/verilated/testb.h)
- Had to increase size of SRAM from 2^15 bytes to 2^25 bytes

# Failing Test List (All Fixed!)
- [x] fence-01.S
 - FENCE has a special opcode (MISC-MEM) so added it as a NOP
- [x] sb-align-01.S
- [x] sh-align-01.S
 - When storing, only the lower half/lower byte of the value is stored, rather than the storing byte for byte/half for half the entire value
 - e.g. for a value of 0x0403_0201 and an the given address of 0x0000_0011, SB will store 0x01, NOT 0x03
 - likewise for an address of 0x0000_0010, SH will store 0x0201, NOT 0x0403
 - fix was to shift the input write data so that the lower byte/half will be written in the corresponding byte/half given by the address
- [x] slt-01.S
- [x] slti-01.S
- [x] sltiu-01.S
- [x] sltu-01.S
 - the output for SLT and SLTU was '0 and '1, which would be expanded into 0x0000_0000 and 0xFFFF_FFFF respectively
 - correct output for when A < B should be 0x0000_00001, rather than 0xFFFF_FFFF
 - fix was to use 32'd1 and 32'd0 to explicitly specify 0x0000_0000 and 0x0000_00001 respectively
- [x] srai-01.S
 - for OP_IMM instructions, it was wrongly assumed that since the immediate is stored in func7 the op should always be computed as {1'b0, func3}
 - the one edge case is for SRA and SRAI, where func7 is used to distinguish between them since the immediate is only 5 bits
 - fix was to use {func7[5], func3} when func3 is either SRA or SRAI, otherwise the ALU op is {1'b0, func3} so that the immediate doesn't affect the
   resulting ALU op

# Privilege Spec Updates
All tests passing!
Created additional modules:
- clint.sv
  - Main interface for interupts and exceptions
  - Contains MIE and MIP CSRs, although this is going to be merged with the csr module
  - Planned to house the memory-mapped timer and software interrupt registers
- csr.sv
  - Contains the minimal CSRs necessary for the privilege spec.

Modified the following modules:
- control_unit.sv
  - Added a new state, TRAP, which will setup the core prior before entering a trap
    - MEPC <- PC
    - PC <- MTVEC
    - disable global interrupts (MSTATUS)
    - save exception code (MCAUSE)
    - save cause of exception (MTVAL)
- prog_cntr.sv
  - Have PC start at address 0x8000_0000
- decoder.sv
  - When trap is started, set PC source to MTVEC
  - When trap is finished, set PC source to MEPC
  - Added separate PC source selection for JALR called LSB_ZERO
    - As per spec, for a JALR instruction, the last bit is set to zero (2.5.1)