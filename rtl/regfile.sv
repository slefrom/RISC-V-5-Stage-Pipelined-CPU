module regfile (
    input logic clk,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] wr_data,
    input logic wr_reg,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

logic [31:0] reg_file [31:0];

always_ff @(posedge clk) begin
if (wr_reg && rd != 5'b0) begin
        reg_file[rd] <= wr_data;
    end  
end

always_comb begin //internal forwarding
    if (rs1 == 5'd0) begin
        rs1_data = 32'd0;
    end else if (wr_reg && (rs1 == rd)) begin
        rs1_data = wr_data;
    end else begin
        rs1_data = reg_file[rs1];
    end

    if (rs2 == 5'd0) begin
        rs2_data = 32'd0;
    end else if (wr_reg && (rs2 == rd)) begin
        rs2_data = wr_data;
    end else begin
        rs2_data = reg_file[rs2];
    end
end


endmodule 
