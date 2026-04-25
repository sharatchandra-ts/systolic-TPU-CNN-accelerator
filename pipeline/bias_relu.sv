module bias_relu #(
    parameter COLS      = 4,
    parameter ACC_WIDTH = 8
)(
    input logic signed [ACC_WIDTH-1:0] conv_out [COLS],
    input logic valid_in [COLS],

    output logic [ACC_WIDTH-1:0] relu_out [COLS],
    output logic valid_out [COLS]
);

    logic signed [ACC_WIDTH-1:0] biased [COLS];
    logic signed [ACC_WIDTH-1:0] bias_mem [COLS];
    initial $readmemh("/Users/sharat/Development/system-verilog/ml_accelerator/weights/conv_bias.hex", bias_mem);

    always_comb begin
        for (int k = 0; k < COLS; k++) begin
            biased[k]    = '0;
            relu_out[k]  = '0;
            valid_out[k] = valid_in[k];
            
            if (valid_in[k]) begin
                biased[k]   = conv_out[k] + bias_mem[k];
                relu_out[k] = (biased[k] < 0) ? '0 : biased[k];
            end
        end
    end

endmodule
