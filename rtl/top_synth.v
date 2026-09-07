
//----------------the synthesised file sv2v game me for asic flow (converted from sv to v)---------------------//

module alu (
	src_a,
	src_b,
	alu_sel,
	result
);
	reg _sv2v_0;
	input wire [31:0] src_a;
	input wire [31:0] src_b;
	input wire [3:0] alu_sel;
	output reg [31:0] result;
	always @(*) begin
		if (_sv2v_0)
			;
		case (alu_sel)
			4'b0000: result = src_a + src_b;
			4'b0001: result = src_a - src_b;
			4'b0010: result = src_a & src_b;
			4'b0011: result = src_a | src_b;
			4'b0100: result = src_a ^ src_b;
			4'b0101: result = src_a << src_b[4:0];
			4'b0110: result = src_a >> src_b[4:0];
			4'b0111: result = $signed(src_a) >>> src_b[4:0];
			4'b1000: result = ($signed(src_a) < $signed(src_b) ? 32'd1 : 32'd0);
			4'b1001: result = (src_a < src_b ? 32'd1 : 32'd0);
			default: result = 32'b00000000000000000000000000000000;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module decode (
	clk,
	rst_n,
	if_id_pc,
	if_id_pc_plus4,
	if_id_instr,
	we_w,
	rd_w,
	result_w,
	stall_d,
	flush_e,
	id_ex_pc,
	id_ex_pc_plus4,
	id_ex_rs1_data,
	id_ex_rs2_data,
	id_ex_imm,
	id_ex_rs1_addr,
	id_ex_rs2_addr,
	id_ex_rd_addr,
	id_ex_ctrl,
	id_ex_br_op
);
	reg _sv2v_0;
	input wire clk;
	input wire rst_n;
	input wire [31:0] if_id_pc;
	input wire [31:0] if_id_pc_plus4;
	input wire [31:0] if_id_instr;
	input wire we_w;
	input wire [4:0] rd_w;
	input wire [31:0] result_w;
	input wire stall_d;
	input wire flush_e;
	output reg [31:0] id_ex_pc;
	output reg [31:0] id_ex_pc_plus4;
	output reg [31:0] id_ex_rs1_data;
	output reg [31:0] id_ex_rs2_data;
	output reg [31:0] id_ex_imm;
	output reg [4:0] id_ex_rs1_addr;
	output reg [4:0] id_ex_rs2_addr;
	output reg [4:0] id_ex_rd_addr;
	output reg [16:0] id_ex_ctrl;
	output reg [2:0] id_ex_br_op;
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;
	assign opcode = if_id_instr[6:0];
	assign rd = if_id_instr[11:7];
	assign funct3 = if_id_instr[14:12];
	assign rs1 = if_id_instr[19:15];
	assign rs2 = if_id_instr[24:20];
	assign funct7 = if_id_instr[31:25];
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	regfile regfile(
		.clk(clk),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd_w),
		.wr_data(result_w),
		.wr_reg(we_w),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data)
	);
	reg [31:0] imm_ext;
	always @(*) begin
		if (_sv2v_0)
			;
		case (opcode)
			7'b0000011, 7'b0010011, 7'b1100111: imm_ext = {{20 {if_id_instr[31]}}, if_id_instr[31:20]};
			7'b0100011: imm_ext = {{20 {if_id_instr[31]}}, if_id_instr[31:25], if_id_instr[11:7]};
			7'b1100011: imm_ext = {{20 {if_id_instr[31]}}, if_id_instr[7], if_id_instr[30:25], if_id_instr[11:8], 1'b0};
			7'b1101111: imm_ext = {{12 {if_id_instr[31]}}, if_id_instr[19:12], if_id_instr[20], if_id_instr[30:21], 1'b0};
			7'b0110111, 7'b0010111: imm_ext = {if_id_instr[31:12], 12'b000000000000};
			default: imm_ext = 32'b00000000000000000000000000000000;
		endcase
	end
	reg [3:0] alu_ctrl;
	always @(*) begin
		if (_sv2v_0)
			;
		case (funct3)
			3'b000: alu_ctrl = ((opcode == 7'b0110011) && funct7[5] ? 4'b0001 : 4'b0000);
			3'b001: alu_ctrl = 4'b0101;
			3'b010: alu_ctrl = 4'b1000;
			3'b011: alu_ctrl = 4'b1001;
			3'b100: alu_ctrl = 4'b0100;
			3'b101: alu_ctrl = (funct7[5] ? 4'b0111 : 4'b0110);
			3'b110: alu_ctrl = 4'b0011;
			3'b111: alu_ctrl = 4'b0010;
			default: alu_ctrl = 4'b0000;
		endcase
	end
	reg [16:0] ctrl;
	always @(*) begin
		if (_sv2v_0)
			;
		ctrl = 1'sb0;
		ctrl[5-:4] = 4'b0000;
		case (opcode)
			7'b0110011: begin
				ctrl[16] = 1'b1;
				ctrl[5-:4] = alu_ctrl;
			end
			7'b0010011: begin
				ctrl[16] = 1'b1;
				ctrl[1] = 1'b1;
				ctrl[5-:4] = alu_ctrl;
			end
			7'b0000011: begin
				ctrl[16] = 1'b1;
				ctrl[12] = 1'b1;
				ctrl[1] = 1'b1;
				ctrl[15-:2] = 2'b01;
				ctrl[11-:3] = funct3;
			end
			7'b0100011: begin
				ctrl[13] = 1'b1;
				ctrl[1] = 1'b1;
				ctrl[11-:3] = funct3;
			end
			7'b1100011: ctrl[6] = 1'b1;
			7'b0110111: begin
				ctrl[16] = 1'b1;
				ctrl[15-:2] = 2'b11;
			end
			7'b0010111: begin
				ctrl[16] = 1'b1;
				ctrl[0] = 1'b1;
				ctrl[1] = 1'b1;
			end
			7'b1101111: begin
				ctrl[16] = 1'b1;
				ctrl[15-:2] = 2'b10;
				ctrl[8-:2] = 2'b01;
			end
			7'b1100111: begin
				ctrl[16] = 1'b1;
				ctrl[15-:2] = 2'b10;
				ctrl[1] = 1'b1;
				ctrl[8-:2] = 2'b10;
			end
		endcase
	end
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			id_ex_pc <= 32'b00000000000000000000000000000000;
			id_ex_pc_plus4 <= 32'b00000000000000000000000000000000;
			id_ex_rs1_data <= 32'b00000000000000000000000000000000;
			id_ex_rs2_data <= 32'b00000000000000000000000000000000;
			id_ex_imm <= 32'b00000000000000000000000000000000;
			id_ex_rs1_addr <= 5'b00000;
			id_ex_rs2_addr <= 5'b00000;
			id_ex_rd_addr <= 5'b00000;
			id_ex_ctrl <= 1'sb0;
			id_ex_br_op <= 3'b000;
		end
		else if (flush_e) begin
			id_ex_pc <= 32'b00000000000000000000000000000000;
			id_ex_pc_plus4 <= 32'b00000000000000000000000000000000;
			id_ex_rs1_data <= 32'b00000000000000000000000000000000;
			id_ex_rs2_data <= 32'b00000000000000000000000000000000;
			id_ex_imm <= 32'b00000000000000000000000000000000;
			id_ex_rs1_addr <= 5'b00000;
			id_ex_rs2_addr <= 5'b00000;
			id_ex_rd_addr <= 5'b00000;
			id_ex_ctrl <= 1'sb0;
			id_ex_br_op <= 3'b000;
		end
		else if (!stall_d) begin
			id_ex_pc <= if_id_pc;
			id_ex_pc_plus4 <= if_id_pc_plus4;
			id_ex_rs1_data <= rs1_data;
			id_ex_rs2_data <= rs2_data;
			id_ex_imm <= imm_ext;
			id_ex_rs1_addr <= rs1;
			id_ex_rs2_addr <= rs2;
			id_ex_rd_addr <= rd;
			id_ex_ctrl <= ctrl;
			id_ex_br_op <= funct3;
		end
	initial _sv2v_0 = 0;
endmodule
module execute (
	clk,
	rst_n,
	id_ex_pc,
	id_ex_pc_plus4,
	id_ex_rs1_data,
	id_ex_rs2_data,
	id_ex_imm,
	id_ex_rd_addr,
	id_ex_ctrl,
	id_ex_br_op,
	forward_a,
	forward_b,
	mem_wb_result,
	ex_mem_result,
	pc_src_e,
	pc_tgt_e,
	ex_mem_alu_result_out,
	ex_mem_write_data,
	ex_mem_rd_addr,
	ex_mem_pc_plus4,
	ex_mem_imm,
	ex_mem_ctrl
);
	reg _sv2v_0;
	input wire clk;
	input wire rst_n;
	input wire [31:0] id_ex_pc;
	input wire [31:0] id_ex_pc_plus4;
	input wire [31:0] id_ex_rs1_data;
	input wire [31:0] id_ex_rs2_data;
	input wire [31:0] id_ex_imm;
	input wire [4:0] id_ex_rd_addr;
	input wire [16:0] id_ex_ctrl;
	input wire [2:0] id_ex_br_op;
	input wire [1:0] forward_a;
	input wire [1:0] forward_b;
	input wire [31:0] mem_wb_result;
	input wire [31:0] ex_mem_result;
	output wire pc_src_e;
	output reg [31:0] pc_tgt_e;
	output reg [31:0] ex_mem_alu_result_out;
	output reg [31:0] ex_mem_write_data;
	output reg [4:0] ex_mem_rd_addr;
	output reg [31:0] ex_mem_pc_plus4;
	output reg [31:0] ex_mem_imm;
	output reg [16:0] ex_mem_ctrl;
	wire [31:0] src_a;
	wire [31:0] src_b;
	reg [31:0] frw_a;
	reg [31:0] frw_b;
	wire [31:0] alu_result;
	wire zero;
	wire lt;
	wire ltu;
	always @(*) begin
		if (_sv2v_0)
			;
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
	assign src_a = (id_ex_ctrl[0] ? id_ex_pc : frw_a);
	assign src_b = (id_ex_ctrl[1] ? id_ex_imm : frw_b);
	alu u_alu(
		.src_a(src_a),
		.src_b(src_b),
		.alu_sel(id_ex_ctrl[5-:4]),
		.result(alu_result)
	);
	assign zero = frw_a == frw_b;
	assign lt = $signed(frw_a) < $signed(frw_b);
	assign ltu = frw_a < frw_b;
	reg branch_taken;
	always @(*) begin
		if (_sv2v_0)
			;
		case (id_ex_br_op)
			3'b000: branch_taken = zero;
			3'b001: branch_taken = !zero;
			3'b100: branch_taken = lt;
			3'b101: branch_taken = !lt;
			3'b110: branch_taken = ltu;
			3'b111: branch_taken = !ltu;
			default: branch_taken = 1'b0;
		endcase
	end
	assign pc_src_e = (id_ex_ctrl[6] & branch_taken) | (id_ex_ctrl[8-:2] != 2'b00);
	always @(*) begin
		if (_sv2v_0)
			;
		if (id_ex_ctrl[8-:2] == 2'b10)
			pc_tgt_e = (frw_a + id_ex_imm) & ~32'h00000001;
		else
			pc_tgt_e = id_ex_pc + id_ex_imm;
	end
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			ex_mem_alu_result_out <= 0;
			ex_mem_write_data <= 0;
			ex_mem_rd_addr <= 0;
			ex_mem_pc_plus4 <= 0;
			ex_mem_imm <= 0;
			ex_mem_ctrl <= 1'sb0;
		end
		else begin
			ex_mem_alu_result_out <= alu_result;
			ex_mem_write_data <= frw_b;
			ex_mem_rd_addr <= id_ex_rd_addr;
			ex_mem_pc_plus4 <= id_ex_pc_plus4;
			ex_mem_imm <= id_ex_imm;
			ex_mem_ctrl <= id_ex_ctrl;
		end
	initial _sv2v_0 = 0;
endmodule
module fetch (
	clk,
	rst_n,
	stall_f,
	flush_d,
	pc_src_e,
	pc_tgt_e,
	imem_addr,
	imem_rdata,
	if_id_pc,
	if_id_pc_plus4,
	if_id_instr
);
	input wire clk;
	input wire rst_n;
	input wire stall_f;
	input wire flush_d;
	input wire pc_src_e;
	input wire [31:0] pc_tgt_e;
	output wire [31:0] imem_addr;
	input wire [31:0] imem_rdata;
	output reg [31:0] if_id_pc;
	output reg [31:0] if_id_pc_plus4;
	output reg [31:0] if_id_instr;
	reg [31:0] pc_f;
	wire [31:0] pc_next_f;
	wire [31:0] pc_plus4_f;
	assign pc_plus4_f = pc_f + 4;
	assign pc_next_f = (pc_src_e ? pc_tgt_e : pc_plus4_f);
	always @(posedge clk or negedge rst_n)
		if (!rst_n)
			pc_f <= 1'sb0;
		else if (!stall_f)
			pc_f <= pc_next_f;
	assign imem_addr = pc_f;
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			if_id_pc <= 0;
			if_id_pc_plus4 <= 0;
			if_id_instr <= 32'h00000013;
		end
		else if (flush_d) begin
			if_id_pc <= 0;
			if_id_pc_plus4 <= 0;
			if_id_instr <= 32'h00000013;
		end
		else if (!stall_f) begin
			if_id_pc <= pc_f;
			if_id_pc_plus4 <= pc_plus4_f;
			if_id_instr <= imem_rdata;
		end
endmodule
module forwarding_unit (
	rs1_e,
	rs2_e,
	rd_m,
	ctrl_m,
	rd_w,
	ctrl_w,
	forward_a,
	forward_b
);
	reg _sv2v_0;
	input wire [4:0] rs1_e;
	input wire [4:0] rs2_e;
	input wire [4:0] rd_m;
	input wire [16:0] ctrl_m;
	input wire [4:0] rd_w;
	input wire [16:0] ctrl_w;
	output reg [1:0] forward_a;
	output reg [1:0] forward_b;
	always @(*) begin
		if (_sv2v_0)
			;
		forward_a = 2'b00;
		forward_b = 2'b00;
		if ((ctrl_m[16] && (rd_m != 0)) && (rd_m == rs1_e))
			forward_a = 2'b10;
		else if ((ctrl_w[16] && (rd_w != 0)) && (rd_w == rs1_e))
			forward_a = 2'b01;
		if ((ctrl_m[16] && (rd_m != 0)) && (rd_m == rs2_e))
			forward_b = 2'b10;
		else if ((ctrl_w[16] && (rd_w != 0)) && (rd_w == rs2_e))
			forward_b = 2'b01;
	end
	initial _sv2v_0 = 0;
endmodule
module hazard_unit (
	rs1_d,
	rs2_d,
	uses_rs1_d,
	uses_rs2_d,
	rd_e,
	ctrl_e,
	pc_src_e,
	stall_f,
	stall_d,
	flush_d,
	flush_e
);
	input wire [4:0] rs1_d;
	input wire [4:0] rs2_d;
	input wire uses_rs1_d;
	input wire uses_rs2_d;
	input wire [4:0] rd_e;
	input wire [16:0] ctrl_e;
	input wire pc_src_e;
	output wire stall_f;
	output wire stall_d;
	output wire flush_d;
	output wire flush_e;
	wire lw_stall;
	assign lw_stall = (ctrl_e[12] && (rd_e != 5'b00000)) && ((uses_rs1_d && (rd_e == rs1_d)) || (uses_rs2_d && (rd_e == rs2_d)));
	assign stall_f = lw_stall & ~pc_src_e;
	assign stall_d = lw_stall & ~pc_src_e;
	assign flush_d = pc_src_e;
	assign flush_e = lw_stall | pc_src_e;
endmodule
module memory (
	clk,
	rst_n,
	ex_mem_alu_result,
	ex_mem_write_data,
	ex_mem_rd_addr,
	ex_mem_pc_plus4,
	ex_mem_imm,
	ex_mem_ctrl,
	dmem_we,
	dmem_re,
	dmem_addr,
	dmem_wdata,
	dmem_size,
	dmem_rdata,
	mem_result,
	mem_wb_alu_result,
	mem_wb_dmem_data,
	mem_wb_rd_addr,
	mem_wb_pc_plus4,
	mem_wb_imm,
	mem_wb_ctrl
);
	reg _sv2v_0;
	input wire clk;
	input wire rst_n;
	input wire [31:0] ex_mem_alu_result;
	input wire [31:0] ex_mem_write_data;
	input wire [4:0] ex_mem_rd_addr;
	input wire [31:0] ex_mem_pc_plus4;
	input wire [31:0] ex_mem_imm;
	input wire [16:0] ex_mem_ctrl;
	output wire dmem_we;
	output wire dmem_re;
	output wire [31:0] dmem_addr;
	output wire [31:0] dmem_wdata;
	output wire [2:0] dmem_size;
	input wire [31:0] dmem_rdata;
	output reg [31:0] mem_result;
	output reg [31:0] mem_wb_alu_result;
	output reg [31:0] mem_wb_dmem_data;
	output reg [4:0] mem_wb_rd_addr;
	output reg [31:0] mem_wb_pc_plus4;
	output reg [31:0] mem_wb_imm;
	output reg [16:0] mem_wb_ctrl;
	assign dmem_re = ex_mem_ctrl[12];
	assign dmem_we = ex_mem_ctrl[13];
	assign dmem_addr = ex_mem_alu_result;
	assign dmem_wdata = ex_mem_write_data;
	assign dmem_size = ex_mem_ctrl[11-:3];
	reg [31:0] formatted_rdata;
	reg [7:0] byte_data;
	reg [15:0] half_data;
	always @(*) begin
		if (_sv2v_0)
			;
		case (ex_mem_alu_result[1:0])
			2'b00: byte_data = dmem_rdata[7:0];
			2'b01: byte_data = dmem_rdata[15:8];
			2'b10: byte_data = dmem_rdata[23:16];
			2'b11: byte_data = dmem_rdata[31:24];
			default: byte_data = 8'bxxxxxxxx;
		endcase
		half_data = (ex_mem_alu_result[1] ? dmem_rdata[31:16] : dmem_rdata[15:0]);
	end
	always @(*) begin
		if (_sv2v_0)
			;
		case (ex_mem_ctrl[11-:3])
			3'b000: formatted_rdata = {{24 {byte_data[7]}}, byte_data};
			3'b001: formatted_rdata = {{16 {half_data[15]}}, half_data};
			3'b010: formatted_rdata = dmem_rdata;
			3'b100: formatted_rdata = {24'b000000000000000000000000, byte_data};
			3'b101: formatted_rdata = {16'b0000000000000000, half_data};
			default: formatted_rdata = dmem_rdata;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		case (ex_mem_ctrl[15-:2])
			2'b10: mem_result = ex_mem_pc_plus4;
			2'b11: mem_result = ex_mem_imm;
			default: mem_result = ex_mem_alu_result;
		endcase
	end
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			mem_wb_alu_result <= 0;
			mem_wb_dmem_data <= 0;
			mem_wb_rd_addr <= 0;
			mem_wb_pc_plus4 <= 0;
			mem_wb_imm <= 0;
			mem_wb_ctrl <= 1'sb0;
		end
		else begin
			mem_wb_alu_result <= ex_mem_alu_result;
			mem_wb_dmem_data <= formatted_rdata;
			mem_wb_rd_addr <= ex_mem_rd_addr;
			mem_wb_pc_plus4 <= ex_mem_pc_plus4;
			mem_wb_imm <= ex_mem_imm;
			mem_wb_ctrl <= ex_mem_ctrl;
		end
	initial _sv2v_0 = 0;
endmodule
module regfile (
	clk,
	rs1,
	rs2,
	rd,
	wr_data,
	wr_reg,
	rs1_data,
	rs2_data
);
	reg _sv2v_0;
	input wire clk;
	input wire [4:0] rs1;
	input wire [4:0] rs2;
	input wire [4:0] rd;
	input wire [31:0] wr_data;
	input wire wr_reg;
	output reg [31:0] rs1_data;
	output reg [31:0] rs2_data;
	reg [31:0] reg_file [31:0];
	always @(posedge clk)
		if (wr_reg && (rd != 5'b00000))
			reg_file[rd] <= wr_data;
	always @(*) begin
		if (_sv2v_0)
			;
		if (rs1 == 5'd0)
			rs1_data = 32'd0;
		else if (wr_reg && (rs1 == rd))
			rs1_data = wr_data;
		else
			rs1_data = reg_file[rs1];
		if (rs2 == 5'd0)
			rs2_data = 32'd0;
		else if (wr_reg && (rs2 == rd))
			rs2_data = wr_data;
		else
			rs2_data = reg_file[rs2];
	end
	initial _sv2v_0 = 0;
endmodule
module top (
	clk,
	rst_n,
	imem_addr,
	imem_rdata,
	dmem_we,
	dmem_re,
	dmem_addr,
	dmem_wdata,
	dmem_size,
	dmem_rdata
);
	input wire clk;
	input wire rst_n;
	output wire [31:0] imem_addr;
	input wire [31:0] imem_rdata;
	output wire dmem_we;
	output wire dmem_re;
	output wire [31:0] dmem_addr;
	output wire [31:0] dmem_wdata;
	output wire [2:0] dmem_size;
	input wire [31:0] dmem_rdata;
	wire [31:0] if_id_pc;
	wire [31:0] if_id_pc_plus4;
	wire [31:0] if_id_instr;
	wire [31:0] id_ex_pc;
	wire [31:0] id_ex_pc_plus4;
	wire [31:0] id_ex_rs1_data;
	wire [31:0] id_ex_rs2_data;
	wire [31:0] id_ex_imm;
	wire [4:0] id_ex_rs1_addr;
	wire [4:0] id_ex_rs2_addr;
	wire [4:0] id_ex_rd_addr;
	wire [16:0] id_ex_ctrl;
	wire [2:0] id_ex_br_op;
	wire [31:0] ex_mem_alu_result;
	wire [31:0] ex_mem_write_data;
	wire [31:0] ex_mem_pc_plus4;
	wire [31:0] ex_mem_imm;
	wire [4:0] ex_mem_rd_addr;
	wire [16:0] ex_mem_ctrl;
	wire [31:0] mem_wb_alu_result;
	wire [31:0] mem_wb_dmem_data;
	wire [31:0] mem_wb_pc_plus4;
	wire [31:0] mem_wb_imm;
	wire [4:0] mem_wb_rd_addr;
	wire [16:0] mem_wb_ctrl;
	wire stall_f;
	wire stall_d;
	wire stall_e;
	wire stall_m;
	wire flush_d;
	wire flush_e;
	wire [1:0] forward_a;
	wire [1:0] forward_b;
	wire [31:0] mem_result;
	wire pc_src_e;
	wire [31:0] pc_tgt_e;
	wire we_w;
	wire [4:0] rd_w;
	wire [31:0] result_w;
	fetch fetch(
		.clk(clk),
		.rst_n(rst_n),
		.stall_f(stall_f),
		.flush_d(flush_d),
		.pc_src_e(pc_src_e),
		.pc_tgt_e(pc_tgt_e),
		.imem_addr(imem_addr),
		.imem_rdata(imem_rdata),
		.if_id_pc(if_id_pc),
		.if_id_pc_plus4(if_id_pc_plus4),
		.if_id_instr(if_id_instr)
	);
	decode decode(
		.clk(clk),
		.rst_n(rst_n),
		.if_id_pc(if_id_pc),
		.if_id_pc_plus4(if_id_pc_plus4),
		.if_id_instr(if_id_instr),
		.we_w(we_w),
		.rd_w(rd_w),
		.result_w(result_w),
		.stall_d(stall_d),
		.flush_e(flush_e),
		.id_ex_pc(id_ex_pc),
		.id_ex_pc_plus4(id_ex_pc_plus4),
		.id_ex_rs1_data(id_ex_rs1_data),
		.id_ex_rs2_data(id_ex_rs2_data),
		.id_ex_imm(id_ex_imm),
		.id_ex_rs1_addr(id_ex_rs1_addr),
		.id_ex_rs2_addr(id_ex_rs2_addr),
		.id_ex_rd_addr(id_ex_rd_addr),
		.id_ex_ctrl(id_ex_ctrl),
		.id_ex_br_op(id_ex_br_op)
	);
	execute execute(
		.clk(clk),
		.rst_n(rst_n),
		.id_ex_pc(id_ex_pc),
		.id_ex_pc_plus4(id_ex_pc_plus4),
		.id_ex_rs1_data(id_ex_rs1_data),
		.id_ex_rs2_data(id_ex_rs2_data),
		.id_ex_imm(id_ex_imm),
		.id_ex_rd_addr(id_ex_rd_addr),
		.id_ex_ctrl(id_ex_ctrl),
		.id_ex_br_op(id_ex_br_op),
		.forward_a(forward_a),
		.forward_b(forward_b),
		.mem_wb_result(result_w),
		.ex_mem_result(mem_result),
		.pc_src_e(pc_src_e),
		.pc_tgt_e(pc_tgt_e),
		.ex_mem_alu_result_out(ex_mem_alu_result),
		.ex_mem_write_data(ex_mem_write_data),
		.ex_mem_rd_addr(ex_mem_rd_addr),
		.ex_mem_pc_plus4(ex_mem_pc_plus4),
		.ex_mem_imm(ex_mem_imm),
		.ex_mem_ctrl(ex_mem_ctrl)
	);
	memory memory(
		.clk(clk),
		.rst_n(rst_n),
		.ex_mem_alu_result(ex_mem_alu_result),
		.ex_mem_write_data(ex_mem_write_data),
		.ex_mem_rd_addr(ex_mem_rd_addr),
		.ex_mem_pc_plus4(ex_mem_pc_plus4),
		.ex_mem_imm(ex_mem_imm),
		.ex_mem_ctrl(ex_mem_ctrl),
		.dmem_we(dmem_we),
		.dmem_re(dmem_re),
		.dmem_addr(dmem_addr),
		.dmem_wdata(dmem_wdata),
		.dmem_size(dmem_size),
		.dmem_rdata(dmem_rdata),
		.mem_result(mem_result),
		.mem_wb_alu_result(mem_wb_alu_result),
		.mem_wb_dmem_data(mem_wb_dmem_data),
		.mem_wb_rd_addr(mem_wb_rd_addr),
		.mem_wb_pc_plus4(mem_wb_pc_plus4),
		.mem_wb_imm(mem_wb_imm),
		.mem_wb_ctrl(mem_wb_ctrl)
	);
	writeback writeback(
		.mem_wb_alu_result(mem_wb_alu_result),
		.mem_wb_dmem_data(mem_wb_dmem_data),
		.mem_wb_pc_plus4(mem_wb_pc_plus4),
		.mem_wb_imm(mem_wb_imm),
		.mem_wb_rd_addr(mem_wb_rd_addr),
		.mem_wb_ctrl(mem_wb_ctrl),
		.we_w(we_w),
		.rd_w(rd_w),
		.result_w(result_w)
	);
	wire [6:0] opcode_d;
	wire uses_rs1_d;
	wire uses_rs2_d;
	assign opcode_d = if_id_instr[6:0];
	assign uses_rs1_d = ((opcode_d != 7'b0110111) && (opcode_d != 7'b0010111)) && (opcode_d != 7'b1101111);
	assign uses_rs2_d = ((opcode_d == 7'b0110011) || (opcode_d == 7'b1100011)) || (opcode_d == 7'b0100011);
	hazard_unit hazard_unit(
		.rs1_d(if_id_instr[19:15]),
		.rs2_d(if_id_instr[24:20]),
		.rd_e(id_ex_rd_addr),
		.ctrl_e(id_ex_ctrl),
		.pc_src_e(pc_src_e),
		.uses_rs1_d(uses_rs1_d),
		.uses_rs2_d(uses_rs2_d),
		.stall_f(stall_f),
		.stall_d(stall_d),
		.flush_d(flush_d),
		.flush_e(flush_e)
	);
	forwarding_unit forwarding_unit(
		.rs1_e(id_ex_rs1_addr),
		.rs2_e(id_ex_rs2_addr),
		.rd_m(ex_mem_rd_addr),
		.ctrl_m(ex_mem_ctrl),
		.rd_w(mem_wb_rd_addr),
		.ctrl_w(mem_wb_ctrl),
		.forward_a(forward_a),
		.forward_b(forward_b)
	);
endmodule
module writeback (
	mem_wb_alu_result,
	mem_wb_dmem_data,
	mem_wb_pc_plus4,
	mem_wb_imm,
	mem_wb_rd_addr,
	mem_wb_ctrl,
	we_w,
	rd_w,
	result_w
);
	reg _sv2v_0;
	input wire [31:0] mem_wb_alu_result;
	input wire [31:0] mem_wb_dmem_data;
	input wire [31:0] mem_wb_pc_plus4;
	input wire [31:0] mem_wb_imm;
	input wire [4:0] mem_wb_rd_addr;
	input wire [16:0] mem_wb_ctrl;
	output wire we_w;
	output wire [4:0] rd_w;
	output reg [31:0] result_w;
	assign we_w = mem_wb_ctrl[16];
	assign rd_w = mem_wb_rd_addr;
	always @(*) begin
		if (_sv2v_0)
			;
		case (mem_wb_ctrl[15-:2])
			2'b00: result_w = mem_wb_alu_result;
			2'b01: result_w = mem_wb_dmem_data;
			2'b10: result_w = mem_wb_pc_plus4;
			2'b11: result_w = mem_wb_imm;
			default: result_w = mem_wb_alu_result;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule