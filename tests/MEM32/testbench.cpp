#include <iostream>
#include <fstream>

#include <backends/cxxrtl/cxxrtl_vcd.h>

#include "rom.cpp"

using namespace std;

typedef unsigned int U_INT;
typedef unsigned char U_CHAR;
typedef bool BIT;

int main()
{
    cxxrtl_design::p_rom top;

    cxxrtl::debug_items all_debug_items;

    top.debug_info(all_debug_items);

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");

    vcd.add_without_memories(all_debug_items);

    std::ofstream waves("rom.vcd");

    // Initialization
    top.p_i__rst.set<BIT>(0);

    top.p_i__wb__addr.set<U_INT>(0);
    top.p_i__wb__dat.set<U_INT>(0);
    top.p_i__wb__sel.set<U_CHAR>(0);
    top.p_i__wb__we.set<BIT>(0);
    top.p_i__wb__cyc.set<BIT>(0);
    top.p_i__wb__stb.set<BIT>(0);

    top.step();
    vcd.sample(0);

    for (int cycle=0; cycle<1000;++cycle) {

        top.p_i__wb__cyc.set<BIT>(1);
        top.p_i__wb__stb.set<BIT>(1);
        if ((cycle % 2) == 0)
            top.p_i__wb__addr.set<U_INT>(cycle * 2);

        top.p_i__clk.set<BIT>(0);
        top.step();
        vcd.sample(cycle*2 + 0);

        top.p_i__clk.set<BIT>(1);
        top.step();
        vcd.sample(cycle*2 + 1);

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}
