module mac_unit #(
	parameter DATA_WIDTH = 8, // 8bit data input
	parameter ACC_WIDTH = 32 // Ment to accomodate overflow while multiplication and addition
)(
	input logic clk,
	input logic reset,
	input logic signed [DATA_WIDTH-1:0] a_in, // First multiplication input
	input logic signed [DATA_WIDTH-1:0] b_in, // Second multiplication input 
	input logic signed [ACC_WIDTH-1:0] c_in, // Accumulated addition input 
	output logic signed [ACC_WIDTH-1:0] acc_out // Final output of accumulated sum
);
	
always_ff @(posedge clk or negedge reset) begin
	if (!reset) acc_out <= 0;
	// The MAC Operation: Multiply and Add
	// In a real FPGA, the compiler maps this to a DSP slice
	else begin
		acc_out <= (a_in * b_in) + c_in;
	end
end

endmodule
