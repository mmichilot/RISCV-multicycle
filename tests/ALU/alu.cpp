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
// \src: alu.sv:22.1-45.14
struct p_alu : public module {
	// \src: alu.sv:25.29-25.32
	/*output*/ value<32> p_out;
	// \src: alu.sv:24.24-24.25
	/*input*/ value<32> p_b;
	// \src: alu.sv:24.22-24.23
	/*input*/ value<32> p_a;
	// \src: alu.sv:23.21-23.23
	/*input*/ value<4> p_op;
	p_alu() {}
	p_alu(adopt, p_alu other) {}

	void reset() override {
		*this = p_alu(adopt {}, std::move(*this));
	}

	bool eval() override;
	bool commit() override;

	void debug_eval();

	void debug_info(debug_items &items, std::string path = "") override;
}; // struct p_alu

bool p_alu::eval() {
	bool converged = true;
	// cells $procmux$15 $procmux$16_CMP0 $procmux$17_CMP0 $procmux$18_CMP0 $procmux$19_CMP0 $procmux$20_CMP0 $procmux$21_CMP0 $procmux$22_CMP0 $procmux$23_CMP0 $procmux$24_CMP0 $procmux$25_CMP0 $procmux$26_CMP0 $ternary$alu.sv:40$13 $lt$alu.sv:40$12 $ternary$alu.sv:39$11 $lt$alu.sv:39$10 $sshr$alu.sv:38$9 $shl$alu.sv:37$8 $shr$alu.sv:36$7 $xor$alu.sv:35$6 $and$alu.sv:34$5 $or$alu.sv:33$4 $sub$alu.sv:32$3 $add$alu.sv:31$2
	p_out = (eq_uu<1>(p_op, value<4>{0x9u}) ? p_a : (eq_uu<1>(p_op, value<4>{0x3u}) ? (lt_uu<1>(p_a, p_b) ? value<32>{0x1u} : value<32>{0u}) : (eq_uu<1>(p_op, value<4>{0x2u}) ? (lt_ss<1>(p_a, p_b) ? value<32>{0x1u} : value<32>{0u}) : (eq_uu<1>(p_op, value<4>{0xdu}) ? sshr_su<32>(p_a, p_b.slice<4,0>().val()) : (eq_uu<1>(p_op, value<4>{0x1u}) ? shl_uu<32>(p_a, p_b.slice<4,0>().val()) : (eq_uu<1>(p_op, value<4>{0x5u}) ? shr_uu<32>(p_a, p_b.slice<4,0>().val()) : (eq_uu<1>(p_op, value<4>{0x4u}) ? xor_uu<32>(p_a, p_b) : (eq_uu<1>(p_op, value<4>{0x7u}) ? and_uu<32>(p_a, p_b) : (eq_uu<1>(p_op, value<4>{0x6u}) ? or_uu<32>(p_a, p_b) : (eq_uu<1>(p_op, value<4>{0x8u}) ? sub_uu<32>(p_a, p_b) : (eq_uu<1>(p_op, value<4>{0u}) ? add_uu<32>(p_a, p_b) : value<32>{0u})))))))))));
	return converged;
}

bool p_alu::commit() {
	bool changed = false;
	return changed;
}

void p_alu::debug_eval() {
}

CXXRTL_EXTREMELY_COLD
void p_alu::debug_info(debug_items &items, std::string path) {
	assert(path.empty() || path[path.size() - 1] == ' ');
	items.add(path + "out", debug_item(p_out, 0, debug_item::OUTPUT|debug_item::DRIVEN_COMB));
	items.add(path + "b", debug_item(p_b, 0, debug_item::INPUT|debug_item::UNDRIVEN));
	items.add(path + "a", debug_item(p_a, 0, debug_item::INPUT|debug_item::UNDRIVEN));
	items.add(path + "op", debug_item(p_op, 0, debug_item::INPUT|debug_item::UNDRIVEN));
}

} // namespace cxxrtl_design

extern "C"
cxxrtl_toplevel cxxrtl_design_create() {
	return new _cxxrtl_toplevel { std::unique_ptr<cxxrtl_design::p_alu>(new cxxrtl_design::p_alu) };
}
