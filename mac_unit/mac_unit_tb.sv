`timescale 1ns/1ps

module mac_unit_tb;

    // 1. Parameters & Signals
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH = 32;

    logic clk;
    logic rst_n;
    logic signed [DATA_WIDTH-1:0] a_in;
    logic signed [DATA_WIDTH-1:0] b_in;
    logic signed [ACC_WIDTH-1:0]  c_in;
    logic signed [ACC_WIDTH-1:0]  acc_out;

    // 2. Instantiate the Device Under Test (DUT)
    // This connects your testbench wires to your MAC module
    mac_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .reset(rst_n),
        .a_in(a_in),
        .b_in(b_in),
        .c_in(c_in),
        .acc_out(acc_out)
    );

    // 3. Clock Generation (100MHz = 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. The Test Script
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, mac_unit_tb);

        // Initialize Inputs
        a_in = 0; b_in = 0; c_in = 0;
        rst_n = 0; // Hold reset

        // Wait 20ns, then release reset
        #20 rst_n = 1;

        // Test Case 1: Simple Positive Multiplication
        // (2 * 3) + 0 = 6
        @(posedge clk); // Wait for a clock edge
        a_in = 8'd2; b_in = 8'd3; c_in = 32'd0;
        
        // Test Case 2: Accumulation
        // (4 * 5) + 6 = 26
        @(posedge clk);
        a_in = 8'd4; b_in = 8'd5; c_in = acc_out; // Use previous result

        // Test Case 3: Signed (Negative) Math
        // (-2 * 3) + 26 = 20
        @(posedge clk);
        a_in = -8'd2; b_in = 8'd3; c_in = acc_out;

        // Observe results for a few more cycles
        repeat(5) @(posedge clk);

        $display("Test Complete. Final Result: %d", acc_out);
        $finish; // Stop the simulation
    end

endmodule
