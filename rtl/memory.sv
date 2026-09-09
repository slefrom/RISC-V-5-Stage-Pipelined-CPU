import rv_pkg::*;

module memory (
  input  logic        clk,
  input  logic        rst_n,

  input  logic [31:0] ex_mem_alu_result,
  input  logic [31:0] ex_mem_write_data,
  input  logic [4:0]  ex_mem_rd_addr,
  input  logic [31:0] ex_mem_pc_plus4,
  input  logic [31:0] ex_mem_imm,
  input  control_signals_t ex_mem_ctrl,
  
  output logic        dmem_we,
  output logic        dmem_re,
  output logic [31:0] dmem_addr,
  output logic [31:0] dmem_wdata,
  output logic [2:0]  dmem_size,
  input  logic [31:0] dmem_rdata, 

  output logic [31:0] mem_result,
  output logic [31:0] mem_wb_alu_result,
  output logic [31:0] mem_wb_dmem_data,
  output logic [4:0]  mem_wb_rd_addr,
  output logic [31:0] mem_wb_pc_plus4,
  output logic [31:0] mem_wb_imm,
  output control_signals_t mem_wb_ctrl
);

  assign dmem_re    = ex_mem_ctrl.mem_read;
  assign dmem_we    = ex_mem_ctrl.mem_write;
  assign dmem_addr  = ex_mem_alu_result;
  assign dmem_wdata = ex_mem_write_data;
  assign dmem_size  = ex_mem_ctrl.mem_size;

  // Sign/Zero extension handling
  logic [31:0] formatted_rdata;
  logic [7:0]  byte_data;
  logic [15:0] half_data;

  always_comb begin
    case (ex_mem_alu_result[1:0])
        2'b00:   byte_data = dmem_rdata[7:0];
        2'b01:   byte_data = dmem_rdata[15:8];
        2'b10:   byte_data = dmem_rdata[23:16];
        2'b11:   byte_data = dmem_rdata[31:24];
        default: byte_data = 8'bx;
    endcase

    half_data = ex_mem_alu_result[1] ? dmem_rdata[31:16] : dmem_rdata[15:0];
end

  always_comb begin
    case (ex_mem_ctrl.mem_size)
      3'b000: formatted_rdata = {{24{byte_data[7]}}, byte_data}; // LB
      3'b001: formatted_rdata = {{16{half_data[15]}}, half_data}; // LH
      3'b010: formatted_rdata = dmem_rdata;                       // LW
      3'b100: formatted_rdata = {24'b0, byte_data};               // LBU
      3'b101: formatted_rdata = {16'b0, half_data};               // LHU
      default: formatted_rdata = dmem_rdata;
    endcase
  end

  // MEM-stage result mux (mirrors the WB mux) so that forwarding from MEM
  // sends the actual result for LUI (imm) and JAL/JALR (PC+4), not the ALU
  // output. result_src 2'b01 (loads) is covered by the load-use stall.
  always_comb begin
    case (ex_mem_ctrl.result_src)
      2'b10:   mem_result = ex_mem_pc_plus4;
      2'b11:   mem_result = ex_mem_imm;
      default: mem_result = ex_mem_alu_result;
    endcase
  end

  // MEM/WB Pipeline Reg
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem_wb_alu_result <= 0;
      mem_wb_dmem_data  <= 0;
      mem_wb_rd_addr    <= 0;
      mem_wb_pc_plus4   <= 0;
      mem_wb_imm        <= 0;
      mem_wb_ctrl       <= '0;
    end else begin
      mem_wb_alu_result <= ex_mem_alu_result;
      mem_wb_dmem_data  <= formatted_rdata;   
      mem_wb_rd_addr    <= ex_mem_rd_addr;
      mem_wb_pc_plus4   <= ex_mem_pc_plus4;
      mem_wb_imm        <= ex_mem_imm;
      mem_wb_ctrl       <= ex_mem_ctrl;
    end
  end

endmodule