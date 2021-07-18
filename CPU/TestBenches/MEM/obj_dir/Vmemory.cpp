// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmemory.h for the primary calling header

#include "Vmemory.h"
#include "Vmemory__Syms.h"

//==========

VL_CTOR_IMP(Vmemory) {
    Vmemory__Syms* __restrict vlSymsp = __VlSymsp = new Vmemory__Syms(this, name());
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vmemory::__Vconfigure(Vmemory__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vmemory::~Vmemory() {
    delete __VlSymsp; __VlSymsp=NULL;
}

void Vmemory::eval() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vmemory::eval\n"); );
    Vmemory__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("memory.sv", 56, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vmemory::_eval_initial_loop(Vmemory__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("memory.sv", 56, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Vmemory::_combo__TOP__1(Vmemory__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_combo__TOP__1\n"); );
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->err = 0U;
    if ((1U & (~ (IData)(vlTOPp->err)))) {
        vlTOPp->err = (1U & ((1U == (IData)(vlTOPp->size))
                              ? (IData)(vlTOPp->addr)
                              : ((2U == (IData)(vlTOPp->size)) 
                                 & (0U != (3U & (IData)(vlTOPp->addr))))));
    }
}

void Vmemory::_settle__TOP__2(Vmemory__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_settle__TOP__2\n"); );
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->err = 0U;
    if ((1U & (~ (IData)(vlTOPp->err)))) {
        vlTOPp->err = (1U & ((1U == (IData)(vlTOPp->size))
                              ? (IData)(vlTOPp->addr)
                              : ((2U == (IData)(vlTOPp->size)) 
                                 & (0U != (3U & (IData)(vlTOPp->addr))))));
    }
    vlTOPp->dout = ((0xffffff00U & vlTOPp->dout) | (IData)(vlTOPp->memory__DOT____Vcellout__bank0__dout));
    vlTOPp->dout = ((0xffff00ffU & vlTOPp->dout) | 
                    ((IData)(vlTOPp->memory__DOT____Vcellout__bank1__dout) 
                     << 8U));
    vlTOPp->dout = ((0xff00ffffU & vlTOPp->dout) | 
                    ((IData)(vlTOPp->memory__DOT____Vcellout__bank2__dout) 
                     << 0x10U));
    vlTOPp->dout = ((0xffffffU & vlTOPp->dout) | ((IData)(vlTOPp->memory__DOT____Vcellout__bank3__dout) 
                                                  << 0x18U));
    vlTOPp->memory__DOT__s_wr = ((~ (IData)(vlTOPp->err)) 
                                 & (IData)(vlTOPp->wr));
    vlTOPp->memory__DOT__s_rd = ((~ (IData)(vlTOPp->err)) 
                                 & (IData)(vlTOPp->rd));
}

VL_INLINE_OPT void Vmemory::_sequent__TOP__3(Vmemory__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_sequent__TOP__3\n"); );
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    CData/*7:0*/ __Vdlyvval__memory__DOT__bank0__DOT__mem__v0;
    CData/*0:0*/ __Vdlyvset__memory__DOT__bank0__DOT__mem__v0;
    CData/*7:0*/ __Vdlyvval__memory__DOT__bank1__DOT__mem__v0;
    CData/*0:0*/ __Vdlyvset__memory__DOT__bank1__DOT__mem__v0;
    CData/*7:0*/ __Vdlyvval__memory__DOT__bank2__DOT__mem__v0;
    CData/*0:0*/ __Vdlyvset__memory__DOT__bank2__DOT__mem__v0;
    CData/*7:0*/ __Vdlyvval__memory__DOT__bank3__DOT__mem__v0;
    CData/*0:0*/ __Vdlyvset__memory__DOT__bank3__DOT__mem__v0;
    SData/*13:0*/ __Vdlyvdim0__memory__DOT__bank0__DOT__mem__v0;
    SData/*13:0*/ __Vdlyvdim0__memory__DOT__bank1__DOT__mem__v0;
    SData/*13:0*/ __Vdlyvdim0__memory__DOT__bank2__DOT__mem__v0;
    SData/*13:0*/ __Vdlyvdim0__memory__DOT__bank3__DOT__mem__v0;
    // Body
    __Vdlyvset__memory__DOT__bank3__DOT__mem__v0 = 0U;
    __Vdlyvset__memory__DOT__bank2__DOT__mem__v0 = 0U;
    __Vdlyvset__memory__DOT__bank1__DOT__mem__v0 = 0U;
    __Vdlyvset__memory__DOT__bank0__DOT__mem__v0 = 0U;
    if ((1U & (~ (IData)(vlTOPp->memory__DOT__s_rd)))) {
        if (vlTOPp->memory__DOT__s_wr) {
            __Vdlyvval__memory__DOT__bank3__DOT__mem__v0 
                = (0xffU & (vlTOPp->din >> 0x18U));
            __Vdlyvset__memory__DOT__bank3__DOT__mem__v0 = 1U;
            __Vdlyvdim0__memory__DOT__bank3__DOT__mem__v0 
                = vlTOPp->addr;
        }
    }
    if ((1U & (~ (IData)(vlTOPp->memory__DOT__s_rd)))) {
        if (vlTOPp->memory__DOT__s_wr) {
            __Vdlyvval__memory__DOT__bank2__DOT__mem__v0 
                = (0xffU & (vlTOPp->din >> 0x10U));
            __Vdlyvset__memory__DOT__bank2__DOT__mem__v0 = 1U;
            __Vdlyvdim0__memory__DOT__bank2__DOT__mem__v0 
                = vlTOPp->addr;
        }
    }
    if ((1U & (~ (IData)(vlTOPp->memory__DOT__s_rd)))) {
        if (vlTOPp->memory__DOT__s_wr) {
            __Vdlyvval__memory__DOT__bank1__DOT__mem__v0 
                = (0xffU & (vlTOPp->din >> 8U));
            __Vdlyvset__memory__DOT__bank1__DOT__mem__v0 = 1U;
            __Vdlyvdim0__memory__DOT__bank1__DOT__mem__v0 
                = vlTOPp->addr;
        }
    }
    if ((1U & (~ (IData)(vlTOPp->memory__DOT__s_rd)))) {
        if (vlTOPp->memory__DOT__s_wr) {
            __Vdlyvval__memory__DOT__bank0__DOT__mem__v0 
                = (0xffU & vlTOPp->din);
            __Vdlyvset__memory__DOT__bank0__DOT__mem__v0 = 1U;
            __Vdlyvdim0__memory__DOT__bank0__DOT__mem__v0 
                = vlTOPp->addr;
        }
    }
    if (vlTOPp->memory__DOT__s_rd) {
        vlTOPp->memory__DOT____Vcellout__bank3__dout 
            = vlTOPp->memory__DOT__bank3__DOT__mem[vlTOPp->addr];
    }
    if (vlTOPp->memory__DOT__s_rd) {
        vlTOPp->memory__DOT____Vcellout__bank2__dout 
            = vlTOPp->memory__DOT__bank2__DOT__mem[vlTOPp->addr];
    }
    if (vlTOPp->memory__DOT__s_rd) {
        vlTOPp->memory__DOT____Vcellout__bank1__dout 
            = vlTOPp->memory__DOT__bank1__DOT__mem[vlTOPp->addr];
    }
    if (vlTOPp->memory__DOT__s_rd) {
        vlTOPp->memory__DOT____Vcellout__bank0__dout 
            = vlTOPp->memory__DOT__bank0__DOT__mem[vlTOPp->addr];
    }
    if (__Vdlyvset__memory__DOT__bank3__DOT__mem__v0) {
        vlTOPp->memory__DOT__bank3__DOT__mem[__Vdlyvdim0__memory__DOT__bank3__DOT__mem__v0] 
            = __Vdlyvval__memory__DOT__bank3__DOT__mem__v0;
    }
    if (__Vdlyvset__memory__DOT__bank2__DOT__mem__v0) {
        vlTOPp->memory__DOT__bank2__DOT__mem[__Vdlyvdim0__memory__DOT__bank2__DOT__mem__v0] 
            = __Vdlyvval__memory__DOT__bank2__DOT__mem__v0;
    }
    if (__Vdlyvset__memory__DOT__bank1__DOT__mem__v0) {
        vlTOPp->memory__DOT__bank1__DOT__mem[__Vdlyvdim0__memory__DOT__bank1__DOT__mem__v0] 
            = __Vdlyvval__memory__DOT__bank1__DOT__mem__v0;
    }
    if (__Vdlyvset__memory__DOT__bank0__DOT__mem__v0) {
        vlTOPp->memory__DOT__bank0__DOT__mem[__Vdlyvdim0__memory__DOT__bank0__DOT__mem__v0] 
            = __Vdlyvval__memory__DOT__bank0__DOT__mem__v0;
    }
    vlTOPp->dout = ((0xffffffU & vlTOPp->dout) | ((IData)(vlTOPp->memory__DOT____Vcellout__bank3__dout) 
                                                  << 0x18U));
    vlTOPp->dout = ((0xff00ffffU & vlTOPp->dout) | 
                    ((IData)(vlTOPp->memory__DOT____Vcellout__bank2__dout) 
                     << 0x10U));
    vlTOPp->dout = ((0xffff00ffU & vlTOPp->dout) | 
                    ((IData)(vlTOPp->memory__DOT____Vcellout__bank1__dout) 
                     << 8U));
    vlTOPp->dout = ((0xffffff00U & vlTOPp->dout) | (IData)(vlTOPp->memory__DOT____Vcellout__bank0__dout));
}

VL_INLINE_OPT void Vmemory::_combo__TOP__4(Vmemory__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_combo__TOP__4\n"); );
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->memory__DOT__s_wr = ((~ (IData)(vlTOPp->err)) 
                                 & (IData)(vlTOPp->wr));
    vlTOPp->memory__DOT__s_rd = ((~ (IData)(vlTOPp->err)) 
                                 & (IData)(vlTOPp->rd));
}

void Vmemory::_eval(Vmemory__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_eval\n"); );
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
        vlTOPp->_sequent__TOP__3(vlSymsp);
    }
    vlTOPp->_combo__TOP__4(vlSymsp);
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

void Vmemory::_eval_initial(Vmemory__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_eval_initial\n"); );
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

void Vmemory::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::final\n"); );
    // Variables
    Vmemory__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vmemory::_eval_settle(Vmemory__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_eval_settle\n"); );
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__2(vlSymsp);
}

VL_INLINE_OPT QData Vmemory::_change_request(Vmemory__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_change_request\n"); );
    Vmemory* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vmemory::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((rd & 0xfeU))) {
        Verilated::overWidthError("rd");}
    if (VL_UNLIKELY((addr & 0xc000U))) {
        Verilated::overWidthError("addr");}
    if (VL_UNLIKELY((wr & 0xfeU))) {
        Verilated::overWidthError("wr");}
    if (VL_UNLIKELY((size & 0xfcU))) {
        Verilated::overWidthError("size");}
    if (VL_UNLIKELY((sign & 0xfeU))) {
        Verilated::overWidthError("sign");}
}
#endif  // VL_DEBUG

void Vmemory::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmemory::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    rd = VL_RAND_RESET_I(1);
    addr = VL_RAND_RESET_I(14);
    dout = VL_RAND_RESET_I(32);
    wr = VL_RAND_RESET_I(1);
    din = VL_RAND_RESET_I(32);
    size = VL_RAND_RESET_I(2);
    sign = VL_RAND_RESET_I(1);
    err = VL_RAND_RESET_I(1);
    memory__DOT__s_rd = VL_RAND_RESET_I(1);
    memory__DOT__s_wr = VL_RAND_RESET_I(1);
    memory__DOT____Vcellout__bank0__dout = VL_RAND_RESET_I(8);
    memory__DOT____Vcellout__bank1__dout = VL_RAND_RESET_I(8);
    memory__DOT____Vcellout__bank2__dout = VL_RAND_RESET_I(8);
    memory__DOT____Vcellout__bank3__dout = VL_RAND_RESET_I(8);
    { int __Vi0=0; for (; __Vi0<16384; ++__Vi0) {
            memory__DOT__bank0__DOT__mem[__Vi0] = VL_RAND_RESET_I(8);
    }}
    { int __Vi0=0; for (; __Vi0<16384; ++__Vi0) {
            memory__DOT__bank1__DOT__mem[__Vi0] = VL_RAND_RESET_I(8);
    }}
    { int __Vi0=0; for (; __Vi0<16384; ++__Vi0) {
            memory__DOT__bank2__DOT__mem[__Vi0] = VL_RAND_RESET_I(8);
    }}
    { int __Vi0=0; for (; __Vi0<16384; ++__Vi0) {
            memory__DOT__bank3__DOT__mem[__Vi0] = VL_RAND_RESET_I(8);
    }}
}
