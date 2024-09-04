`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"

module Simple_Single_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signles
  wire [31:0] pc_in;
  wire [31:0] pc_out;
  wire [31:0] next_pc;
  wire [31:0] extended_offset;
  wire [31:0] branch_pc;
  wire Branch;
  wire BranchType;
  //wire zero;
  wire [31:0] pc_result1;
  wire [31:0] instr;
  wire Jump;
  wire [31:0] pc_result2;
  wire jumpTo;
  wire [31:0] rs;
  wire [31:0] rt;
  wire RegDst;
  wire [4:0] writeTarget;
  wire [4:0] writeAddr;
  wire Regwrite;
  wire [31:0] dataToWrite;
  wire [1:0] ALUOp;
  wire ALUSrc;;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire [3:0] ALU_operation;
  wire [1:0] FURslt;
  wire leftRight;
  wire Shift;
  wire [31:0] zero_filled;
  wire [31:0] ALUdata2;
  wire [31:0] ALUresult;
  wire ALUzero;
  wire ALUoverflow;
  wire [4:0] shamt;
  wire [31:0] shiftresult;
  wire [31:0] newData;
  wire [31:0] loadedData;
  wire [31:0] wbData;

  //modules
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );

  Adder PC_Adder1 ( //next PC = PC + 4
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (next_pc)
  );

  Adder PC_Adder2 ( //next PC = PC + 4 + branch offset
      .src1_i(next_pc),
      .src2_i({extended_offset[29:0], 2'b00}),
      .sum_o (branch_pc)
  );

  Mux2to1 #( //decide branch or not
      .size(32)
  ) Mux_branch (
      .data0_i (next_pc),
      .data1_i (branch_pc),
      .select_i(Branch & (~BranchType ^ ALUzero)),
      .data_o  (pc_result1)
  );

  Mux2to1 #( //decide jump or not
      .size(32)
  ) Mux_jump (
      .data0_i (pc_result1),
      .data1_i ({next_pc[31:28], instr[25:0], 2'b0}),
      .select_i(Jump),
      .data_o  (pc_result2)
  );

  Mux2to1 #( //decide jump to $ra or not
      .size(32)
  ) Mux_jr (
      .data0_i (pc_result2),
      .data1_i (rs),
      .select_i(jumpTo),
      .data_o  (pc_in)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr)
  );

  Mux2to1 #( //write rt or rd
      .size(5)
  ) Mux_Reg_Dst (
      .data0_i (instr[20:16]), //rt
      .data1_i (instr[15:11]), //rd
      .select_i(RegDst),
      .data_o  (writeTarget)
  );

  Mux2to1 #( //write reg or not
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (writeTarget),
      .data1_i (5'd31), //reg31, jal
      .select_i(Jump),
      .data_o  (writeAddr)
  );

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instr[25:21]),
      .RTaddr_i(instr[20:16]),
      .RDaddr_i(writeAddr),
      .RDdata_i(dataToWrite),
      .RegWrite_i(RegWrite & (~jumpTo)),
      .RSdata_o(rs),
      .RTdata_o(rt)
  );

  Decoder Decoder (
      .instr_op_i(instr[31:26]),
      .RegWrite_o(RegWrite),
      .ALUOp_o(ALUOp),
      .ALUSrc_o(ALUSrc),
      .RegDst_o(RegDst),
      .Jump_o(Jump),
      .Branch_o(Branch),
      .BranchType_o(BranchType),
      .MemRead_o(MemRead),
      .MemWrite_o(MemWrite),
      .MemtoReg_o(MemtoReg)
  );

  ALU_Ctrl AC (
      .funct_i(instr[5:0]),
      .ALUOp_i(ALUOp),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .leftRight_o(leftRight), 
      .Shift_o(Shift), 
      .JumpTo_o(jumpTo)
  );

  Sign_Extend SE (
      .data_i(instr[15:0]),
      .data_o(extended_offset)
  );

  Zero_Filled ZF (
      .data_i(instr[15:0]),
      .data_o(zero_filled)
  );

  Mux2to1 #( //from rt directly or sign extension
      .size(32)
  ) ALU_src2Src (
      .data0_i (rt),
      .data1_i (extended_offset),
      .select_i(ALUSrc),
      .data_o  (ALUdata2)
  );

  ALU ALU (
      .aluSrc1(rs),
      .aluSrc2(ALUdata2),
      .ALU_operation_i(ALU_operation),
      .result(ALUresult),
      .zero(ALUzero),
      .overflow(ALUoverflow)
  );

  Mux2to1 #( //shift by shamt or rs
      .size(5)
  ) Shiftsrc (
      .data0_i (instr[10:6]),
      .data1_i (rs[4:0]),
      .select_i(Shift),
      .data_o  (shamt)
  );

  Shifter shifter (
      .result(shiftresult),
      .leftRight(leftRight),
      .shamt(shamt),
      .sftSrc(ALUdata2)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (ALUresult),
      .data1_i (shiftresult),
      .data2_i (zero_filled),
      .select_i(FURslt),
      .data_o  (newData)
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(newData),
      .data_i(rt),
      .MemRead_i(MemRead),
      .MemWrite_i(MemWrite),
      .data_o(loadedData)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(newData),
      .data1_i(loadedData),
      .select_i(MemtoReg),
      .data_o(wbData)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Jal (
      .data0_i (wbData),
      .data1_i (next_pc),
      .select_i(Jump),
      .data_o  (dataToWrite)
  );



endmodule



