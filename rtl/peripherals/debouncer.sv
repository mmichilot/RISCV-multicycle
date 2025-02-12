`timescale 1ns/1ps

module debouncer (
    input clk,

    input btn,
    output logic btn_debounced
);

// 2FF Synchronizer
logic btn_q, btn_sync;
always_ff @(posedge clk) begin
    btn_q <= btn;
    btn_sync <= btn_q;
end

// How it works:
// 1. When a change is detected b/w the debounced and synchronizer output,
//    start a timer. btn_change will remain high for the duration of the timer.
// 2. When the timer finishes counting down, set the debounced output to the
//    current synchronizer output, assuming the input has stabalized within the
//    timer period.
logic btn_change;
logic [15:0] timer;
always_ff @(posedge clk) begin
    if (!btn_change && (btn_debounced != btn_sync)) begin
        btn_change <= 1;
        timer <= {(16){1'b1}};
    end else if (btn_change && timer == '0) begin
        btn_change <= 0;
        btn_debounced <= btn_sync;
    end else if (btn_change && timer != '0)
        timer <= timer - 1;
end

endmodule