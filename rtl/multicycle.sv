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

   /**
    *         _                _    
    *      __(_)__ _ _ _  __ _| |___
    *     (_-< / _` | ' \/ _` | (_-<
    *     /__/_\__, |_||_\__,_|_/__/
    *          |___/                
    */

    // Instruction
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
    logic imem_read, dmem_read, dmem_write;
    logic pc_write, reg_write, csr_write;
    logic illegal_inst, inst_addr_misalign, load_addr_misalign, store_addr_misalign, env_call, env_break;
    logic trap_start, trap_finish;

    // Decoder
    logic alu_b_src;
    logic [1:0] alu_a_src, reg_src;
    logic [2:0] pc_src, immed_type;
    logic [3:0] alu_op;

    // Program Counter
    logic [31:0] pc_in, pc_out, next_pc;
    assign next_pc = pc_out + 4;

    // Branch Generator
    logic take_branch;

    // Immediate Generator
    logic [31:0] immed;

    // Register File
    logic [31:0] rs1_data, rs2_data, rd_data;

    // ALU
    logic [31:0] alu_a_data, alu_b_data, alu_out;

    // IRQ Controller
    logic trap_pending;
    logic [31:0] mip, trap_cause;

    // CSR
    logic irq_en;
    logic [31:0] csr_rdata, mie, mtvec, mepc;

    // Memory
    logic cpu_stall;
    logic [31:0] inst, data;

    /**
    *                 _           _             _ _   
    *      __ ___ _ _| |_ _ _ ___| |  _  _ _ _ (_) |_ 
    *     / _/ _ \ ' \  _| '_/ _ \ | | || | ' \| |  _|
    *     \__\___/_||_\__|_| \___/_|  \_,_|_||_|_|\__|
    *                                                 
    */
    control_unit control_unit (
    	.clk,
        .rst_n,
        .inst,

        .take_branch,
        .cpu_stall,

        // Trap Handling
        .trap_pending,
        .trap_start,
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
        .csr_write
    );

    /**
    *         _                _         
    *      __| |___ __ ___  __| |___ _ _ 
    *     / _` / -_) _/ _ \/ _` / -_) '_|
    *     \__,_\___\__\___/\__,_\___|_|  
    *                                    
    */
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

    /**
    *                                                          _           
    *      _ __ _ _ ___  __ _ _ _ __ _ _ __    __ ___ _  _ _ _| |_ ___ _ _ 
    *     | '_ \ '_/ _ \/ _` | '_/ _` | '  \  / _/ _ \ || | ' \  _/ -_) '_|
    *     | .__/_| \___/\__, |_| \__,_|_|_|_| \__\___/\_,_|_||_\__\___|_|  
    *     |_|           |___/                                              
    */
    always_comb begin
        unique case(pc_src)
            PC_PLUS_4: pc_in = next_pc;
            ALU_OUT:   pc_in = alu_out;
            LSB_ZERO:  pc_in = { alu_out[31:1], 1'b0 };
            CSR_MTVEC: pc_in = mtvec;
            CSR_MEPC:  pc_in = mepc;
            default:   pc_in = next_pc;
        endcase
    end

    prog_cntr #(
        .RESET_ADDR (RESET_VECTOR)
    ) prog_cntr (
        .clk,
        .rst_n,
        .ld(pc_write),
        .data(pc_in),
        .count(pc_out)
    );

    /**
    *      _                     _                    
    *     | |__ _ _ __ _ _ _  __| |_    __ _ ___ _ _  
    *     | '_ \ '_/ _` | ' \/ _| ' \  / _` / -_) ' \ 
    *     |_.__/_| \__,_|_||_\__|_||_| \__, \___|_||_|
    *                                  |___/          
    */
    branch_gen branch_gen (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .func3,
        .take_branch
    );

    /**
    *      _                    _                 
    *     (_)_ __  _ __  ___ __| |  __ _ ___ _ _  
    *     | | '  \| '  \/ -_) _` | / _` / -_) ' \ 
    *     |_|_|_|_|_|_|_\___\__,_| \__, \___|_||_|
    *                              |___/          
    */
    immed_gen immed_gen (
        .inst,
        .immed_type,
        .immed
    );

    /**
    *                   _    _              __ _ _     
    *      _ _ ___ __ _(_)__| |_ ___ _ _   / _(_) |___ 
    *     | '_/ -_) _` | (_-<  _/ -_) '_| |  _| | / -_)
    *     |_| \___\__, |_/__/\__\___|_|   |_| |_|_\___|
    *             |___/                                
    */
    always_comb begin
        unique case(reg_src)
            NEXT_PC: rd_data = next_pc;
            ALU:     rd_data = alu_out;
            MEM:     rd_data = data;
            CSR:     rd_data = csr_rdata;
        endcase
    end

    reg_file reg_file (
        .clk,
        .wr(reg_write),
        .rs1,
        .rs2,
        .rd,
        .rd_data,
        .rs1_data,
        .rs2_data
    );

    /**
    *           _      
    *      __ _| |_  _ 
    *     / _` | | || |
    *     \__,_|_|\_,_|
    *                  
    */
    always_comb begin
        unique case(alu_a_src)
            RS1:     alu_a_data = rs1_data;
            CURR_PC: alu_a_data = pc_out;
            ZERO:    alu_a_data = '0;
            default: alu_a_data = '0;
        endcase
    end
    
    always_comb begin
        unique case(alu_b_src)
            RS2: alu_b_data = rs2_data;
            IMMED: alu_b_data = immed;
        endcase
    end

    
    alu alu (
        .op(alu_op),
        .a(alu_a_data),
        .b(alu_b_data),
        .out(alu_out)
    );
    

    /**
    *      _                       _           _ _         
    *     (_)_ _ __ _   __ ___ _ _| |_ _ _ ___| | |___ _ _ 
    *     | | '_/ _` | / _/ _ \ ' \  _| '_/ _ \ | / -_) '_|
    *     |_|_| \__, | \__\___/_||_\__|_| \___/_|_\___|_|  
    *              |_|                                     
    */
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


    /**
    *                
    *      __ ____ _ 
    *     / _(_-< '_|
    *     \__/__/_|  
    *                
    */
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
        .trap_start,
        .trap_finish,

        .mtvec,
        .mepc
    );


    /**
    *                                   
    *      _ __  ___ _ __  ___ _ _ _  _ 
    *     | '  \/ -_) '  \/ _ \ '_| || |
    *     |_|_|_\___|_|_|_\___/_|  \_, |
    *                              |__/ 
    */
    memory memory(
        .clk_i       (clk),
        .rst_i       (~rst_n),

        .cpu_stall,

        .imem_read,
        .imem_addr   (pc_out),
        .instruction (inst),

        .dmem_read,
        .dmem_write,
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
