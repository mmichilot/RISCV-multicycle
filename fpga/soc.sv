`timescale 1ns / 1ps

module soc (
        input clk,
        input rst_n,

        output logic [7:0] leds
    );


    /////////////////////////////
    //    ____                 //
    //   / ___|___  _ __ ___   //
    //  | |   / _ \| '__/ _ \  //
    //  | |__| (_) | | |  __/  //
    //   \____\___/|_|  \___|  //
    /////////////////////////////
    logic timer_int, software_int;
    logic [31:0] interrupts;
    assign interrupts[7] = timer_int;
    assign interrupts[3] = software_int;

    logic wb_cyc_o, wb_stb_o, wb_we_o, wb_ack_i;
    logic [3:0] wb_sel_o;
    logic [31:0] wb_adr_o, wb_dat_i, wb_dat_o;
    core core(
        .clk,
        .rst_n,

        .wb_cyc_o,
        .wb_stb_o,
        .wb_stall_i (0),
        .wb_ack_i,
        .wb_we_o,
        .wb_sel_o,
        .wb_adr_o,
        .wb_dat_o,
        .wb_dat_i,

        .interrupts
    );


    /////////////////////////////////////
    //   ____  ____      _    __  __   //
    //  / ___||  _ \    / \  |  \/  |  //
    //  \___ \| |_) |  / _ \ | |\/| |  //
    //   ___) |  _ <  / ___ \| |  | |  //
    //  |____/|_| \_\/_/   \_\_|  |_|  //
    /////////////////////////////////////
    localparam SRAM_SIZE = 32_768;
    localparam SRAM_ADDR_WIDTH = $clog2(SRAM_SIZE);
    logic sram_ack_o;
    logic [31:0] sram_dat_o;
    wb_sram #(
        .SIZE_BYTES(SRAM_SIZE),
        .FILE("../firmware/build/firmware.hex")
    ) sram (
        .wb_clk_i (clk),
        .wb_cyc_i (wb_cyc_o),
        .wb_stb_i (wb_stb_o & sram_sel),
        .wb_adr_i (wb_adr_o[SRAM_ADDR_WIDTH-1:0]),
        .wb_we_i  (wb_we_o),
        .wb_sel_i (wb_sel_o),
        .wb_dat_i (wb_dat_o),
        .wb_dat_o (sram_dat_o),
        .wb_ack_o (sram_ack_o)
    );


    /////////////////////////////////////
    //    ____ _     ___ _   _ _____   //
    //   / ___| |   |_ _| \ | |_   _|  //
    //  | |   | |    | ||  \| | | |    //
    //  | |___| |___ | || |\  | | |    //
    //   \____|_____|___|_| \_| |_|    //
    /////////////////////////////////////
    logic clint_ack_o;
    logic [31:0] clint_dat_o;
    clint clint (
        .clk ,
        .rst_n,

        .wb_cyc_i (wb_cyc_o),
        .wb_stb_i (wb_stb_o & clint_sel),
        .wb_we_i  (wb_we_o),
        .wb_adr_i (wb_adr_o[15:0]),
        .wb_sel_i (wb_sel_o),
        .wb_dat_i (wb_dat_o),
        .wb_dat_o (clint_dat_o),
        .wb_ack_o (clint_ack_o),

        .software_int,
        .timer_int
    );


    ///////////////////////////////////////////////////////////
    //   ____           _       _                    _       //
    //  |  _ \ ___ _ __(_)_ __ | |__   ___ _ __ __ _| |___   //
    //  | |_) / _ \ '__| | '_ \| '_ \ / _ \ '__/ _` | / __|  //
    //  |  __/  __/ |  | | |_) | | | |  __/ | | (_| | \__ \  //
    //  |_|   \___|_|  |_| .__/|_| |_|\___|_|  \__,_|_|___/  //
    //                   |_|                                 //
    ///////////////////////////////////////////////////////////
    logic led_ack_o;
    logic [31:0] led_dat_o;
    led_driver led_driver (
        .clk,
        .rst_n,

        .wb_cyc_i (wb_cyc_o),
        .wb_stb_i (wb_stb_o & led_sel),
        .wb_we_i  (wb_we_o),
        .wb_ack_o (led_ack_o),
        .wb_sel_i (wb_sel_o),
        .wb_adr_i (wb_adr_o[1:0]),
        .wb_dat_i (wb_dat_o),
        .wb_dat_o (led_dat_o),

        .leds
    );


    //////////////////////////////////////////////
    //   ____                     _             //
    //  |  _ \  ___  ___ ___   __| | ___ _ __   //
    //  | | | |/ _ \/ __/ _ \ / _` |/ _ \ '__|  //
    //  | |_| |  __/ (_| (_) | (_| |  __/ |     //
    //  |____/ \___|\___\___/ \__,_|\___|_|     //
    //////////////////////////////////////////////
    localparam SRAM_BASE = 32'h8000_0000;
    localparam SRAM_MASK = ~(SRAM_SIZE-1);
    localparam CLINT_BASE = 32'h0200_0000;
    localparam CLINT_MASK = 32'hFFFF_0000;
    localparam LED_BASE = 32'h0201_0000;
    localparam LED_MASK = 32'hFFFF_FFFC;

    logic sram_sel, clint_sel, led_sel;
    wb_decoder wb_decoder (
        .adr_i           (wb_adr_o),

        .slv0_adr_prefix (SRAM_BASE),
        .slv0_adr_mask   (SRAM_MASK),
        .acmp0           (sram_sel),

        .slv1_adr_prefix (CLINT_BASE),
        .slv1_adr_mask   (CLINT_MASK),
        .acmp1           (clint_sel),

        .slv2_adr_prefix (LED_BASE),
        .slv2_adr_mask   (LED_MASK),
        .acmp2           (led_sel)
    );

    always_comb begin : wb_dat_i_mux
        wb_dat_i = '0;

        if (sram_sel)
            wb_dat_i = sram_dat_o;
        if (clint_sel)
            wb_dat_i = clint_dat_o;
        if (led_sel)
            wb_dat_i = led_dat_o;
    end

    assign wb_ack_i = clint_ack_o | sram_ack_o | led_ack_o;

endmodule
