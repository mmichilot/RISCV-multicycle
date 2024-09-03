`ifndef DEFS
`define DEFS

// verilator lint_off UNUSED
enum logic [6:0] {
    LUI      = 7'b0110111,
    AUIPC    = 7'b0010111,
    JAL      = 7'b1101111,
    JALR     = 7'b1100111,
    BRANCH   = 7'b1100011,
    LOAD     = 7'b0000011,
    STORE    = 7'b0100011,
    OP_IMM   = 7'b0010011,
    OP       = 7'b0110011,
    SYSTEM   = 7'b1110011,
    FENCE    = 7'b0001111
} opcode_e;

enum logic [2:0] {I_IMMED, S_IMMED, B_IMMED, U_IMMED, J_IMMED} immed_type_e;

enum logic [1:0] {RS1, CURR_PC, ZERO} alu_a_src_e;
enum logic {RS2, IMMED} alu_b_src_e;
enum logic [1:0] {NEXT_PC, ALU, MEM, CSR} reg_src_e;
enum logic {PC_PLUS_4, ALU_OUT} pc_src_e;
enum logic {CSR_RS1, CSR_IMMED} csr_src_e;

enum logic [3:0] {
    ADD  = 4'b0000,
    SLL  = 4'b0001,
    SLT  = 4'b0010,
    SLTU = 4'b0011,
    XOR  = 4'b0100,
    SRL  = 4'b0101,
    OR   = 4'b0110,
    AND  = 4'b0111,
    SUB  = 4'b1000,
    SRA  = 4'b1101
} alu_op_e;
// verilator lint_on UNUSED

`endif
