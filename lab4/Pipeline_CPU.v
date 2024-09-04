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
`include "Pipe_Reg.v"

module Pipeline_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  /*your code here*/
  //Internal Signles
  wire [32-1:0] pc_in;
  wire [32-1:0] pc_out;
  wire [32-1:0] pc_add;
  wire [32-1:0] pc_branch;
  wire [32-1:0] pc_no_jump;
  wire [32-1:0] pc_temp;
  wire [32-1:0] instr;
  wire RegWrite;
  wire [2-1:0] ALUOp;
  wire ALUSrc;
  wire RegDst;
  wire Jump;
  wire Branch;
  wire BranchType;
  wire JRsrc;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire [5-1:0] RegAddrTemp;
  wire [5-1:0] RegAddr;
  wire [32-1:0] WriteData;
  wire [32-1:0] RSdata;
  wire [32-1:0] RTdata;
  wire [4-1:0] ALU_operation;
  wire [2-1:0] FURslt;
  wire sftVariable;
  wire leftRight;
  wire [32-1:0] extendData;
  wire [32-1:0] zeroData;
  wire [32-1:0] ALUsrcData;
  wire [32-1:0] ALUresult;
  wire zero;
  wire overflow;
  wire [5-1:0] shamt;
  wire [32-1:0] sftResult;
  wire [32-1:0] RegData;
  wire [32-1:0] MemData;
  wire [32-1:0] DataNoJal;

  //modules

  // IF
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );

  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (pc_add)
  );

  Adder Adder2 (
      .src1_i(pc_add),
      .src2_i({extendData[29:0], 2'b00}),
      .sum_o (pc_branch)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (pc_add),
      .data1_i (pc_branch),
      .select_i(Branch & (~BranchType ^ zero)),
      .data_o  (pc_no_jump)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (pc_no_jump),
      .data1_i ({pc_add[31:28], instr[25:0], 2'b00}),
      .select_i(Jump),
      .data_o  (pc_temp)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jr (
      .data0_i (pc_temp),
      .data1_i (RSdata),
      .select_i(JRsrc),
      .data_o  (pc_in)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr)
  );

  // IF/ID - store instr
  wire [32-1:0] IFID;
  Pipe_Reg #(
      .size(32)
  ) pipe_IFID (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(instr),
      .data_o(IFID)
  );

  // ID

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(IFID[25:21]),
      .RTaddr_i(IFID[20:16]),
      .RDaddr_i(MEMWB_RegAddr),
      .RDdata_i(WriteData),
      .RegWrite_i(MEMWB_RegWrite & (~JRsrc)),
      .RSdata_o(RSdata),
      .RTdata_o(RTdata)
  );

  Decoder Decoder (
      .instr_op_i(IFID[31:26]),
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

  Sign_Extend SE (
      .data_i(IFID[15:0]),
      .data_o(extendData)
  );

  Zero_Filled ZF (
      .data_i(IFID[15:0]),
      .data_o(zeroData)
  );

  // ID/EX
  wire [31:0] IDEX;
  Pipe_Reg #(
      .size(32)
  ) pipe_IDEX (
      .clk_i(clk_i), 
      .rst_n(rst_n), 
      .data_i(IFID), 
      .data_o(IDEX)
  );

  wire [1:0] IDEX_ALUOp;
  wire IDEX_ALUSrc;
  wire IDEX_MemRead;
  wire IDEX_MemtoReg;
  wire IDEX_MemWrite;
  wire IDEX_RegDst;
  wire IDEX_RegWrite;
  Pipe_Reg #(
      .size(8)
  ) pipe_IDEXctrl (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i({RegWrite, ALUOp, ALUSrc, RegDst, MemRead, MemWrite, MemtoReg}),
      .data_o({IDEX_RegWrite, IDEX_ALUOp, IDEX_ALUSrc, IDEX_RegDst, IDEX_MemRead, IDEX_MemWrite, IDEX_MemtoReg})
  );

  wire [31:0] IDEX_RSdata;
  Pipe_Reg #(
      .size(32)
  ) pipe_IDEXrs (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(RSdata), 
    .data_o(IDEX_RSdata)
  );

  wire [31:0] IDEX_RTdata;
  Pipe_Reg #(
      .size(32)
  ) pipe_IDEXrt (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(RTdata), 
    .data_o(IDEX_RTdata)
  );

  wire [31:0] IDEX_extendData;
  Pipe_Reg #(
      .size(32)
  ) pipe_IDEXextendData (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(extendData), 
    .data_o(IDEX_extendData)
  );

  wire [31:0] IDEX_zeroData;
  Pipe_Reg #(
      .size(32)
  ) pipe_IDEXzeroData (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(zeroData), 
    .data_o(IDEX_zeroData)
  );

  // EX
  Mux2to1 #(
      .size(5)
  ) Mux_RS_RT (
      .data0_i (IDEX[20:16]), //rt
      .data1_i (IDEX[15:11]), //rd
      .select_i(IDEX_RegDst),
      .data_o  (RegAddrTemp)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (RegAddrTemp),
      .data1_i (5'd31),
      .select_i(Jump),
      .data_o  (RegAddr)
  );
    ALU_Ctrl AC (
      .funct_i(IDEX[5:0]),
      .ALUOp_i(IDEX_ALUOp),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .sftVariable_o(sftVariable),
      .leftRight_o(leftRight),
      .JRsrc_o(JRsrc)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (IDEX_RTdata),
      .data1_i (IDEX_extendData),
      .select_i(IDEX_ALUSrc),
      .data_o  (ALUsrcData)
  );

  ALU ALU (
      .aluSrc1(IDEX_RSdata),
      .aluSrc2(ALUsrcData),
      .ALU_operation_i(ALU_operation),
      .result(ALUresult),
      .zero(zero),
      .overflow(overflow)
  );

  Mux2to1 #(
      .size(5)
  ) Shamt_Src (
      .data0_i (IDEX[10:6]),
      .data1_i (IDEX_RSdata[4:0]),
      .select_i(sftVariable),
      .data_o  (shamt)
  );

  Shifter shifter (
      .leftRight(leftRight),
      .shamt(shamt),
      .sftSrc(ALUsrcData),
      .result(sftResult)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (ALUresult),
      .data1_i (sftResult),
      .data2_i (IDEX_zeroData),
      .select_i(FURslt),
      .data_o  (RegData)
  );

  // EX/MEM
  wire EXMEM_RegWrite;
  wire EXMEM_MemWrite;
  wire EXMEM_MemRead;
  wire EXMEM_MemtoReg;
  Pipe_Reg #(
      .size(4)
  ) pipe_EXMEMctrl (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i({IDEX_MemRead, IDEX_MemtoReg, IDEX_MemWrite, IDEX_RegWrite}), 
    .data_o({EXMEM_MemRead, EXMEM_MemtoReg, EXMEM_MemWrite, EXMEM_RegWrite})
  );

  wire [31:0] EXMEM_RegData;
  Pipe_Reg #(
      .size(32)
   ) pipe_EXMEMregData (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(RegData), 
    .data_o(EXMEM_RegData)
  );

  wire [31:0] EXMEM_RTdata;
  Pipe_Reg #(
      .size(32)
   ) pipe_EXMEMrt (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(IDEX_RTdata), 
    .data_o(EXMEM_RTdata)
  );

  wire [4:0] EXMEM_RegAddr;
  Pipe_Reg #(
      .size(5)
  ) pipe_EXMEMregAddr (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(RegAddr), 
    .data_o(EXMEM_RegAddr)
  );

  // MEM
  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(EXMEM_RegData),
      .data_i(EXMEM_RTdata),
      .MemRead_i(EXMEM_MemRead),
      .MemWrite_i(EXMEM_MemWrite),
      .data_o(MemData)
  );

  // MEM/WB
  wire MEMWB_MemWrite;
  wire MEMWB_MemtoReg;
  Pipe_Reg #(
      .size(2)
  ) pipe_MEMWBctrl (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i({EXMEM_RegWrite, EXMEM_MemtoReg}),
      .data_o({MEMWB_RegWrite, MEMWB_MemtoReg})
  );

  wire [31:0] MEMWB_RegData;
  Pipe_Reg #(
      .size(32)
   ) pipe_MEMWBregData (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(EXMEM_RegData), 
    .data_o(MEMWB_RegData)
  );

  wire [4:0] MEMWB_RegAddr;
  Pipe_Reg #(
      .size(5)
  ) pipe_MEMWBregAddr (
    .clk_i (clk_i), 
    .rst_n (rst_n), 
    .data_i(EXMEM_RegAddr), 
    .data_o(MEMWB_RegAddr)
  );

  wire [31:0] MEMWB_MemData;
  Pipe_Reg #(
    .size(32)
  ) pipe_MEMWBMemData (
    .clk_i(clk_i), 
    .rst_n(rst_n), 
    .data_i(MemData), 
    .data_o(MEMWB_MemData)
  );

  // WB
  Mux2to1 #(
      .size(32)
  ) Mux_Read_Mem (
      .data0_i (MEMWB_RegData),
      .data1_i (MEMWB_MemData),
      .select_i(MEMWB_MemtoReg),
      .data_o  (DataNoJal)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Jal (
      .data0_i (DataNoJal),
      .data1_i (pc_add),
      .select_i(Jump),
      .data_o  (WriteData)
  );
endmodule



