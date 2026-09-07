import rv_pkg::*;

module top (
  input  logic        clk,
  input  logic        rst_n,
  
  // Instruction Mem Interface
  output logic [31:0] imem_addr,
  input  logic [31:0] imem_rdata,
  output logic        dmem_we,
  output logic        dmem_re,
  output logic [31:0] dmem_addr,
  output logic [31:0] dmem_wdata,
  output logic [2:0]  dmem_size,
  input  logic [31:0] dmem_rdata
);

  // IF/ID Pipeline Reg Wires
  logic [31:0] if_id_pc, if_id_pc_plus4, if_id_instr;
  
  // ID/EX Pipeline Reg Wires
  logic [31:0] id_ex_pc, id_ex_pc_plus4, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
  logic [4:0]  id_ex_rs1_addr, id_ex_rs2_addr, id_ex_rd_addr;
  control_signals_t id_ex_ctrl;
  branch_op_t  id_ex_br_op;
  
  // EX/MEM Pipeline Reg Wires
  logic [31:0] ex_mem_alu_result, ex_mem_write_data, ex_mem_pc_plus4, ex_mem_imm;
  logic [4:0]  ex_mem_rd_addr;
  control_signals_t ex_mem_ctrl;
  
  // MEM/WB Pipeline Reg Wires
  logic [31:0] mem_wb_alu_result, mem_wb_dmem_data, mem_wb_pc_plus4, mem_wb_imm;
  logic [4:0]  mem_wb_rd_addr;
  control_signals_t mem_wb_ctrl;

  // Hazard + Forwarding Wires
  logic stall_f, stall_d, stall_e, stall_m, flush_d, flush_e;
  logic [1:0] forward_a, forward_b;
  logic [31:0] mem_result;
  logic pc_src_e;
  logic [31:0] pc_tgt_e;
  
  // Writeback Wires
  logic we_w;
  logic [4:0] rd_w;
  logic [31:0] result_w;
  
  fetch fetch (
    .clk(clk), .rst_n(rst_n),
    .stall_f(stall_f), .flush_d(flush_d),
    .pc_src_e(pc_src_e), .pc_tgt_e(pc_tgt_e),
    .imem_addr(imem_addr), .imem_rdata(imem_rdata),
    .if_id_pc(if_id_pc), .if_id_pc_plus4(if_id_pc_plus4), .if_id_instr(if_id_instr)
  );

  decode decode (
    .clk(clk), .rst_n(rst_n),
    .if_id_pc(if_id_pc), .if_id_pc_plus4(if_id_pc_plus4), .if_id_instr(if_id_instr),
    .we_w(we_w), .rd_w(rd_w), .result_w(result_w),
    .stall_d(stall_d), .flush_e(flush_e),
    .id_ex_pc(id_ex_pc), .id_ex_pc_plus4(id_ex_pc_plus4), 
    .id_ex_rs1_data(id_ex_rs1_data), .id_ex_rs2_data(id_ex_rs2_data), .id_ex_imm(id_ex_imm),
    .id_ex_rs1_addr(id_ex_rs1_addr), .id_ex_rs2_addr(id_ex_rs2_addr), .id_ex_rd_addr(id_ex_rd_addr),
    .id_ex_ctrl(id_ex_ctrl), .id_ex_br_op(id_ex_br_op)
  );

  execute execute (
    .clk(clk), .rst_n(rst_n),
    .id_ex_pc(id_ex_pc), .id_ex_pc_plus4(id_ex_pc_plus4),
    .id_ex_rs1_data(id_ex_rs1_data), .id_ex_rs2_data(id_ex_rs2_data), .id_ex_imm(id_ex_imm),
    .id_ex_rd_addr(id_ex_rd_addr), .id_ex_ctrl(id_ex_ctrl), .id_ex_br_op(id_ex_br_op),
    .forward_a(forward_a), .forward_b(forward_b),
    .mem_wb_result(result_w), .ex_mem_result(mem_result),
    .pc_src_e(pc_src_e), .pc_tgt_e(pc_tgt_e),
    .ex_mem_alu_result_out(ex_mem_alu_result), .ex_mem_write_data(ex_mem_write_data),
    .ex_mem_rd_addr(ex_mem_rd_addr), .ex_mem_pc_plus4(ex_mem_pc_plus4), .ex_mem_imm(ex_mem_imm),
    .ex_mem_ctrl(ex_mem_ctrl)
  );

  memory memory (
    .clk(clk), .rst_n(rst_n),
    .ex_mem_alu_result(ex_mem_alu_result), .ex_mem_write_data(ex_mem_write_data),
    .ex_mem_rd_addr(ex_mem_rd_addr), .ex_mem_pc_plus4(ex_mem_pc_plus4), .ex_mem_imm(ex_mem_imm),
    .ex_mem_ctrl(ex_mem_ctrl),
    .dmem_we(dmem_we), .dmem_re(dmem_re), .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata), .dmem_size(dmem_size),
    .dmem_rdata(dmem_rdata),
    .mem_result(mem_result),
    .mem_wb_alu_result(mem_wb_alu_result), .mem_wb_dmem_data(mem_wb_dmem_data),
    .mem_wb_rd_addr(mem_wb_rd_addr), .mem_wb_pc_plus4(mem_wb_pc_plus4), .mem_wb_imm(mem_wb_imm),
    .mem_wb_ctrl(mem_wb_ctrl)
  );

  writeback writeback(
    .mem_wb_alu_result(mem_wb_alu_result), .mem_wb_dmem_data(mem_wb_dmem_data),
    .mem_wb_pc_plus4(mem_wb_pc_plus4), .mem_wb_imm(mem_wb_imm),
    .mem_wb_rd_addr(mem_wb_rd_addr), .mem_wb_ctrl(mem_wb_ctrl),
    .we_w(we_w), .rd_w(rd_w), .result_w(result_w)
  );

  logic [6:0] opcode_d;
  logic uses_rs1_d;
  logic uses_rs2_d;

  assign opcode_d = if_id_instr[6:0];

  assign uses_rs1_d = (opcode_d != OP_LUI)  && (opcode_d != OP_AUIPC) && (opcode_d != OP_JAL);

  assign uses_rs2_d = (opcode_d == OP_OP) ||(opcode_d == OP_BRANCH) || (opcode_d == OP_STORE);

  hazard_unit hazard_unit (
    .rs1_d(if_id_instr[19:15]), .rs2_d(if_id_instr[24:20]),
    .rd_e(id_ex_rd_addr), .ctrl_e(id_ex_ctrl), .pc_src_e(pc_src_e), .uses_rs1_d (uses_rs1_d), .uses_rs2_d (uses_rs2_d),
    .stall_f(stall_f), .stall_d(stall_d), .flush_d(flush_d), .flush_e(flush_e)
  );

  forwarding_unit forwarding_unit (
    .rs1_e(id_ex_rs1_addr), .rs2_e(id_ex_rs2_addr),
    .rd_m(ex_mem_rd_addr), .ctrl_m(ex_mem_ctrl),
    .rd_w(mem_wb_rd_addr), .ctrl_w(mem_wb_ctrl),
    .forward_a(forward_a), .forward_b(forward_b)
  );

endmodule


