`ifndef DEFS
`define DEFS

typedef enum logic [6:0] {
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

typedef enum logic [2:0] {I_IMMED, S_IMMED, B_IMMED, U_IMMED, J_IMMED} immed_type_e;

typedef enum logic [1:0] {RS1, CURR_PC, ZERO} alu_a_src_e;
typedef enum logic {RS2, IMMED} alu_b_src_e;
typedef enum logic [1:0] {NEXT_PC, ALU, MEM, CSR} reg_src_e;
typedef enum logic [2:0] {PC_PLUS_4, ALU_OUT, LSB_ZERO, CSR_MTVEC, CSR_MEPC} pc_src_e;
typedef enum logic {CSR_RS1, CSR_IMMED} csr_src_e;

typedef enum logic {
    SIGNED = 1'b0,
    UNSIGNED = 1'b1
} sign_e;

typedef enum logic [1:0] {
    BYTE = 2'b00,
    HALF = 2'b01,
    WORD = 2'b10
} size_e;

typedef enum logic [3:0] {
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

typedef enum logic [11:0] { 
    ECALL  = 12'b000000000000,
    EBREAK = 12'b000000000001,
    MRET   = 12'b001100000010
} func12_e;

typedef enum logic [1:0] {
    NOP   = 2'b00,
    WRITE = 2'b01,
    SET   = 2'b10, 
    CLEAR = 2'b11
} csr_op_e;

typedef enum logic [11:0] {
    // Machine Information Registers
    MVENDORID = 12'hF11,
    MARCHID   = 12'hF12,
    MIMPID    = 12'hF13,
    MHARTID   = 12'hF14,
    
    // Machine Trap Setup
    MSTATUS   = 12'h300,
    MISA      = 12'h301,
    MIE       = 12'h304,
    MTVEC     = 12'h305,
    MSTATUSH  = 12'h310,

    // Machine Trap Handling
    MSCRATCH  = 12'h340,
    MEPC      = 12'h341,
    MCAUSE    = 12'h342,
    MTVAL     = 12'h343,
    MIP       = 12'h344
} csr_e;

typedef enum logic [4:0] {
    SOFTWARE_INT = 5'd3,
    TIMER_INT    = 5'd7,
    EXTERNAL_INT = 5'd11
} interrupt_codes_e;

typedef enum logic [4:0] {
    INST_ADDR_MISALIGN  = 5'd0,
    ILLEGAL_INST        = 5'd2,
    ENV_BREAK           = 5'd3,
    LOAD_ADDR_MISALIGN  = 5'd4,
    STORE_ADDR_MISALIGN = 5'd6,
    ENV_CALL            = 5'd11,
    HARDWARE_ERROR      = 5'd19
} exception_codes_e;

typedef enum logic [1:0] {
    INST_READ,
    DATA_READ,
    DATA_WRITE
} mem_op_e;

`endif
