#include <backends/cxxrtl/cxxrtl.h>

#if defined(CXXRTL_INCLUDE_CAPI_IMPL) || \
    defined(CXXRTL_INCLUDE_VCD_CAPI_IMPL)
#include <backends/cxxrtl/cxxrtl_capi.cc>
#endif

#if defined(CXXRTL_INCLUDE_VCD_CAPI_IMPL)
#include <backends/cxxrtl/cxxrtl_vcd_capi.cc>
#endif

using namespace cxxrtl_yosys;

namespace cxxrtl_design {

// \top: 1
// \src: prog_cntr.sv:23.1-39.10
struct p_prog__cntr : public module {
	// \src: prog_cntr.sv:28.25-28.30
	/*output*/ wire<32> p_count;
	// \src: prog_cntr.sv:27.24-27.28
	/*input*/ value<32> p_data;
	// \src: prog_cntr.sv:26.11-26.13
	/*input*/ value<1> p_ld;
	// \src: prog_cntr.sv:25.11-25.15
	/*input*/ value<1> p_rstn;
	// \src: prog_cntr.sv:24.11-24.14
	/*input*/ value<1> p_clk;
	value<1> prev_p_clk;
	bool posedge_p_clk() const {
		return !prev_p_clk.slice<0>().val() && p_clk.slice<0>().val();
	}
	p_prog__cntr() {}
	p_prog__cntr(adopt, p_prog__cntr other) {}

	void reset() override {
		*this = p_prog__cntr(adopt {}, std::move(*this));
	}

	bool eval() override;
	bool commit() override;

	void debug_eval();

	void debug_info(debug_items &items, std::string path = "") override;
}; // struct p_prog__cntr

bool p_prog__cntr::eval() {
	bool converged = true;
	bool posedge_p_clk = this->posedge_p_clk();
	// cells $procdff$9 $procmux$7 $eq$prog_cntr.sv:33$2 $procmux$4 $eq$prog_cntr.sv:35$3
	if (posedge_p_clk) {
		p_count.next = (eq_uu<1>(p_rstn, value<32>{0u}) ? value<32>{0u} : (eq_uu<1>(p_ld, value<32>{0x1u}) ? p_data : p_count.curr));
	}
	return converged;
}

bool p_prog__cntr::commit() {
	bool changed = false;
	if (p_count.commit()) changed = true;
	prev_p_clk = p_clk;
	return changed;
}

void p_prog__cntr::debug_eval() {
}

CXXRTL_EXTREMELY_COLD
void p_prog__cntr::debug_info(debug_items &items, std::string path) {
	assert(path.empty() || path[path.size() - 1] == ' ');
	items.add(path + "count", debug_item(p_count, 0, debug_item::OUTPUT|debug_item::DRIVEN_SYNC));
	items.add(path + "data", debug_item(p_data, 0, debug_item::INPUT|debug_item::UNDRIVEN));
	items.add(path + "ld", debug_item(p_ld, 0, debug_item::INPUT|debug_item::UNDRIVEN));
	items.add(path + "rstn", debug_item(p_rstn, 0, debug_item::INPUT|debug_item::UNDRIVEN));
	items.add(path + "clk", debug_item(p_clk, 0, debug_item::INPUT|debug_item::UNDRIVEN));
}

} // namespace cxxrtl_design

extern "C"
cxxrtl_toplevel cxxrtl_design_create() {
	return new _cxxrtl_toplevel { std::unique_ptr<cxxrtl_design::p_prog__cntr>(new cxxrtl_design::p_prog__cntr) };
}
