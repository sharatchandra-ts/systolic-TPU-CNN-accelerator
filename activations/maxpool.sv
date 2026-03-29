module maxpool #(
  parameter WIDTH   = 32
)(
  input  logic signed [WIDTH-1:0] a, b, c, d,
  output logic signed [WIDTH-1:0] data_out
);
  logic signed [WIDTH-1:0] max_ab, max_cd;

  assign max_ab   = (a > b) ? a : b;
  assign max_cd   = (c > d) ? c : d;
  assign data_out = (max_ab > max_cd) ? max_ab : max_cd;

endmodule
