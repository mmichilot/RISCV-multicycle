#include <memory>
#include <verilated.h>
#include "Vmemory.h"

int main(int argc, char** argv, char** env) {
    
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->debug(0);
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);

    const std::unique_ptr<Vmemory> top{new Vmemory{contextp.get(), "TOP"}};
    
    int cycle = 0;

    top->clk = 0;
    top->wr = 1;
    top->rd = 0;
    top->din = cycle;

    while(!contextp->gotFinish()) {
        top->addr = (cycle % 40);

        if (cycle == 40) {
            top->wr = 0;
            top->rd = 1;
        }
        
        top->clk = !top->clk;
        top->eval();
        contextp->timeInc(1);

        top->clk = !top->clk;
        top->eval();
        contextp->timeInc(1);

        cycle++;
    }

    top->final();

}
