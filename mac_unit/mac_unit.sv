module mac_unit #(
	// 8bit data input
	parameter DATA_WIDTH = 8, 
	// Ment to accomodate overflow while multiplication and addition
	parameter ACC_WIDTH = 32
)(
	input logic clk,
	input logic rst_n,
	// To clear the accumulated sum
	input logic clear_in,
	output logic clear_out,
	// To check if the input data is ready to be sent to the MAC
	input logic w_valid_in,
	input logic a_valid_in,
	input logic acc_valid_in,


	output logic w_valid_out,
	output logic a_valid_out,
	output logic acc_valid_out,
	// First multiplication input
	input logic signed [DATA_WIDTH-1:0] a_in,
	output logic signed [DATA_WIDTH-1:0] a_out,
	// Enable loading of weights
	input logic load_en,
	// Second multiplication input
	input logic signed [DATA_WIDTH-1:0] w_in,
	output logic signed [DATA_WIDTH-1:0] w_out,
	// Accumulated addition input 
	input logic signed [ACC_WIDTH-1:0] acc_in,
	// Final output of accumulated sum
	output logic signed [ACC_WIDTH-1:0] acc_out
);
	logic signed [2*DATA_WIDTH-1:0] product;
	// Wight register
	logic signed [DATA_WIDTH-1:0] w_reg;

	// Use different product incase truncation issue occurs
	assign product = a_in * w_reg;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			clear_out <= 1'b0;
			a_out <= '0;
			w_out <= '0;
			acc_out <= '0;
			acc_valid_out <= 1'b0;
			w_valid_out <= 1'b0;
			a_valid_out <= 1'b0;

		end else begin
			if (load_en) begin
				// Capture for this PE
				w_reg <= w_in; 
				// Pass the SAME input down to the next PE in the same cycle
				w_out <= w_in; 
			end else begin
				// Keep passing if needed
				w_out <= w_reg; 
			end

			// Data always moves to the neighbor every cycle
			clear_out <= clear_in;
			a_valid_out <= a_valid_in;
			acc_valid_out <= acc_valid_in || a_valid_in;
			w_valid_out <= w_valid_in;
			a_out <= a_in;

			if (clear_in) acc_out <= '0;
            else if (a_valid_in) acc_out <= acc_in + ACC_WIDTH'(product);
            else acc_out <= acc_in;
	    end
	end
endmodule
