module relu #(
  parameter WIDTH = 32
)(
  input  logic signed [WIDTH-1:0] data_in,
  output logic signed [WIDTH-1:0] data_out
);
  assign data_out = (data_in[WIDTH-1]) ? '0 : data_in;
endmodule
