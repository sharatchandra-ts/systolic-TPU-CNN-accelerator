module pe_array_1d_unit #(
	// Number of mac units in 1 array
	parameter N = 4,
	// 8bit data input
	parameter DATA_WIDTH = 8, 
	// Ment to accomodate overflow while multiplication and addition
	parameter ACC_WIDTH = 32 
)(
	input logic clk,
	input logic rst_n,
	input logic clear_in,
	input logic valid_in,
	input logic signed [DATA_WIDTH-1:0] a_in,
	input logic signed [DATA_WIDTH-1:0] w_in [N],
	output logic signed [ACC_WIDTH-1:0] result,
	output logic valid_out_final
);
	// Intermediate wires, which pass through each PE
	logic signed [DATA_WIDTH-1:0] a_wire [N+1];
	logic signed [ACC_WIDTH-1:0] acc_wire [N+1];
	logic valid_wire [N+1];
	logic clear_wire [N+1];


	// Entry points of each wire
	assign a_wire[0] = a_in;
	assign acc_wire[0] = 0;
	assign valid_wire[0] = valid_in;
	assign clear_wire[0] = clear_in;

	// Generate N MAC units at compile time
	genvar i;
	generate for (i = 0; i < N; i++) begin : pe_line
		mac_unit #(
			.DATA_WIDTH(DATA_WIDTH),
			.ACC_WIDTH(ACC_WIDTH)
			) pe_inst (
			.clk (clk),
			.rst_n (rst_n),
			.clear_in (clear_wire[i]),
			.clear_out (clear_wire[i+1]),
			.valid_in (valid_wire[i]),
			.valid_out (valid_wire[i+1]),
			.a_in (a_wire[i]),
			.a_out (a_wire[i+1]),
			.w_in (w_in[i]),
			.w_out (), // Not used in 1D, will use in 2D
			.acc_in (acc_wire[i]),
			.acc_out (acc_wire[i+1])
			);
	end 
	endgenerate

	// Final result of the wire
	assign result = acc_wire[N];
	assign valid_out_final = valid_wire[N]; 
endmodule
