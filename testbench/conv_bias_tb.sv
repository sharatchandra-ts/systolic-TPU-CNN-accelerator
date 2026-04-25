`timescale 1ns/1ps

module conv_engine_tb;

    // --- Parameters (Matching your Conv Engine) ---
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    parameter IMG_W        = 28;
    parameter IMG_H        = 28;
    parameter K_W          = 3;
    parameter K_H          = 3;
    parameter ROWS         = 9;  // K_W * K_H
    parameter COLS         = 4;  // Number of Kernels (and Bias columns)
    parameter ADDR_WIDTH   = 10;
    
    // 21-bit width to prevent overflow during 9-element MAC operations
    localparam OUT_WIDTH = (2 * DATA_WIDTH) + 5; 

    // --- Signals ---
    logic clk;
    logic rst_n;
    logic start;
    logic busy;
    logic layer_done;
    logic weight_valid;
    logic signed [DATA_WIDTH-1:0] weight_in; 
    
    // Raw output from the Convolution Engine
    logic signed [COLS-1:0][OUT_WIDTH-1:0] conv_out_raw;
    logic out_valid_raw [COLS];

    // --- Signals for Bias & ReLU Stage ---
    logic signed [OUT_WIDTH-1:0] br_input_array [COLS];
    logic [OUT_WIDTH-1:0] final_relu_out [COLS];
    logic final_valid_out [COLS];

    // --- Bridge: Packed to Unpacked Array ---
    // This connects the Engine output to the Bias/ReLU input
    always_comb begin
        for (int i = 0; i < COLS; i++) begin
            br_input_array[i]    = conv_out_raw[i];
        end
    end

    // --- 1. Instantiate Convolution Engine (UUT) ---
    conv_engine #(
        .DATA_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .IMG_W(IMG_W), .IMG_H(IMG_H), .K_W(K_W), .K_H(K_H),
        .ROWS(ROWS), .COLS(COLS), .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk), .rst_n(rst_n), .start(start), 
        .busy(busy), .layer_done(layer_done),
        .weight_valid(weight_valid), .weight_in(weight_in),
        .conv_out(conv_out_raw), .out_valid(out_valid_raw)
    );

    // --- 2. Instantiate Bias & ReLU ---
    bias_relu #(
        .COLS(COLS),
        .ACC_WIDTH(OUT_WIDTH)
    ) u_bias_relu (
        .conv_out(br_input_array),
        .valid_in(out_valid_raw),
        .relu_out(final_relu_out),
        .valid_out(final_valid_out)
    );

    // --- Clock Generation ---
    initial clk = 0;
    always #5 clk = ~clk;


    // --- Cycle-by-Cycle Logic Monitor ---
    int cycle_count = 0;
    always @(posedge clk) begin
        if (uut.state == 2'b10) begin // Monitoring during COMPUTE
            cycle_count++;
            if (final_valid_out[0]) begin
                $write("  valid: ");
                for (int j = 0; j < COLS; j++) begin
                    $write("%0d ", final_valid_out[j]);
                end
                $display("");
                $write("  POST-RELU: ");
                for (int j = 0; j < COLS; j++) begin
                    $write("%-5d ", final_relu_out[j]);
                end
                $display("");
            end
        end
    end

     task automatic print_loaded_weights();
        $display("\n--- [STAGE 1] LOADED WEIGHT MAP (Systolic Array PE w_reg) ---");
        $display("         K0       K1       K2       K3");
        $display("Row 0: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[0].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[0].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[0].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[0].column_gen[3].pe_inst.w_reg);
        $display("Row 1: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[1].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[1].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[1].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[1].column_gen[3].pe_inst.w_reg);
        $display("Row 2: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[2].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[2].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[2].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[2].column_gen[3].pe_inst.w_reg);
        $display("Row 3: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[3].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[3].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[3].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[3].column_gen[3].pe_inst.w_reg);
        $display("Row 4: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[4].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[4].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[4].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[4].column_gen[3].pe_inst.w_reg);
        $display("Row 5: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[5].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[5].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[5].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[5].column_gen[3].pe_inst.w_reg);
        $display("Row 6: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[6].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[6].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[6].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[6].column_gen[3].pe_inst.w_reg);
        $display("Row 7: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[7].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[7].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[7].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[7].column_gen[3].pe_inst.w_reg);
        $display("Row 8: | %4d | %4d | %4d | %4d |", uut.u_array.row_gen[8].column_gen[0].pe_inst.w_reg, uut.u_array.row_gen[8].column_gen[1].pe_inst.w_reg, uut.u_array.row_gen[8].column_gen[2].pe_inst.w_reg, uut.u_array.row_gen[8].column_gen[3].pe_inst.w_reg);
        $display("------------------------------------------------------------\n");
    endtask

    // --- Main Simulation Control ---
    initial begin
        // Reset and Init
        rst_n = 0; start = 0; weight_in = 0; weight_valid = 0;
        
        $display("\n--- STARTING CONV ENGINE + BIAS_RELU PIPELINE ---");
        #40 rst_n = 1;
        repeat(5) @(posedge clk);

        // Start weight loading
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for Engine to move to compute state
        wait(uut.state == 2'b10); 
        print_loaded_weights();

        // Wait for the FIRST VALID result from the VERY END of the pipeline
        wait(final_valid_out[0] == 1'b1);
        $display("\n***************************************************");
        $display(" [SUCCESS] FIRST FULL PIPELINE RESULT DETECTED!");
        $display(" Time          : %0t", $time);
        $display(" Final ReLU K0 : %d (Raw Conv: %d)", final_relu_out[0], $signed(conv_out_raw[0]));
        $display("***************************************************\n");

        // Let it run for a while to see multiple pixels
        repeat(100) @(posedge clk);
        
        $display("Simulation finished. Check waves for details.");
        $finish;
    end

    // --- Waveform Export ---
    initial begin
        $dumpfile("pipeline_full_debug.vcd");
        $dumpvars(0, conv_engine_tb);
    end

endmodule