`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: 
// Module Name: OTTER_CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cpu
    (
        input clk,
        input rst
    ); 

    // -- Signals --
    
    // Control Unit
    logic pcUpdate, irWrite, addrSrc, memWrite, memRead, regWrite, aluCtrl, enBranch;
    logic [1:0] regSrc, aluSrcA, aluSrcB;

    // Decoder
    logic [2:0] immedSrc;
    logic [3:0] aluOp;

    // Datapath
    /* verilator lint_off UNUSED */
    logic [31:0] addr, inst;
    /* verilator lint_on UNUSED */

    // Memory
    logic mem_error;
    logic [31:0] mem_out, mem_in;

    // -- Deprecated --
    logic br_lt,br_eq,br_ltu;
    //Branch Condition Generator
    always_comb
    begin
        br_lt=0; br_eq=0; br_ltu=0;
    end

    (* keep_hierarchy=1 *)
    control_unit control_unit(
        // Inputs
    	.clk      (clk      ),
        .rst      (rst      ),
        .opcode   (inst[6:0]),
        .error    (mem_error),

        // Outputs
        .enBranch (enBranch ),
        .pcUpdate (pcUpdate ),
        .irWrite  (irWrite  ),
        .addrSrc  (addrSrc  ),
        .memWrite (memWrite ),
        .memRead  (memRead  ),
        .regSrc   (regSrc   ),
        .regWrite (regWrite ),
        .aluSrcA  (aluSrcA  ),
        .aluSrcB  (aluSrcB  ),
        .aluCtrl  (aluCtrl  )
    );

    (* keep_hierarchy=1 *)
    decoder decoder(
        // Inputs
    	.opcode    (inst[6:0]),
        .func3     (inst[14:12]),
        .func7     (inst[31:25]),
        .aluCtrl   (aluCtrl   ),
        .CU_BR_EQ  (br_eq  ),
        .CU_BR_LT  (br_lt ),
        .CU_BR_LTU (br_ltu ),

        // Outputs
        .immedSrc  (immedSrc  ),
        .aluOp     (aluOp     )
    );

    (* keep_hierarchy=1 *)
    datapath datapath(
        // Inputs
    	.clk      (clk      ),
        .rst      (rst      ),
        .data_in  (mem_out  ),
        .enBranch (enBranch ),
        .pcUpdate (pcUpdate ),
        .irWrite  (irWrite  ),
        .addrSrc  (addrSrc  ),
        .regSrc   (regSrc   ),
        .regWrite (regWrite ),
        .immedSrc (immedSrc ),
        .aluSrcA  (aluSrcA  ),
        .aluSrcB  (aluSrcB  ),
        .aluOp    (aluOp    ),

        // Outputs
        .addr     (addr     ),
        .inst_out (inst ),
        .data_out (mem_in )
    );

    (* keep_hierarchy=1 *)
    memory mem(
        // Inputs
    	.clk   (clk   ),
        .rd    (memRead),
        .we    (memWrite    ),
        .addr  (addr  ),
        .data  (mem_in  ),
        .size  (inst[13:12]  ),

        // Outputs
        .out   (mem_out   ),
        .error (mem_error )
    );

endmodule
