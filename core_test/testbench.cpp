// Based off of tracing example from Verilator

// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.sv"
#include "Vtop.h"

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Create logs/directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

    // Set debug level, 0 is off 9 is highest
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Costruct the Verilated model, from Vtop.h generated from Verilating "top.v"
    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};

    // set Vtop's input signals
    top->clk = 0;
    top->rst = 0;

    // Simulate for a certain time
    while (contextp->time() < 200) {
        contextp->timeInc(1); // 1 timeprecision period passes

        // Toggle a fast (time/2 period) clock
        top->clk = !top->clk;

        // Toggle control signals on an edge that doesnt' correspond
        // to where the controls are sampled.
        if (!top->clk) {
            if (contextp->time() > 4 && contextp->time() < 10)
                top->rst = 1;
            else 
                top->rst = 0;
        }

        // Evaluate model
        top->eval();
    }

    top->final();

    return 0;
}   

