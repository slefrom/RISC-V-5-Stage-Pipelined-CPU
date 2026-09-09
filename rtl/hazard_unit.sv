import rv_pkg::*;

module hazard_unit (
  input  logic [4:0]        rs1_d,
  input  logic [4:0]        rs2_d,
  input  logic              uses_rs1_d, // to prevent false stalls if instuctions dont read rs1 or rs2
  input  logic              uses_rs2_d, 
  input  logic [4:0]        rd_e,
  input  control_signals_t  ctrl_e,
  input  logic              pc_src_e,   // branch taken / jump in EX

  output logic              stall_f,
  output logic              stall_d,
  output logic              flush_d,
  output logic              flush_e
);

  logic lw_stall;

  // Only stall if the instruction in ID actually reads the register
  assign lw_stall = ctrl_e.mem_read && (rd_e != 5'b0) && ((uses_rs1_d && (rd_e == rs1_d)) || (uses_rs2_d && (rd_e == rs2_d)));

  // Taken branches/jumps override stalls completely
  assign stall_f = lw_stall & ~pc_src_e;
  assign stall_d = lw_stall & ~pc_src_e;
  assign flush_d = pc_src_e;
  assign flush_e = lw_stall | pc_src_e;

endmodule