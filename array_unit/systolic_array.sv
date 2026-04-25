module systolic_array #(
    // Dimensions of the TPU grid
    parameter ROWS = 4,
    parameter COLUMNS = 4,
    // 8bit data input
    parameter DATA_WIDTH = 8, 
    // Ment to accomodate overflow while multiplication and addition
    parameter ACC_WIDTH = 32 
)(
    input logic clk,
    input logic rst_n,
    input logic load_en,
    // Inputs enter from top and left
    input logic signed [DATA_WIDTH-1:0] a_in [ROWS],
    input logic signed [DATA_WIDTH-1:0] w_in [COLUMNS],
    // Results exit from the bottom row
    output logic signed [ACC_WIDTH-1:0] result [COLUMNS],

    input logic a_valid [ROWS], // Valid for input
    input logic w_valid [COLUMNS], // Valid for weights
    input logic clear_in [COLUMNS], // New input array

    output logic valid_out_final [COLUMNS]
);
    // 2D Matrix wires to connect the PEs
    logic signed [DATA_WIDTH-1:0] a_wire   [ROWS][COLUMNS+1];
    logic signed [DATA_WIDTH-1:0] w_wire   [ROWS+1][COLUMNS];
    logic signed [ACC_WIDTH-1:0]  acc_wire [ROWS+1][COLUMNS];
    logic w_valid_wire [ROWS+1][COLUMNS];
    logic acc_valid_wire [ROWS+1][COLUMNS];
    logic a_valid_wire [ROWS][COLUMNS+1];
    logic clear_wire [ROWS+1][COLUMNS];

    // Connect top and left boundaries
    genvar i;
    generate
        for (i = 0; i < ROWS; i++) begin
            assign a_wire[i][0] = a_in[i];
            assign a_valid_wire[i][0] = a_valid[i]; 
        end
        for (i = 0; i < COLUMNS; i++) begin
            assign w_wire[0][i] = w_in[i];
            assign acc_wire[0][i] = 0;
            assign w_valid_wire[0][i] = w_valid[i]; 
            assign clear_wire[0][i] = clear_in[i];
            // assign valid_out_final[i] = acc_valid_wire[ROWS][i];
        end
    endgenerate

    // Generate the 2D Mesh of MAC units
    genvar r, c;
    generate 
        for (r = 0; r < ROWS; r++) begin : row_gen
            for (c = 0; c < COLUMNS; c++) begin : column_gen    
                mac_unit #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH(ACC_WIDTH)
                ) pe_inst (
                    .clk (clk),
                    .rst_n (rst_n),
                    .load_en (load_en),
                    .clear_in (clear_wire[r][c]),
                    .clear_out (clear_wire[r+1][c]), // Flowing North-to-South
                    .w_valid_in (w_valid_wire[r][c]),
                    .w_valid_out (w_valid_wire[r+1][c]), // Flowing North-to-South
                    .acc_valid_in (acc_valid_wire[r][c]),
                    .acc_valid_out (acc_valid_wire[r+1][c]), // Flowing North-to-South
                    .a_valid_in (a_valid_wire[r][c]),
                    .a_valid_out (a_valid_wire[r][c+1]), // To West-to-East neighbor
                    .a_in (a_wire[r][c]),
                    .a_out (a_wire[r][c+1]),     // Flowing West-to-East
                    .w_in (w_wire[r][c]),
                    .w_out (w_wire[r+1][c]),     // Flowing North-to-South
                    .acc_in (acc_wire[r][c]),
                    .acc_out (acc_wire[r+1][c])    // Flowing North-to-South
                );
            end
        end 
    endgenerate

    // Final result output from the bottom row
    generate
        for (i = 0; i < COLUMNS; i++) begin
            assign result[i] = acc_wire[ROWS][i];
            assign valid_out_final[i] = acc_valid_wire[ROWS][i];
        end
    endgenerate

endmodule
