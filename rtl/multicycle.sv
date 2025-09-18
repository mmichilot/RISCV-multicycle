`timescale 1ns / 1ps
`include "defs.svh"

module multicycle #(
        parameter RESET_VECTOR = 'h8000_0000
    )(
        input clk,
        input rst_n,

        // Wishbone interface
        output logic        wb_cyc_o,
        output logic        wb_stb_o,
        input  logic        wb_stall_i,
        input  logic        wb_ack_i,
        output logic        wb_we_o,
        output logic [3:0]  wb_sel_o,
        output logic [31:0] wb_adr_o,
        output logic [31:0] wb_dat_o,
        input  logic [31:0] wb_dat_i,

        // Interrupt Interface
        input logic [31:0] interrupts
    );

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
    logic imem_read, dmem_read, dmem_write, imem_ready, dmem_ready;
    logic pc_write, reg_write, csr_write;
    logic illegal_inst, inst_addr_misalign, load_addr_misalign, store_addr_misalign, env_call, env_break;
    logic trap_finish;
    control_unit control_unit (
    	.clk,
        .rst_n,
        .inst,

        .take_branch,

        // Trap Handling
        .trap_pending,
        .trap_finish,

        .mem_addr(alu_out),

        // Exceptions
        .illegal_inst,
        .inst_addr_misalign,
        .load_addr_misalign,
        .store_addr_misalign,
        .env_call,
        .env_break,

        .pc_write,
        .imem_read,
        .dmem_read,
        .dmem_write,
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
        .trap_pending,
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
            CSR_MTVEC: pc_data = mtvec;
            CSR_MEPC:  pc_data = mepc;
            default:   pc_data = next_pc;
        endcase
    end

    // Program Counter
    logic [31:0] pc_out;
    prog_cntr #(
        .RESET_ADDR (RESET_VECTOR)
    ) prog_cntr (
        .clk,
        .rst_n,
        .ld(pc_write | trap_pending),
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
            MEM:     reg_data = data;
            CSR:     reg_data = csr_rdata;
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


    /////////////////////////////////////////////////////////
    //   ___       _                             _         //
    //  |_ _|_ __ | |_ ___ _ __ _ __ _   _ _ __ | |_ ___   //
    //   | || '_ \| __/ _ \ '__| '__| | | | '_ \| __/ __|  //
    //   | || | | | ||  __/ |  | |  | |_| | |_) | |_\__ \  //
    //  |___|_| |_|\__\___|_|  |_|   \__,_| .__/ \__|___/  //
    //                                    |_|              //
    /////////////////////////////////////////////////////////
    logic trap_pending;
    logic [31:0] mip, trap_cause;
    irq_controller irq_controller (
        .clk,
        .rst_n,

        .irq_en,
        .mie,
        .mip,

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


    ///////////////////////////////
    //    ____ ____  ____        //
    //   / ___/ ___||  _ \ ___   //
    //  | |   \___ \| |_) / __|  //
    //  | |___ ___) |  _ <\__ \  //
    //   \____|____/|_| \_\___/  //
    ///////////////////////////////
    logic irq_en;
    logic [31:0] csr_rdata, mie, mtvec, mepc;
    csr csr (
        .clk,
        .rst_n,

        .csr_we    (csr_write),
        .csr_op    (func3[1:0]),
        .csr_reg   (inst[31:20]),
        .csr_wdata (func3[2] ? 32'(rs1) : rs1_data),
        .csr_rdata,


        .pc(pc_out),
        .instruction(inst),
        .misaligned_addr(alu_out),

        .mie,
        .irq_en,

        .mip,
        .trap_cause,
        .trap_pending,
        .trap_finish,

        .mtvec,
        .mepc
    );


    ////////////////////////////////////////////////
    //   __  __                                   //
    //  |  \/  | ___ _ __ ___   ___  _ __ _   _   //
    //  | |\/| |/ _ \ '_ ` _ \ / _ \| '__| | | |  //
    //  | |  | |  __/ | | | | | (_) | |  | |_| |  //
    //  |_|  |_|\___|_| |_| |_|\___/|_|   \__, |  //
    //                                    |___/   //
    ////////////////////////////////////////////////
    logic [31:0] inst, data;
    memory memory(
        .clk_i       (clk),
        .rst_i       (~rst_n),

        .imem_read,
        .imem_ready,
        .imem_addr   (pc_out),
        .instruction (inst),

        .dmem_read,
        .dmem_write,
        .dmem_ready,
        .dmem_size   (inst[13:12]),
        .dmem_sign   (inst[14]),
        .dmem_addr   (alu_out),
        .dmem_wdata  (rs2_data),
        .data,

        .wb_cyc_o,
        .wb_stb_o,
        .wb_stall_i,
        .wb_ack_i,
        .wb_we_o,
        .wb_sel_o,
        .wb_adr_o,
        .wb_dat_o,
        .wb_dat_i
    );

endmodule
