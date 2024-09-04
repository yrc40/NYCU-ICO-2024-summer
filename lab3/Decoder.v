module Decoder (
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //OP Field [31:26] 
  parameter OF_R_FORMAT = 6'b000000;
  parameter OF_I_ADDI = 6'b010011;
  parameter OF_I_LW = 6'b011000;
  parameter OF_I_SW = 6'b101000;
  parameter OF_I_BEQ = 6'b011001;
  parameter OF_I_BNE = 6'b011010;
  parameter OF_J_JUMP = 6'b001100;
  parameter OF_J_JAL = 6'b001111;
  parameter OF_I_BLT = 6'b011100;
  parameter OF_I_BNEZ = 6'b011101;
  parameter OF_I_BGEZ = 6'b011110;

  //ALU OP
  parameter ALU_ADD = 2'b00;
  parameter ALU_SUB = 2'b01;
  parameter ALU_R_FORMAT = 2'b10;
  parameter ALU_LESS = 2'b11;

  //I/O ports
  input [6-1:0] instr_op_i;

  output RegWrite_o;
  output [1:0] ALUOp_o;
  output ALUSrc_o;
  output RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output MemtoReg_o;

  //Internal Signals
  wire RegWrite_o;
  wire [1:0] ALUOp_o;
  wire ALUSrc_o;
  wire RegDst_o;
  wire Jump_o;
  wire Branch_o;
  wire BranchType_o;
  wire MemRead_o;
  wire MemWrite_o;
  wire MemtoReg_o;

  // RegWrite_o
  assign RegWrite_o = (instr_op_i == OF_R_FORMAT ||
                      instr_op_i == OF_I_ADDI ||
                      instr_op_i == OF_I_LW ||
                      instr_op_i == OF_J_JAL) ? 1'b1 : 1'b0;

  // ALUOp_o
  assign ALUOp_o = (instr_op_i == OF_R_FORMAT) ? ALU_R_FORMAT :
                   (instr_op_i == OF_I_ADDI || instr_op_i == OF_I_LW || instr_op_i == OF_I_SW) ? ALU_ADD :
                   (instr_op_i == OF_I_BEQ || instr_op_i == OF_I_BNE || instr_op_i == OF_I_BNEZ) ? ALU_SUB :
                   (instr_op_i == OF_I_BGEZ || instr_op_i == OF_I_BLT) ? ALU_LESS :
                   2'b00; 

  // ALUSrc_o
  assign ALUSrc_o = (instr_op_i == OF_I_ADDI || instr_op_i == OF_I_LW || instr_op_i == OF_I_SW) ? 1'b1 : 1'b0;

  // RegDst_o
  assign RegDst_o = (instr_op_i == OF_R_FORMAT) ? 1'b1 : 1'b0;

  // Jump_o
  assign Jump_o = (instr_op_i == OF_J_JAL || instr_op_i == OF_J_JUMP) ? 1'b1 : 1'b0;

  // Branch_o
  assign Branch_o = (instr_op_i == OF_I_BEQ || 
                     instr_op_i == OF_I_BGEZ || 
                     instr_op_i == OF_I_BLT || 
                     instr_op_i == OF_I_BNE || 
                     instr_op_i == OF_I_BNEZ) ? 1'b1 : 1'b0;

  // BranchType_o
  assign BranchType_o = (instr_op_i == OF_I_BEQ || instr_op_i == OF_I_BGEZ) ? 1'b1 : 1'b0;

  // MemRead_o
  assign MemRead_o = (instr_op_i == OF_I_LW) ? 1'b1 : 1'b0;

  // MemWrite_o
  assign MemWrite_o = (instr_op_i == OF_I_SW) ? 1'b1 : 1'b0;

  // MemtoReg_o
  assign MemtoReg_o = (instr_op_i == OF_I_LW) ? 1'b1 : 1'b0;

endmodule
