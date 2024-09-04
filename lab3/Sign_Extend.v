module Sign_Extend (
    data_i,
    data_o
);

  //I/O ports
  input [16-1:0] data_i;

  output [32-1:0] data_o;

  //Internal Signals
  wire [32-1:0] data_o;

  //Sign extended
  assign data_o = (data_i[16-1] == 1'b0) ? {16'b0, data_i} : {16'b1111111111111111, data_i};


endmodule
