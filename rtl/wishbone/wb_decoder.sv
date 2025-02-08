`timescale 1ns / 1ps

module wb_decoder (
    input  logic [31:0] adr_i,

    // Slave 0
    input  logic [31:0] slv0_adr_prefix,
    input  logic [31:0] slv0_adr_mask,
    output logic        acmp0,

    // Slave 1
    input  logic [31:0] slv1_adr_prefix,
    input  logic [31:0] slv1_adr_mask,
    output logic        acmp1,

    // Slave 2
    input  logic [31:0] slv2_adr_prefix,
    input  logic [31:0] slv2_adr_mask,
    output logic        acmp2
);

// Mask away unnecessary bits from the lower half of the address. Use XOR to determine whether
// the remaining bits match the prefix. Any discrepancy will remain as a set bit in the result,
// which can then be found using the reduction (|) operator.
// Result has any bit set -> result is 1 -> invert to represent no match.
assign acmp0 = ~|((adr_i & slv0_adr_mask) ^ slv0_adr_prefix);
assign acmp1 = ~|((adr_i & slv1_adr_mask) ^ slv1_adr_prefix);
assign acmp2 = ~|((adr_i & slv2_adr_mask) ^ slv2_adr_prefix);

endmodule
