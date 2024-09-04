module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  parameter ADD = 4'b0000;
  parameter SUB = 4'b0001;
  parameter AND = 4'b0010;
  parameter OR = 4'b0110;
  parameter NOR = 4'b1100;
  parameter LESS = 4'b0111;

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire zero;
  wire overflow;

  //Main function
  // ALU operation assignments
  assign result = (ALU_operation_i == ADD)  ? aluSrc1 + aluSrc2 :
                  (ALU_operation_i == SUB)  ? aluSrc1 - aluSrc2 :
                  (ALU_operation_i == AND)  ? aluSrc1 & aluSrc2 :
                  (ALU_operation_i == OR)   ? aluSrc1 | aluSrc2 :
                  (ALU_operation_i == NOR)  ? ~(aluSrc1 | aluSrc2) :
                  (ALU_operation_i == LESS) ? ($signed(aluSrc1) < $signed(aluSrc2)) : 32'b0;

  // Zero flag assignment
  assign zero = (result == 32'b0) ? 1'b1 : 1'b0;
   // Overflow detection logic
  wire add_sub_overflow;
  wire add_overflow;
  wire sub_overflow;
  
  // Overflow detection for addition and subtraction
  assign add_overflow = (aluSrc1[31] & aluSrc2[31] & ~result[31]) | (~aluSrc1[31] & ~aluSrc2[31] & result[31]);
  assign sub_overflow = (aluSrc1[31] & ~aluSrc2[31] & ~result[31]) | (~aluSrc1[31] & aluSrc2[31] & result[31]);
  
  // Final overflow flag
  assign add_sub_overflow = (ALU_operation_i == ADD) ? add_overflow : 
                            (ALU_operation_i == SUB) ? sub_overflow :
                            1'b0;

  assign overflow = add_sub_overflow;

endmodule
