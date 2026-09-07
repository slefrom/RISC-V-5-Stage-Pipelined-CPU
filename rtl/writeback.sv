import rv_pkg::*;

module writeback (
  input  logic [31:0] mem_wb_alu_result,
  input  logic [31:0] mem_wb_dmem_data,
  input  logic [31:0] mem_wb_pc_plus4,
  input  logic [31:0] mem_wb_imm,
  input  logic [4:0]  mem_wb_rd_addr,
  input  control_signals_t mem_wb_ctrl,

  //  to ID (regfile)
  output logic        we_w,
  output logic [4:0]  rd_w,
  output logic [31:0] result_w
);

  assign we_w = mem_wb_ctrl.reg_write;
  assign rd_w = mem_wb_rd_addr;

  always_comb begin
    case (mem_wb_ctrl.result_src)
      2'b00: result_w = mem_wb_alu_result;
      2'b01: result_w = mem_wb_dmem_data; // From Data Memory
      2'b10: result_w = mem_wb_pc_plus4;  // For JAL/JALR
      2'b11: result_w = mem_wb_imm;       // For LUI
      default: result_w = mem_wb_alu_result;
    endcase
  end

endmodule