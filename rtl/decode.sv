import rv_pkg::*;

module decode (
  input  logic                    clk,
  input  logic                    rst_n,

  // From Fetch (IF/ID Pipeline Register)
  input  logic [31:0]             if_id_pc,
  input  logic [31:0]             if_id_pc_plus4,
  input  logic [31:0]             if_id_instr,

  // From Writeback
  input  logic                    we_w,
  input  logic [4:0]              rd_w,
  input  logic [31:0]             result_w,

  // Hazard Control
  input  logic                    stall_d,
  input  logic                    flush_e,

  // ID/EX Pipeline Register Outputs
  output logic [31:0]             id_ex_pc,
  output logic [31:0]             id_ex_pc_plus4,
  output logic [31:0]             id_ex_rs1_data,
  output logic [31:0]             id_ex_rs2_data,
  output logic [31:0]             id_ex_imm,
  output logic [4:0]              id_ex_rs1_addr,
  output logic [4:0]              id_ex_rs2_addr,
  output logic [4:0]              id_ex_rd_addr,
  output control_signals_t        id_ex_ctrl,
  output branch_op_t              id_ex_br_op
);

  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [4:0] rs1, rs2, rd;

  assign opcode = if_id_instr[6:0];
  assign rd     = if_id_instr[11:7];
  assign funct3 = if_id_instr[14:12];
  assign rs1    = if_id_instr[19:15];
  assign rs2    = if_id_instr[24:20];
  assign funct7 = if_id_instr[31:25];

  logic [31:0] rs1_data, rs2_data;

  regfile regfile (
    .clk      (clk),
    .rs1      (rs1),
    .rs2      (rs2),
    .rd       (rd_w),
    .wr_data  (result_w),
    .wr_reg   (we_w),
    .rs1_data (rs1_data),
    .rs2_data (rs2_data)
  );

// Immediate Gen Unit
  logic [31:0] imm_ext;

  always_comb begin
    case (opcode)
      OP_LOAD, OP_OP_IMM, OP_JALR: imm_ext = {{20{if_id_instr[31]}}, if_id_instr[31:20]};
      OP_STORE:  imm_ext = {{20{if_id_instr[31]}}, if_id_instr[31:25], if_id_instr[11:7]};
      OP_BRANCH: imm_ext = {{20{if_id_instr[31]}}, if_id_instr[7],     if_id_instr[30:25], if_id_instr[11:8], 1'b0};
      OP_JAL: imm_ext = {{12{if_id_instr[31]}}, if_id_instr[19:12], if_id_instr[20],   if_id_instr[30:21], 1'b0};
      OP_LUI, OP_AUIPC:  imm_ext = {if_id_instr[31:12], 12'b0};
      default:imm_ext = 32'b0;
    endcase
  end

// ALU Decoder
  alu_op_t alu_ctrl;

  always_comb begin
    case (funct3)
      3'b000:  alu_ctrl = (opcode == OP_OP && funct7[5]) ? ALU_SUB : ALU_ADD;
      3'b001:  alu_ctrl = ALU_SLL;
      3'b010:  alu_ctrl = ALU_SLT;
      3'b011:  alu_ctrl = ALU_SLTU;
      3'b100:  alu_ctrl = ALU_XOR;
      3'b101:  alu_ctrl = (funct7[5]) ? ALU_SRA : ALU_SRL;
      3'b110:  alu_ctrl = ALU_OR;
      3'b111:  alu_ctrl = ALU_AND;
      default: alu_ctrl = ALU_ADD;
    endcase
  end

  // Main Control Unit
  control_signals_t ctrl;

  always_comb begin
    ctrl             = '0;
    ctrl.alu_control = ALU_ADD;

    case (opcode)
      OP_OP: begin
        ctrl.reg_write   = 1'b1;
        ctrl.alu_control = alu_ctrl;
      end

      OP_OP_IMM: begin
        ctrl.reg_write   = 1'b1;
        ctrl.alu_src_b   = 1'b1;
        ctrl.alu_control = alu_ctrl;
      end

      OP_LOAD: begin
        ctrl.reg_write   = 1'b1;
        ctrl.mem_read    = 1'b1;
        ctrl.alu_src_b   = 1'b1;
        ctrl.result_src  = 2'b01;
        ctrl.mem_size    = funct3;
      end

      OP_STORE: begin
        ctrl.mem_write   = 1'b1;
        ctrl.alu_src_b   = 1'b1;
        ctrl.mem_size    = funct3;
      end

      OP_BRANCH: begin
        ctrl.branch      = 1'b1;
      end

      OP_LUI: begin
        ctrl.reg_write   = 1'b1;
        ctrl.result_src  = 2'b11; // Imm
      end

      OP_AUIPC: begin
        ctrl.reg_write   = 1'b1;
        ctrl.alu_src_a   = 1'b1; // PC
        ctrl.alu_src_b   = 1'b1; // Imm
      end

      OP_JAL: begin
        ctrl.reg_write   = 1'b1;
        ctrl.result_src  = 2'b10; // PC + 4
        ctrl.jump        = 2'b01;
      end

      OP_JALR: begin
        ctrl.reg_write   = 1'b1;
        ctrl.result_src  = 2'b10; // PC + 4
        ctrl.alu_src_b   = 1'b1;
        ctrl.jump        = 2'b10;
      end

    endcase
  end

  // ID/EX Pipeline Reg
always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin           //huge pain ugh why couldnt i have done if (!rst_n || flush_e) ????
      id_ex_pc       <= 32'b0;
      id_ex_pc_plus4 <= 32'b0;
      id_ex_rs1_data <= 32'b0;
      id_ex_rs2_data <= 32'b0;
      id_ex_imm      <= 32'b0;
      id_ex_rs1_addr <= 5'b0;
      id_ex_rs2_addr <= 5'b0;
      id_ex_rd_addr  <= 5'b0;
      id_ex_ctrl     <= '0;
      id_ex_br_op    <= BR_BEQ;
    end else if (flush_e) begin
      id_ex_pc       <= 32'b0;
      id_ex_pc_plus4 <= 32'b0;
      id_ex_rs1_data <= 32'b0;
      id_ex_rs2_data <= 32'b0;
      id_ex_imm      <= 32'b0;
      id_ex_rs1_addr <= 5'b0;
      id_ex_rs2_addr <= 5'b0;
      id_ex_rd_addr  <= 5'b0;
      id_ex_ctrl     <= '0;
      id_ex_br_op    <= BR_BEQ;
    end else if (!stall_d) begin
      id_ex_pc       <= if_id_pc;
      id_ex_pc_plus4 <= if_id_pc_plus4;
      id_ex_rs1_data <= rs1_data;
      id_ex_rs2_data <= rs2_data;
      id_ex_imm      <= imm_ext;
      id_ex_rs1_addr <= rs1;
      id_ex_rs2_addr <= rs2;
      id_ex_rd_addr  <= rd;
      id_ex_ctrl     <= ctrl;
      id_ex_br_op    <= branch_op_t'(funct3);
    end
  end

endmodule