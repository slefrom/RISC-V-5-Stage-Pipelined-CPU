import rv_pkg::*;

module forwarding_unit (
  // Source registers in EX stage
  input  logic [4:0] rs1_e,
  input  logic [4:0] rs2_e,
  
  // Destination register and control in MEM stage
  input  logic [4:0] rd_m,
  input  control_signals_t ctrl_m,
  
  // Destination register and control in WB stage
  input  logic [4:0] rd_w,
  input  control_signals_t ctrl_w,
  
  // Forwarding selectors
  output logic [1:0] forward_a,
  output logic [1:0] forward_b
);

  always_comb begin
    forward_a = 2'b00;
    forward_b = 2'b00;

    // fwd to alu_src_a
    if (ctrl_m.reg_write && (rd_m != 0) && (rd_m == rs1_e)) begin
      forward_a = 2'b10; // fwd from EX/MEM
    end else if (ctrl_w.reg_write && (rd_w != 0) && (rd_w == rs1_e)) begin
      forward_a = 2'b01; // fwd from MEM/WB
    end

    // same but for b
    if (ctrl_m.reg_write && (rd_m != 0) && (rd_m == rs2_e)) begin
      forward_b = 2'b10; 
    end else if (ctrl_w.reg_write && (rd_w != 0) && (rd_w == rs2_e)) begin
      forward_b = 2'b01; 
    end
  end

  

endmodule

