// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VMEMORY_H_
#define _VMEMORY_H_  // guard

#include "verilated.h"

//==========

class Vmemory__Syms;

//----------

VL_MODULE(Vmemory) {
  public:
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clk,0,0);
    VL_IN8(rd,0,0);
    VL_IN8(wr,0,0);
    VL_IN8(size,1,0);
    VL_IN8(sign,0,0);
    VL_OUT8(err,0,0);
    VL_IN16(addr,13,0);
    VL_OUT(dout,31,0);
    VL_IN(din,31,0);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    CData/*0:0*/ memory__DOT__s_rd;
    CData/*0:0*/ memory__DOT__s_wr;
    CData/*7:0*/ memory__DOT__bank0__DOT__mem[16384];
    CData/*7:0*/ memory__DOT__bank1__DOT__mem[16384];
    CData/*7:0*/ memory__DOT__bank2__DOT__mem[16384];
    CData/*7:0*/ memory__DOT__bank3__DOT__mem[16384];
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*7:0*/ memory__DOT____Vcellout__bank0__dout;
    CData/*7:0*/ memory__DOT____Vcellout__bank1__dout;
    CData/*7:0*/ memory__DOT____Vcellout__bank2__dout;
    CData/*7:0*/ memory__DOT____Vcellout__bank3__dout;
    CData/*0:0*/ __Vclklast__TOP__clk;
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vmemory__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vmemory);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    Vmemory(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vmemory();
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval();
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(Vmemory__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vmemory__Syms* symsp, bool first);
  private:
    static QData _change_request(Vmemory__Syms* __restrict vlSymsp);
  public:
    static void _combo__TOP__1(Vmemory__Syms* __restrict vlSymsp);
    static void _combo__TOP__4(Vmemory__Syms* __restrict vlSymsp);
  private:
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(Vmemory__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(Vmemory__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(Vmemory__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _sequent__TOP__3(Vmemory__Syms* __restrict vlSymsp);
    static void _settle__TOP__2(Vmemory__Syms* __restrict vlSymsp) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
