package rv_pkg;


  typedef enum logic [6:0] {
    OP_LOAD   = 7'b000_0011,
    OP_STORE  = 7'b010_0011,
    OP_BRANCH = 7'b110_0011,
    OP_JALR   = 7'b110_0111,
    OP_JAL    = 7'b110_1111,
    OP_OP_IMM = 7'b001_0011,
    OP_OP     = 7'b011_0011,
    OP_LUI    = 7'b011_0111,
    OP_AUIPC  = 7'b001_0111,
    OP_SYSTEM = 7'b111_0011
  } opcode_t;


typedef enum logic [3:0] {
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_AND  = 4'b0010,
        ALU_OR   = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SLL  = 4'b0101,
        ALU_SRL  = 4'b0110,
        ALU_SRA  = 4'b0111,
        ALU_SLT  = 4'b1000,
        ALU_SLTU = 4'b1001
} alu_op_t;

  // funct3
  typedef enum logic [2:0] {
    BR_BEQ  = 3'b000,
    BR_BNE  = 3'b001,
    BR_BLT  = 3'b100,
    BR_BGE  = 3'b101,
    BR_BLTU = 3'b110,
    BR_BGEU = 3'b111
  } branch_op_t;

  typedef struct packed {
    logic       reg_write;
    logic [1:0] result_src; // 00: ALU, 01: DataMem, 10: PC+4 (for JAL/JALR), 11: Imm (LUI)
    logic       mem_write;
    logic       mem_read;
    logic [2:0] mem_size;   // funct3 for memory (LB, LH, LW, LBU, LHU, SB, SH, SW)
    logic [1:0] jump;       // 00: none, 01: JAL, 10: JALR
    logic       branch;
    alu_op_t    alu_control;
    logic       alu_src_b;  // 0: rs2, 1: imm
    logic       alu_src_a;  // 0: rs1, 1: PC (for AUIPC and JAL/branch address calc)
  } control_signals_t;


endpackage
