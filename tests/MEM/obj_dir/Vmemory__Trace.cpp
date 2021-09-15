// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmemory__Syms.h"


//======================

void Vmemory::traceChg(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    Vmemory* t = (Vmemory*)userthis;
    Vmemory__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    if (vlSymsp->getClearActivity()) {
        t->traceChgThis(vlSymsp, vcdp, code);
    }
}

//======================


void Vmemory::traceChgThis(Vmemory__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        if (VL_UNLIKELY((1U & (vlTOPp->__Vm_traceActivity 
                               | (vlTOPp->__Vm_traceActivity 
                                  >> 1U))))) {
            vlTOPp->traceChgThis__2(vlSymsp, vcdp, code);
        }
        if (VL_UNLIKELY((4U & vlTOPp->__Vm_traceActivity))) {
            vlTOPp->traceChgThis__3(vlSymsp, vcdp, code);
        }
        vlTOPp->traceChgThis__4(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void Vmemory::traceChgThis__2(Vmemory__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->chgBit(c+1,(vlTOPp->memory__DOT__s_rd));
        vcdp->chgBit(c+9,(vlTOPp->memory__DOT__s_wr));
    }
}

void Vmemory::traceChgThis__3(Vmemory__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->chgBus(c+17,(vlTOPp->memory__DOT____Vcellout__bank0__dout),8);
        vcdp->chgBus(c+25,(vlTOPp->memory__DOT____Vcellout__bank1__dout),8);
        vcdp->chgBus(c+33,(vlTOPp->memory__DOT____Vcellout__bank2__dout),8);
        vcdp->chgBus(c+41,(vlTOPp->memory__DOT____Vcellout__bank3__dout),8);
    }
}

void Vmemory::traceChgThis__4(Vmemory__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->chgBit(c+49,(vlTOPp->clk));
        vcdp->chgBit(c+57,(vlTOPp->rd));
        vcdp->chgBus(c+65,(vlTOPp->addr),14);
        vcdp->chgBus(c+73,(vlTOPp->dout),32);
        vcdp->chgBit(c+81,(vlTOPp->wr));
        vcdp->chgBus(c+89,(vlTOPp->din),32);
        vcdp->chgBus(c+97,(vlTOPp->size),2);
        vcdp->chgBit(c+105,(vlTOPp->sign));
        vcdp->chgBit(c+113,(vlTOPp->err));
        vcdp->chgBus(c+121,((0xffU & vlTOPp->din)),8);
        vcdp->chgBus(c+129,((0xffU & (vlTOPp->din >> 8U))),8);
        vcdp->chgBus(c+137,((0xffU & (vlTOPp->din >> 0x10U))),8);
        vcdp->chgBus(c+145,((0xffU & (vlTOPp->din >> 0x18U))),8);
    }
}
