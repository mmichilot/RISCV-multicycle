`timescale 1ns / 1ps
`include "buses.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  M. Michilot
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: OTTER Core
// Module Name: core
// Project Name: OTTER CPU
// Target Devices: 
// Tool Versions: 
// Description: Contains the core of OTTER CPU that handles code execution
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module core(
    input rst,
    input clk,
    otter_bus.primary bus
    );
    
    // -- Signals --
    
    // Control Unit
    logic pcUpdate, irWrite, addrSrc, regWrite, aluCtrl, enBranch;
    logic [1:0] regSrc, aluSrcA, aluSrcB;

    // Decoder
    logic [2:0] immedSrc;
    logic [3:0] aluOp;

    // Datapath
    /* verilator lint_off UNUSED */
    logic [31:0] inst;
    /* verilator lint_on UNUSED */


    assign bus.size = inst[13:12]; // Size of data to be written to bus

    (* keep = 1 *)
    (* keep_hierarchy=1 *)
    control_unit control_unit(
        // Inputs
    	.clk      (clk),
        .rst      (rst),
        .opcode   (inst[6:0]),
        .error    (bus.error),

        // Outputs
        .enBranch (enBranch),
        .pcUpdate (pcUpdate),
        .irWrite  (irWrite),
        .addrSrc  (addrSrc),
        .memWrite (bus.wr),
        .memRead  (bus.rd),
        .regSrc   (regSrc),
        .regWrite (regWrite),
        .aluSrcA  (aluSrcA),
        .aluSrcB  (aluSrcB),
        .aluCtrl  (aluCtrl)
    );

    (* keep = 1 *)
    (* keep_hierarchy=1 *)
    decoder decoder(
        // Inputs
    	.opcode    (inst[6:0]),
        .func3     (inst[14:12]),
        .func7     (inst[31:25]),
        .aluCtrl   (aluCtrl),

        // Outputs
        .immedSrc  (immedSrc),
        .aluOp     (aluOp)
    );

    (* keep = 1 *)
    (* keep_hierarchy=1 *)
    datapath datapath(
        // Inputs
    	.clk      (clk),
        .rst      (rst),
        .data_in  (bus.rdata),
        .enBranch (enBranch),
        .pcUpdate (pcUpdate),
        .irWrite  (irWrite),
        .addrSrc  (addrSrc),
        .regSrc   (regSrc),
        .regWrite (regWrite),
        .immedSrc (immedSrc),
        .aluSrcA  (aluSrcA),
        .aluSrcB  (aluSrcB),
        .aluOp    (aluOp),

        // Outputs
        .inst_out (inst),
        .addr     (bus.addr),
        .data_out (bus.wdata)
    );

endmodule
