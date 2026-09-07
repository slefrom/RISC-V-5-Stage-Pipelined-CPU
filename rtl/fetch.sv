module fetch (
  input  logic        clk,
  input  logic        rst_n,
  
  // Hazard control
  input  logic        stall_f,
  input  logic        flush_d,
  
  // Branch/Jump resolution from EX stage
  input  logic        pc_src_e,
  input  logic [31:0] pc_tgt_e,
  
  // Instruction Memory
  output logic [31:0] imem_addr,
  input  logic [31:0] imem_rdata,
  
  // IF/ID Pipeline Register Outputs
  output logic [31:0] if_id_pc,
  output logic [31:0] if_id_pc_plus4,
  output logic [31:0] if_id_instr
);

  logic [31:0] pc_f, pc_next_f, pc_plus4_f;

  assign pc_plus4_f = pc_f + 4;
  assign pc_next_f  = pc_src_e ? pc_tgt_e : pc_plus4_f;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_f <= '0; 
    end else if (!stall_f) begin
      pc_f <= pc_next_f;
    end
  end

  assign imem_addr = pc_f;

  // IF/ID Pipeline Reg
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    if_id_pc       <= 0;
    if_id_pc_plus4 <= 0;
    if_id_instr    <= 32'h00000013; // NOP (addi x0, x0, 0)
  end else begin
  if (flush_d) begin
      if_id_pc       <= 0;
      if_id_pc_plus4 <= 0;
      if_id_instr    <= 32'h00000013; 
  end else if (!stall_f) begin
      if_id_pc       <= pc_f;
      if_id_pc_plus4 <= pc_plus4_f;
      if_id_instr    <= imem_rdata;
    end
  end
end

endmodule

