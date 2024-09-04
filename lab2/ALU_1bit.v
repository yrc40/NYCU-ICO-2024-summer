`include "Full_adder.v"
`define op_add  2'b11
`define op_and  2'b00
`define op_or  2'b10
`define op_less  2'b01

module ALU_1bit (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut
);
  
  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;

  output result;
  output carryOut;

  //Internal Signals
  wire result;
  wire carryOut;

  //Main function
  wire sum;
  wire inputA, inputB;

  assign inputA = (invertA == 1'b1) ? ~a : a;
  assign inputB = (invertB == 1'b1) ? ~b : b;

  assign result = (operation == `op_add) ? sum : 
    (operation == `op_and) ? inputA & inputB :
    (operation == `op_or) ? inputA | inputB :
    (operation == `op_less) ? less : 1'b0;

  Full_adder adder (
    .carryIn(carryIn),
    .input1(inputA),
    .input2(inputB),
    .sum(sum),
    .carryOut(carryOut)
  );

endmodule
