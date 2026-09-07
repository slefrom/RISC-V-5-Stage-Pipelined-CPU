import rv_pkg::*;

module execute (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [31:0] id_ex_pc,
  input  logic [31:0] id_ex_pc_plus4,
  input  logic [31:0] id_ex_rs1_data,
  input  logic [31:0] id_ex_rs2_data,
  input  logic [31:0] id_ex_imm,
  input  logic [4:0]  id_ex_rd_addr,
  input  control_signals_t id_ex_ctrl,
  input  branch_op_t  id_ex_br_op,
  input  logic [1:0]  forward_a, // 00: ID/EX, 01: WB, 10: MEM
  input  logic [1:0]  forward_b, // 00: ID/EX, 01: WB, 10: MEM
  input  logic [31:0] mem_wb_result,
  input  logic [31:0] ex_mem_result,
  
  // Branch/Jump resolution to IF stage
  output logic        pc_src_e,
  output logic [31:0] pc_tgt_e,
  output logic [31:0] ex_mem_alu_result_out,
  output logic [31:0] ex_mem_write_data,
  output logic [4:0]  ex_mem_rd_addr,
  output logic [31:0] ex_mem_pc_plus4,
  output logic [31:0] ex_mem_imm,
  output control_signals_t ex_mem_ctrl
);

  logic [31:0] src_a, src_b, frw_a, frw_b;
  logic [31:0] alu_result;
  logic zero, lt, ltu;
  
  // Forwarding Muxes
  always_comb begin
    case (forward_a)
      2'b00: frw_a = id_ex_rs1_data;
      2'b01: frw_a = mem_wb_result;
      2'b10: frw_a = ex_mem_result; 
      default: frw_a = id_ex_rs1_data;
    endcase

    case (forward_b)
      2'b00: frw_b = id_ex_rs2_data;
      2'b01: frw_b = mem_wb_result;
      2'b10: frw_b = ex_mem_result; 
      default: frw_b = id_ex_rs2_data;
    endcase
  end

  assign src_a = (id_ex_ctrl.alu_src_a) ? id_ex_pc : frw_a;
  assign src_b = (id_ex_ctrl.alu_src_b) ? id_ex_imm : frw_b;

  alu u_alu (
    .src_a   (src_a),
    .src_b   (src_b),
    .alu_sel (id_ex_ctrl.alu_control),
    .result  (alu_result)
  );

  // Branch Comparator
  assign zero = (frw_a == frw_b);
  assign lt   = ($signed(frw_a) < $signed(frw_b));
  assign ltu  = (frw_a < frw_b);

  logic branch_taken;
  always_comb begin
    case (id_ex_br_op)
      BR_BEQ:  branch_taken = zero;
      BR_BNE:  branch_taken = !zero;
      BR_BLT:  branch_taken = lt;
      BR_BGE:  branch_taken = !lt;
      BR_BLTU: branch_taken = ltu;
      BR_BGEU: branch_taken = !ltu;
      default: branch_taken = 1'b0;
    endcase
  end

  // Branch + Jump Resolution
  assign pc_src_e = (id_ex_ctrl.branch & branch_taken) | (id_ex_ctrl.jump != 2'b00);
  
  always_comb begin
    if (id_ex_ctrl.jump == 2'b10) begin // JALR
      pc_tgt_e = (frw_a + id_ex_imm) & ~32'h1; // Set LSB to 0
    end else begin // Branch or JAL
      pc_tgt_e = id_ex_pc + id_ex_imm;
    end
  end

  // EX/MEM Pipeline Reg
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ex_mem_alu_result_out <= 0;
      ex_mem_write_data     <= 0;
      ex_mem_rd_addr        <= 0;
      ex_mem_pc_plus4       <= 0;
      ex_mem_imm            <= 0;
      ex_mem_ctrl           <= '0;
    end else begin
      ex_mem_alu_result_out <= alu_result;
      ex_mem_write_data     <= frw_b; 
      ex_mem_rd_addr        <= id_ex_rd_addr;
      ex_mem_pc_plus4       <= id_ex_pc_plus4;
      ex_mem_imm            <= id_ex_imm;
      ex_mem_ctrl           <= id_ex_ctrl;
    end
  end

endmodule