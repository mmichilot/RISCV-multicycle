#include <verilated_fst_c.h>

/**
 * Adapted from ZipCPU
 * https://zipcpu.com/blog/2017/06/21/looking-at-verilator.html
 */
template<class MODULE> class TESTBENCH {
public:
    uint64_t m_time_ps;
    std::unique_ptr<MODULE> m_soc;
    std::unique_ptr<VerilatedFstC> m_trace;

    TESTBENCH(void) {
        m_soc = std::unique_ptr<MODULE>(new MODULE);
        m_time_ps = 0ul;

    }

    virtual ~TESTBENCH(void) {
        if (m_trace) m_trace->close();
        m_soc->final();
    }

    virtual void reset(void) {
        m_soc->rst_n = 0;
        // Make sure any inheritance gets applied
        this->tick();
        m_soc->rst_n = 1;
    }

    virtual void tick(void) {
        // Make sure any combinatorial logic depending upon
        // inputs that may have changed before we called tick()
        // has settled before the rising edge of the clock.
        m_soc->eval();
        if (m_trace) m_trace->dump(m_time_ps+2500);

        // Rising edge
        m_time_ps += 5000;
        m_soc->clk = 1;
        m_soc->eval();
        if (m_trace) {
            m_trace->dump(m_time_ps);
            m_trace->flush();
        }

        // Falling edge
        m_time_ps += 5000;
        m_soc->clk = 0;
        m_soc->eval();
        if (m_trace) m_trace->dump(m_time_ps);
    }

    virtual void trace(const char* vcdname, int depth = 99) {
        if (!m_trace) {
            m_trace = std::unique_ptr<VerilatedFstC>(new VerilatedFstC);
            m_soc->trace(m_trace.get(), 99);
            m_trace->spTrace()->set_time_resolution("ps");
            m_trace->spTrace()->set_time_unit("ps");
            m_trace->open(vcdname);
        }
    }

    virtual bool done(void) { return (Verilated::gotFinish()); }
};