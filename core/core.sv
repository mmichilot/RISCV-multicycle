`timescale 1ns / 1ps
`include "defs.svh"

module core(
        input clk,
        input rst_n,

        // Instruction Memory Interface
        output logic [31:0] imem_addr,
        output logic        imem_read,
        input  logic [31:0] imem_rdata,
        input  logic        imem_ready,

        // Data Memory Interface
        output logic        dmem_read,
        output logic        dmem_write,
        output logic [3:0]  dmem_byte_en,
        output logic [31:0] dmem_addr,
        output logic [31:0] dmem_wdata,
        input  logic [31:0] dmem_rdata,
        input  logic        dmem_ready,

        // Interrupt Interface
        input logic [31:0] interrupts
    );

    // Convenient wires
    logic [31:0] inst;
    assign inst = imem_rdata;

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

        .imem_addr(alu_out),
        .dmem_addr,
        .dmem_size,
        .dmem_addr_misalign,

        // Exceptions
        .illegal_inst,
        .inst_addr_misalign,
        .load_addr_misalign,
        .store_addr_misalign,
        .env_call,
        .env_break,

        .pc_write,
        .inst_read(imem_read),
        .data_read(dmem_read),
        .data_write(dmem_write),
        .reg_write,
        .csr_write,

        .imem_ready,
        .dmem_ready
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
            CSR_MEPC:  pc_data = trap_return;
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
            MEM:     reg_data = s_dmem_rdata;
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

    // CSR Interface
    logic [1:0] csr_op;
    logic [11:0] csr_addr;
    logic [31:0] csr_rd_data, csr_wr_data;
    assign csr_wr_data = func3[2] ? immed : rs1_data;
    assign csr_addr = inst[31:20];
    assign csr_op = func3[1:0];

    // Trap Interface
    logic trap_pending;
    logic [31:0] trap_vector, trap_return;

    csr csr (
        .clk,
        .rst_n,

        .csr_write,
        .csr_op,
        .csr_addr,
        .csr_wr_data,
        .csr_rd_data,

        .interrupts,
        .illegal_inst,
        .inst_addr_misalign,
        .load_addr_misalign,
        .store_addr_misalign,
        .env_call,
        .env_break,

        .pc(pc_out),
        .instruction(inst),
        .misaligned_addr(alu_out),

        .trap_pending,
        .trap_start,
        .trap_finish,
        .trap_vector,
        .trap_return
    );

    /*
     * MEMORY INTERFACE
     */

    // Instruction interface
    assign imem_addr  = pc_out;

    // Data Interface
    logic [1:0] dmem_size;
    assign dmem_size = inst[13:12];
    assign dmem_addr = alu_out;

    // Misaligned Data Memory Address
    logic dmem_addr_misalign;
    assign dmem_addr_misalign = (dmem_size == WORD && |dmem_addr[1:0]) || (dmem_size == HALF && dmem_addr[0]);

    // Align incoming read data
    logic data_sign;
    assign data_sign = inst[14];
    logic [31:0] s_dmem_rdata;

    always_comb begin
        case(data_sign)
            SIGNED: begin
                case(dmem_size)
                    BYTE:    s_dmem_rdata = 32'(signed'(dmem_rdata[8*dmem_addr[1:0] +: 8]));
                    HALF:    s_dmem_rdata = 32'(signed'(dmem_rdata[8*dmem_addr[1:0] +: 16]));
                    default: s_dmem_rdata = dmem_rdata;
                endcase
            end

            UNSIGNED: begin
                case (dmem_size)
                    BYTE:    s_dmem_rdata = 32'(dmem_rdata[8*dmem_addr[1:0] +: 8]);
                    HALF:    s_dmem_rdata = 32'(dmem_rdata[8*dmem_addr[1:0] +: 16]);
                    default: s_dmem_rdata = dmem_rdata;
                endcase
            end
        endcase
    end

    // Convert size to byte enable
    always_comb begin
        case (dmem_size)
            BYTE:    dmem_byte_en = (4'b0001 << dmem_addr[1:0]);
            HALF:    dmem_byte_en = (4'b0011 << dmem_addr[1:0]);
            WORD:    dmem_byte_en = 4'b1111;
            default: dmem_byte_en = 4'b0000;
        endcase
    end

    // Setup write data
    always_comb begin
        case (dmem_size)
            BYTE:    dmem_wdata = rs2_data << (8 * dmem_addr[1:0]);
            HALF:    dmem_wdata = rs2_data << (16 * dmem_addr[1]);
            WORD:    dmem_wdata = rs2_data;
            default: dmem_wdata = rs2_data;
        endcase
    end

endmodule
