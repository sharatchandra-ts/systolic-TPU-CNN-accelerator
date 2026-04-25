`timescale 1ns/1ps

module bias_relu_tb;

    parameter COLS = 4;
    parameter ACC_WIDTH = 8;

    // Interface signals
    logic signed [ACC_WIDTH-1:0] conv_out [COLS];
    logic valid_in [COLS];
    logic [ACC_WIDTH-1:0] relu_out [COLS];
    logic valid_out [COLS];

    // Clock for stimulus timing
    logic clk = 0;
    always #5 clk = ~clk;

    // Instantiate the Unit Under Test (UUT)
    bias_relu #(
        .COLS(COLS),
        .ACC_WIDTH(ACC_WIDTH)
    ) uut (
        .conv_out(conv_out),
        .valid_in(valid_in),
        .relu_out(relu_out),
        .valid_out(valid_out)
    );

    // Test stimulus
    initial begin
        $display("Starting Bias + ReLU Test...");
        
        // Initialize inputs
        for (int i = 0; i < COLS; i++) begin
            conv_out[i] = 0;
            valid_in[i] = 0;
        end

        @(posedge clk);

        // Feed a 4x4 matrix (one row per cycle)
        // Row 0: Positive values
        conv_out = '{21'h0000A, 21'h00014, 21'h0001E, 21'h00028}; 
        valid_in = '{1, 1, 1, 1};
        @(posedge clk);
        display_results(0);

        // Row 1: Negative values (should result in 0 after ReLU)
        conv_out = '{-21'sd50, -21'sd100, -21'sd150, -21'sd200};
        @(posedge clk);
        display_results(1);

        // Row 2: Mixed values
        conv_out = '{21'sd500, -21'sd500, 21'sd10, -21'sd10};
        @(posedge clk);
        display_results(2);

        // Row 3: Small values
        conv_out = '{21'sd1, 21'sd2, 21'sd3, 21'sd4};
        @(posedge clk);
        display_results(3);

        $display("Test Complete.");
        $finish;
    end

    // Task to print the output row
    task display_results(int row_idx);
        $write("Row %0d Output: ", row_idx);
        for (int i = 0; i < COLS; i++) begin
            $write("%d ", relu_out[i]);
        end
        $display("");
    endtask

endmodule
