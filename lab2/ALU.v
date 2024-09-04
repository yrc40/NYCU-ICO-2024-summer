`include "ALU_1bit.v"

module ALU (
    aluSrc1,
    aluSrc2,
    invertA,
    invertB,
    operation,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input invertA;
  input invertB;
  input [2-1:0] operation;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire zero;
  wire overflow;

  //Main function

  /*Generate 32 bit ALU*/
  wire set;
  wire carryNumber[32-1:0];
  assign set = aluSrc1[31] ^ (~aluSrc2[31]) ^ carryNumber[31]; //the sum of 32th bit
  genvar i; 
  generate
    for(i = 0; i < 32; i = i + 1) begin : ALU_32bit
      wire cryIn; 
      if (i == 0) begin
        assign cryIn = invertB; 
      end else begin
        assign cryIn = carryNumber[i-1];
      end
      ALU_1bit alu (
        .a(aluSrc1[i]),
        .b(aluSrc2[i]),
        .invertA(invertA),
        .invertB(invertB),
        .operation(operation),
        .carryIn(cryIn), 
        .less((i == 0) ? set : 1'b0), 
        .result(result[i]),
        .carryOut(carryNumber[i])
      );
    end
  endgenerate

  /*Calculate 32 bit ALU output*/
  assign  zero = (result == 0);
  assign  overflow = carryNumber[31] ^ carryNumber[30];


endmodule
