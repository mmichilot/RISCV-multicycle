`timescale 1ns / 1ps
`include "defs.svh"

module core(
        input clk,
        input rst_n,
        
        // Instruction Memory Interface
        output logic inst_read,
        output logic [31:0] inst_addr,
        input [31:0] inst_data,

        // Data Memory Interface
        output logic data_read,
        output logic data_write,
        output logic data_sign,
        output logic [1:0]  data_size,
        output logic [31:0] data_addr,
        output logic [31:0] data_write_data,
        input [31:0] data_read_data,

        // Interrupt Interface
        input [31:0] interrupts
    );
    
    // Convenient wires
    logic [31:0] inst;
    assign inst = inst_data;

    logic [4:0] rs1, rs2, rd;
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd  = inst[11:7];

    logic [6:0] opcode;
    assign opcode = inst[6:0];

    logic [2:0] func3;
    assign func3 = inst[14:12];

    logic [6:0] func7;
    assign func7 = inst[31:25];
    
    // Control unit
    logic pc_write, reg_write, csr_write;
    logic illegal_inst, inst_addr_misalign, load_addr_misalign, store_addr_misalign, env_call, env_break;
    logic trap_start, trap_finish;
    control_unit control_unit (
    	.clk,
        .rst_n,
        .inst,

        .take_branch,
        
        // Trap Handling
        .trap_pending,
        .trap_start,
        .trap_finish,
        .trap_cause,

        .inst_addr(alu_out),
        .data_addr,
        .data_size,
        .data_addr_misalign,
        
        // Exceptions (to CLINT)
        .illegal_inst,
        .inst_addr_misalign,
        .load_addr_misalign,
        .store_addr_misalign,
        .env_call,
        .env_break,

        .pc_write,
        .inst_read,
        .data_read,
        .data_write,
        .reg_write,
        .csr_write
    );

    // Decoder
    logic alu_b_src;
    logic [1:0] alu_a_src, reg_src;
    logic [2:0] pc_src, immed_type;
    logic [3:0] alu_op;
    decoder decoder (
    	.opcode,
        .func3,
        .func7,

        .take_branch,
        .trap_start,
        .trap_finish,
        
        .immed_type,
        .alu_a_src,
        .alu_b_src,
        .alu_op,
        .reg_src,
        .pc_src
    );

    // Program Counter Source MUX
    logic [31:0] pc_data;
    always_comb begin
        unique case(pc_src)
            PC_PLUS_4: pc_data = next_pc;
            ALU_OUT:   pc_data = alu_out;
            LSB_ZERO:  pc_data = { alu_out[31:1], 1'b0 };
            CSR_MTVEC: pc_data = trap_vector;
            CSR_MEPC:  pc_data = interrupted_pc;
            default:   pc_data = next_pc;
        endcase
    end

    // Program Counter
    logic [31:0] pc_out;
    prog_cntr prog_cntr (
        .clk,
        .rst_n,
        .ld(pc_write),
        .data(pc_data),
        .count(pc_out)
    );

    logic [31:0] next_pc;
    assign next_pc = pc_out + 4;

    // Branch Generator
    logic take_branch;
    branch_gen branch_gen (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .func3,
        .take_branch
    );

    // Immediate Generator
    logic [31:0] immed;
    immed_gen immed_gen (
        .inst,
        .immed_type,
        .immed
    );

    // Register File Data MUX
    logic [31:0] reg_data;
    always_comb begin
        unique case(reg_src)
            NEXT_PC: reg_data = next_pc;
            ALU:     reg_data = alu_out;
            MEM:     reg_data = data_read_data;
            CSR:     reg_data = csr_rd_data;
        endcase
    end

    // Register File
    logic [31:0] rs1_data, rs2_data;
    reg_file reg_file (
        .clk,
        .wr(reg_write),
        .rs1,
        .rs2,
        .rd,
        .rd_data(reg_data),
        .rs1_data,
        .rs2_data
    );

    // ALU A Source MUX
    logic [31:0] alu_a_data;
    always_comb begin
        unique case(alu_a_src)
            RS1:     alu_a_data = rs1_data;
            CURR_PC: alu_a_data = pc_out;
            ZERO:    alu_a_data = '0;
            default: alu_a_data = '0;
        endcase
    end

    // ALU B Source MUX
    logic [31:0] alu_b_data;
    always_comb begin
        unique case(alu_b_src)
            RS2: alu_b_data = rs2_data;
            IMMED: alu_b_data = immed;
        endcase
    end

    // ALU
    logic [31:0] alu_out;
    alu alu (
        .op(alu_op),
        .a(alu_a_data),
        .b(alu_b_data),
        .out(alu_out)
    );

    /*
     * CONTROL & STATUS REGISTERS
     */

    // Interface
    logic [1:0] csr_op;
    logic [11:0] csr_addr;
    logic [31:0] csr_rd_data, csr_wr_data;
    assign csr_wr_data = func3[2] ? immed : rs1_data;
    assign csr_addr = inst[31:20];
    assign csr_op = func3[1:0];

    // CSR Registers
    logic csr_reg_write;
    logic [31:0] csr_reg_out;
    logic interrupts_enabled;
    logic [31:0] trap_vector, interrupted_pc;
    csr csr (
        .clk,
        .rst_n,
        
        .csr_write(csr_reg_write),
        .csr_op,
        .csr_addr,
        .csr_wr_data,
        .csr_rd_data(csr_reg_out),

        .pc(pc_out),
        .instruction(inst),
        .misaligned_addr(alu_out),

        .trap_start,
        .trap_finish,
        .trap_cause,
        .trap_vector,
        .interrupted_pc,

        .interrupts_enabled

    );

    // CLINT
    logic clint_write;
    logic [31:0] clint_out;
    logic trap_pending;
    logic [31:0] trap_cause;
    clint clint (
        .clk,
        .rst_n,

        .csr_write(clint_write),
        .csr_op,
        .csr_addr,
        .csr_wr_data,
        .csr_rd_data(clint_out),

        .interrupts_enabled,
        .interrupts,

        .illegal_inst,
        .inst_addr_misalign,
        .load_addr_misalign,
        .store_addr_misalign,
        .env_call,
        .env_break,

        .trap_pending,
        .trap_cause
    );

    // CSR Bus MUX
    always_comb begin
        unique case(csr_addr)
            MIP, MIE: begin
                clint_write = csr_write;
                csr_rd_data = clint_out;
            end
            default: begin
                csr_reg_write = csr_write;
                csr_rd_data   = csr_reg_out;
            end
        endcase
    end

    /*
     * MEMORY INTERFACE
     */

    // Instruction interface
    assign inst_addr = pc_out;

    // Data Interface
    assign data_sign = inst[14];
    assign data_size = inst[13:12];
    assign data_addr = alu_out;
    assign data_write_data = rs2_data;

    // Misaligned Data Address
    logic data_addr_misalign;
    assign data_addr_misalign = (data_size == WORD && |data_addr[1:0]) || (data_size == HALF && data_addr[0]);
    
endmodule
