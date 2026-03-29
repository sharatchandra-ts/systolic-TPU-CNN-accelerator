`timescale 1ns/1ps

module systolic_1d_tb;
    parameter N = 4;
    logic clk, rst_n, clear_in, valid_in;
    logic signed [7:0] a_in;
    logic signed [7:0] w_in [N];
    logic signed [31:0] result;
    logic valid_out_final;

    pe_array_1d_unit #(.N(N)) dut (.*);

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, systolic_1d_tb);
        
        // Setup Weights: [5, 6, 7, 8]
        w_in[0]=5; w_in[1]=6; w_in[2]=7; w_in[3]=8;
        a_in=0; clear_in=0; valid_in=0; rst_n=0;
        
        #20 rst_n = 1;
        
        // Start feeding vector [1, 2, 3, 4]
        @(posedge clk); a_in=1; valid_in=1;
        @(posedge clk); a_in=2;
        @(posedge clk); a_in=3;
        @(posedge clk); a_in=4;
        @(posedge clk); valid_in=0; a_in=0;

        // Wait for results to drain out of the pipeline (N cycles)
        repeat(N+1) @(posedge clk);
        
        $display("Final Result: %d", result); // Expected: (1*5)+(2*6)+(3*7)+(4*8) = 70
        $finish;
    end
endmodule
