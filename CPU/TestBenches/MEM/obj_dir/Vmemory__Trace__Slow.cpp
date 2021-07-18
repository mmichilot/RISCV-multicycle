// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmemory__Syms.h"


//======================

void Vmemory::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addCallback(&Vmemory::traceInit, &Vmemory::traceFull, &Vmemory::traceChg, this);
}
void Vmemory::traceInit(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->open()
    Vmemory* t = (Vmemory*)userthis;
    Vmemory__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vcdp->scopeEscape(' ');
    t->traceInitThis(vlSymsp, vcdp, code);
    vcdp->scopeEscape('.');
}
void Vmemory::traceFull(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    Vmemory* t = (Vmemory*)userthis;
    Vmemory__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    t->traceFullThis(vlSymsp, vcdp, code);
}

//======================


void Vmemory::traceInitThis(Vmemory__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    vcdp->module(vlSymsp->name());  // Setup signal names
    // Body
    {
        vlTOPp->traceInitThis__1(vlSymsp, vcdp, code);
    }
}

void Vmemory::traceFullThis(Vmemory__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vlTOPp->traceFullThis__1(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void Vmemory::traceInitThis__1(Vmemory__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->declBit(c+49,"clk", false,-1);
        vcdp->declBit(c+57,"rd", false,-1);
        vcdp->declBus(c+65,"addr", false,-1, 13,0);
        vcdp->declBus(c+73,"dout", false,-1, 31,0);
        vcdp->declBit(c+81,"wr", false,-1);
        vcdp->declBus(c+89,"din", false,-1, 31,0);
        vcdp->declBus(c+97,"size", false,-1, 1,0);
        vcdp->declBit(c+105,"sign", false,-1);
        vcdp->declBit(c+113,"err", false,-1);
        vcdp->declBit(c+49,"memory clk", false,-1);
        vcdp->declBit(c+57,"memory rd", false,-1);
        vcdp->declBus(c+65,"memory addr", false,-1, 13,0);
        vcdp->declBus(c+73,"memory dout", false,-1, 31,0);
        vcdp->declBit(c+81,"memory wr", false,-1);
        vcdp->declBus(c+89,"memory din", false,-1, 31,0);
        vcdp->declBus(c+97,"memory size", false,-1, 1,0);
        vcdp->declBit(c+105,"memory sign", false,-1);
        vcdp->declBit(c+113,"memory err", false,-1);
        vcdp->declBus(c+153,"memory e_size", false,-1, 1,0);
        vcdp->declBit(c+161,"memory e_sign", false,-1);
        vcdp->declBit(c+1,"memory s_rd", false,-1);
        vcdp->declBit(c+9,"memory s_wr", false,-1);
        vcdp->declBus(c+169,"memory bank0 ADDR_WIDTH", false,-1, 31,0);
        vcdp->declBus(c+177,"memory bank0 DATA_WIDTH", false,-1, 31,0);
        vcdp->declBit(c+49,"memory bank0 clk", false,-1);
        vcdp->declBit(c+1,"memory bank0 rd", false,-1);
        vcdp->declBus(c+65,"memory bank0 addr", false,-1, 13,0);
        vcdp->declBus(c+17,"memory bank0 dout", false,-1, 7,0);
        vcdp->declBit(c+9,"memory bank0 wr", false,-1);
        vcdp->declBus(c+121,"memory bank0 din", false,-1, 7,0);
        vcdp->declBus(c+169,"memory bank1 ADDR_WIDTH", false,-1, 31,0);
        vcdp->declBus(c+177,"memory bank1 DATA_WIDTH", false,-1, 31,0);
        vcdp->declBit(c+49,"memory bank1 clk", false,-1);
        vcdp->declBit(c+1,"memory bank1 rd", false,-1);
        vcdp->declBus(c+65,"memory bank1 addr", false,-1, 13,0);
        vcdp->declBus(c+25,"memory bank1 dout", false,-1, 7,0);
        vcdp->declBit(c+9,"memory bank1 wr", false,-1);
        vcdp->declBus(c+129,"memory bank1 din", false,-1, 7,0);
        vcdp->declBus(c+169,"memory bank2 ADDR_WIDTH", false,-1, 31,0);
        vcdp->declBus(c+177,"memory bank2 DATA_WIDTH", false,-1, 31,0);
        vcdp->declBit(c+49,"memory bank2 clk", false,-1);
        vcdp->declBit(c+1,"memory bank2 rd", false,-1);
        vcdp->declBus(c+65,"memory bank2 addr", false,-1, 13,0);
        vcdp->declBus(c+33,"memory bank2 dout", false,-1, 7,0);
        vcdp->declBit(c+9,"memory bank2 wr", false,-1);
        vcdp->declBus(c+137,"memory bank2 din", false,-1, 7,0);
        vcdp->declBus(c+169,"memory bank3 ADDR_WIDTH", false,-1, 31,0);
        vcdp->declBus(c+177,"memory bank3 DATA_WIDTH", false,-1, 31,0);
        vcdp->declBit(c+49,"memory bank3 clk", false,-1);
        vcdp->declBit(c+1,"memory bank3 rd", false,-1);
        vcdp->declBus(c+65,"memory bank3 addr", false,-1, 13,0);
        vcdp->declBus(c+41,"memory bank3 dout", false,-1, 7,0);
        vcdp->declBit(c+9,"memory bank3 wr", false,-1);
        vcdp->declBus(c+145,"memory bank3 din", false,-1, 7,0);
    }
}

void Vmemory::traceFullThis__1(Vmemory__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->fullBit(c+1,(vlTOPp->memory__DOT__s_rd));
        vcdp->fullBit(c+9,(vlTOPp->memory__DOT__s_wr));
        vcdp->fullBus(c+17,(vlTOPp->memory__DOT____Vcellout__bank0__dout),8);
        vcdp->fullBus(c+25,(vlTOPp->memory__DOT____Vcellout__bank1__dout),8);
        vcdp->fullBus(c+33,(vlTOPp->memory__DOT____Vcellout__bank2__dout),8);
        vcdp->fullBus(c+41,(vlTOPp->memory__DOT____Vcellout__bank3__dout),8);
        vcdp->fullBit(c+49,(vlTOPp->clk));
        vcdp->fullBit(c+57,(vlTOPp->rd));
        vcdp->fullBus(c+65,(vlTOPp->addr),14);
        vcdp->fullBus(c+73,(vlTOPp->dout),32);
        vcdp->fullBit(c+81,(vlTOPp->wr));
        vcdp->fullBus(c+89,(vlTOPp->din),32);
        vcdp->fullBus(c+97,(vlTOPp->size),2);
        vcdp->fullBit(c+105,(vlTOPp->sign));
        vcdp->fullBit(c+113,(vlTOPp->err));
        vcdp->fullBus(c+121,((0xffU & vlTOPp->din)),8);
        vcdp->fullBus(c+129,((0xffU & (vlTOPp->din 
                                       >> 8U))),8);
        vcdp->fullBus(c+137,((0xffU & (vlTOPp->din 
                                       >> 0x10U))),8);
        vcdp->fullBus(c+145,((0xffU & (vlTOPp->din 
                                       >> 0x18U))),8);
        vcdp->fullBus(c+153,(vlTOPp->memory__DOT__e_size),2);
        vcdp->fullBit(c+161,(vlTOPp->memory__DOT__e_sign));
        vcdp->fullBus(c+169,(0xeU),32);
        vcdp->fullBus(c+177,(8U),32);
    }
}
