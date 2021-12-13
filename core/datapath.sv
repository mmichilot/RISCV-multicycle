`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: OTTER Datapath
// Module Name: datapath
// Project Name: OTTER CPU
// Target Devices: N/A
// Tool Versions: 
// Description: Describes the architecture layout
// 
// Dependencies: alu, prog_cntr, reg_file, sz_ex, immed_gen
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module datapath 
    (
        input clk,
        input rst,

        input enBranch,
        input pcUpdate,
        input irWrite,
        input addrSrc,
        input [1:0] regSrc,
        input regWrite,
        input [2:0] immedSrc,
        input [1:0] aluSrcA,
        input [1:0] aluSrcB,
        input [3:0] aluOp,

        input [31:0] data_in,

        output logic [31:0] addr,
        output logic [31:0] inst_out,
        output logic [31:0] data_out
    );

    // -- Signals --

    // Branch Generator
    logic takeBranch;

    // Program Counter
    logic pc_ld;
    logic [31:0] pc_out;

    // Size + Extend
    //logic [31:0] sz_ex_out;

    // Register File
    logic [31:0] rs1_data, rs2_data, rd_data;

    // Immediate Generator
    logic [31:0] immed;

    // ALU
    logic [31:0] alu_a, alu_b, alu_out;

    // -- MUX Select Signal Enums
    /* verilator lint_off UNUSED */
    enum logic {PC_OUT,ALU_OUT} addrSrc_e;
    enum logic [1:0] {PC,ALU,MEM} regSrc_e;
    enum logic [1:0] {CURR_PC,OLD_PC,RS1,ZERO} aluSrcA_e;
    enum logic [1:0] {RS2,IMMED,FOUR} aluSrcB_e;
    /* verilator lint_on UNUSED */

    // -- Non-architectural registers --
    logic [31:0] inst, old_pc;

    assign inst_out = inst; // Pass instruction to control unit
    assign data_out = rs2_data; // Pass data to bus
    
    // -- Datapath Layout --
    brn_gen brn_gen(
    	.rs1        (rs1_data),
        .rs2        (rs2_data),
        .func3      (inst[14:12]),
        .takeBranch (takeBranch)
    );
    
    assign pc_ld = pcUpdate | (enBranch && takeBranch); 

    // Program Counter
    (* keep_hierarchy=1 *)
    prog_cntr pc(
        // Inputs
    	.clk   (clk),
        .rst   (rst),
        .ld    (pc_ld),
        .data  (alu_out),

        // Outputs
        .count (pc_out)
    );

    always_comb begin : addrSrc_MUX
        case (addrSrc)
            PC_OUT:  addr = pc_out;
            ALU_OUT: addr = alu_out;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            inst   <= 0;
            old_pc <= 0;
        end else if (irWrite) begin
            inst   <= data_in;
            old_pc <= pc_out;
        end
    end

    // Size and Extend
    // (* keep_hierarchy=1 *)
    // sz_ex sz_ex(
    //     // Inputs
    // 	.data     (data_in),
    //     .byte_sel (addr[1:0]),
    //     .size     (inst[13:12]),
    //     .sign     (inst[14]),

    //     // Outputs
    //     .out      (sz_ex_out)
    // );
    

    always_comb begin : regSrc_MUX
        case(regSrc)
            PC:      rd_data = pc_out;
            ALU:     rd_data = alu_out;
            MEM:     rd_data = data_in;
            default: rd_data = alu_out;
        endcase
    end

    // Register File
    (* keep_hierarchy=1 *)
    reg_file reg_file(
        // Inputs
    	.clk      (clk),
        .wr       (regWrite),
        .rs1      (inst[19:15]),
        .rs2      (inst[24:20]),
        .rd       (inst[11:7]),

        // Outputs
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    // Immediate Generator
    (* keep_hierarchy=1 *)
    immed_gen immed_gen(
        // Inputs
    	.inst     (inst),
        .immedSrc (immedSrc),

        // Outputs
        .immed    (immed)
    );

    always_comb begin : aluSrcA_MUX
        case(aluSrcA)
            CURR_PC: alu_a = pc_out;
            OLD_PC:  alu_a = old_pc;
            RS1:     alu_a = rs1_data;
            ZERO:    alu_a = 0;
        endcase
    end

    always_comb begin : aluSrcB_MU
        case(aluSrcB)
            RS2:     alu_b = rs2_data;
            IMMED:   alu_b = immed;
            FOUR:    alu_b = 4;
            default: alu_b = rs2_data;
        endcase
    end

    // ALU
    (* keep_hierarchy=1 *)
    alu alu(
    	.aluOp (aluOp ),
        .a     (alu_a),
        .b     (alu_b),
        .out   (alu_out)
    );

    // always_comb begin : byte_sel_set
    //     byte_sel = 4'b0;

    //     case(inst[13:12])
    //             BYTE:    s_we[byte_sel] = 1'b1;
    //             HALF:    s_we[byte_sel +: 2] = 2'b11;
    //             WORD:    s_we = 4'b1111;
    //             default: s_we = 0;
    //     endcase
    // end
    
endmodule
