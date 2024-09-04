module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    leftRight_o, 
    Shift_o,
    JumpTo_o
);

  //function field(R format)
  parameter FUNC_ADD = 6'b100011;
  parameter FUNC_SUB = 6'b010011;
  parameter FUNC_AND = 6'b011111;
  parameter FUNC_OR  = 6'b101111;
  parameter FUNC_NOR = 6'b010000;
  parameter FUNC_SLT = 6'b010100;
  parameter FUNC_SLLV = 6'b011000;
  parameter FUNC_SLL = 6'b010010;
  parameter FUNC_SRLV = 6'b101000;
  parameter FUNC_SRL = 6'b100010;
  parameter FUNC_JR = 6'b000001;

  //ALU OP
  parameter ALU_ADD = 2'b00;
  parameter ALU_SUB = 2'b01;
  parameter ALU_R_FORMAT = 2'b10;
  parameter ALU_LESS = 2'b11;

  parameter ADD = 4'b0000;
  parameter SUB = 4'b0001;
  parameter AND = 4'b0010;
  parameter OR = 4'b0110;
  parameter NOR = 4'b1100;
  parameter LESS = 4'b0111;

  //I/O ports
  input [6-1:0] funct_i;
  input [2-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output leftRight_o;
  output Shift_o;
  output JumpTo_o;

  //Internal Signals
  wire [4-1:0] ALU_operation_o;
  wire [2-1:0] FURslt_o;
  wire leftRight_o;
  wire Shift_o;
  wire JumpTo_o;

  //Main function
  assign ALU_operation_o = (ALUOp_i == ALU_ADD)        ? ADD :
                           (ALUOp_i == ALU_SUB)        ? SUB :
                           (ALUOp_i == ALU_R_FORMAT && funct_i == FUNC_ADD) ? ADD :
                           (ALUOp_i == ALU_R_FORMAT && funct_i == FUNC_SUB) ? SUB :
                           (ALUOp_i == ALU_R_FORMAT && funct_i == FUNC_AND) ? AND :
                           (ALUOp_i == ALU_R_FORMAT && funct_i == FUNC_OR)  ? OR  :
                           (ALUOp_i == ALU_R_FORMAT && funct_i == FUNC_NOR) ? NOR :
                           (ALUOp_i == ALU_R_FORMAT && funct_i == FUNC_SLT) ? LESS:
                           4'b0000; 

  // Determine Function Unit Result (FURslt_o)
  assign FURslt_o = (ALUOp_i == ALU_R_FORMAT && (funct_i == FUNC_SLL || funct_i == FUNC_SLLV || funct_i == FUNC_SRL || funct_i == FUNC_SRLV)) ? 2'b01 :
                    2'b00; // Default ALU result

  // Determine Left/Right shift direction (leftRight_o)
  assign leftRight_o = (ALUOp_i == ALU_R_FORMAT && (funct_i == FUNC_SLL || funct_i == FUNC_SLLV)) ? 1'b1 : 1'b0;

  // Determine Shift operation indicator (Shift_o)
  assign Shift_o = (ALUOp_i == ALU_R_FORMAT && (funct_i == FUNC_SLLV || funct_i == FUNC_SRLV)) ? 1'b1 : 1'b0;

  // Determine Jump operation indicator (JumpTo_o)
  assign JumpTo_o = (ALUOp_i == ALU_R_FORMAT && funct_i == FUNC_JR) ? 1'b1 : 1'b0;

endmodule
