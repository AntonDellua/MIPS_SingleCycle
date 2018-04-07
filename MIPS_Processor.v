/******************************************************************
* Description
*	This is the top-level of a MIPS processor that can execute the next set of instructions:
*		add
*		addi
*		sub
*		ori
*		or
*		bne
*		beq
*		and
*		nor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer organization class at ITESO.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	12/06/2016
******************************************************************/

module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 512,
	parameter DATA_WIDTH=32
)

(
	// Inputs
	input clk,
	input reset,
	input [7:0] PortIn,
	// Output
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);
//******************************************************************/
//******************************************************************/

assign  PortOut = 0;

//******************************************************************/
//******************************************************************/

wire [31:0] w_MuxJump_PC;
wire [31:0] w_PC_ROM;
wire [31:0] w_Add_ShiftA_Add;
wire [31:0] w_ROM_Out;
wire [31:0] w_ShiftA_MuxJump;
wire [5:0]  w_ALU_Op;
wire			w_Jump;
wire			w_Branch;
wire			w_MemRead;
wire			w_MemtoReg;
wire			w_MemWrite;
wire			w_ALUSrc;
wire			w_RegWrite;
wire			w_RegDst;
wire [5:0]  w_WriteReg;
wire [31:0] w_WriteData;
wire [31:0] w_A;
wire [31:0] w_Reg_MuxALU;
wire [31:0] w_Sign;
wire [31:0] w_ShiftB;
wire [31:0] w_B;
wire [31:0] w_Add_MuxBranch;
wire			w_zero;
wire			w_PCSrc;
wire [3:0]	w_ALUControl;
wire [31:0] w_ALUResult;
wire [31:0]	w_Mux_Mux;
wire [31:0] w_RAM_Mux;
wire			w_JAL;
wire [4:0]  w_JAL_In;
wire [31:0] w_MuxJR;
wire			w_JR;


//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

PC_Register
ProgramCounter
(
	//Input
	.clk(clk),
	.reset(reset),
	.NewPC(w_MuxJR),
	//Output
	.PCValue(w_PC_ROM)
);

Adder32bits
Add_PC
(
	//Input
	.Data0(w_PC_ROM),
	.Data1(4),
	//Output
	.Result(w_Add_ShiftA_Add)
);

ProgramMemory
#(
	.MEMORY_DEPTH(MEMORY_DEPTH)
)
ROM
(
	//Input
	.Address(w_PC_ROM),
	//Output
	.Instruction(w_ROM_Out)
);

ShiftLeft2Cat
ShiftA
(
	//Input
	//.DataInput(w_ROM_Out[25:0]),
	.DataInput(w_ROM_Out),
	//.Concatenate(w_Add_ShiftA_Add[31:28]),
	//Output
	.DataOutput(w_ShiftA_MuxJump)
);

Control
ControlUnit
(
	//Input
	.OP(w_ROM_Out[31:26]),
	//Output
	.ALUOp(w_ALU_Op),
	.Jump(w_Jump),
	.Branch(w_Branch),
	.MemRead(w_MemRead),
	.MemtoReg(w_MemtoReg),
	.MemWrite(w_MemWrite),
	.ALUSrc(w_ALUSrc),
	.RegWrite(w_RegWrite),
	.RegDst(w_RegDst),
	.Jal(w_JAL)
);

Multiplexer2to1
MuxReg
(
	//Input
	.Selector(w_RegDst),
	.Data0(w_ROM_Out[20:16]),
	.Data1(w_ROM_Out[15:11]),
	//Output
	.OUT(w_JAL_In)
);

RegisterFile
RegisterFile
(
	//Input
	.clk(clk),
	.reset(reset),
	.RegWrite(w_RegWrite),
	.ReadRegister1(w_ROM_Out[25:21]),
	.ReadRegister2(w_ROM_Out[20:16]),
	.WriteRegister(w_WriteReg),
	.WriteData(w_WriteData),
	//Output
	.ReadData1(w_A),
	.ReadData2(w_Reg_MuxALU)
);

SignExtend
SignExtend
(
	//Input
	.DataInput(w_ROM_Out[15:0]),
	//Output
	.SignExtendOutput(w_Sign)
);

ShiftLeft2
ShiftB
(
	//Input
	.DataInput(w_Sign),
	//Output
	.DataOutput(w_ShiftB)
);

Multiplexer2to1
MuxALU
(
	//Input
	.Selector(w_ALUSrc),
	.Data0(w_Reg_MuxALU),
	.Data1(w_Sign),
	//Output
	.OUT(w_B)
);

Adder32bits
Add
(
	//Input
	.Data0(w_Add_ShiftA_Add),
	.Data1(w_ShiftB),
	//Output
	.Result(w_Add_MuxBranch)
);

ANDGate
AND
(
	//Input
	.A(w_Branch),
	.B(w_zero),
	//Output
	.C(w_PCSrc)
);

ALU
ALU
(
	//Input
	.A(w_A),
	.B(w_B),
	.C(w_PC_ROM),		//PCValue, used for JAL
	.ALUOperation(w_ALUControl),
	.shamt(w_ROM_Out[10:6]),
	//Output
	//.ovf(),
	.Zero(w_zero),
	.ALUResult(w_ALUResult)
);

ALUControl
ALUControl
(
	//Input
	.ALUFunction(w_ROM_Out[5:0]),
	.ALUOp(w_ALU_Op),
	//Output
	.ALUOperation(w_ALUControl),
	.JrFlag(w_JR)
);

Multiplexer2to1
MuxBranch
(
	//Input
	.Data0(w_Add_ShiftA_Add),
	.Data1(w_Add_MuxBranch),
	.Selector(w_PCSrc),
	//Output
	.OUT(w_Mux_Mux)
);

Multiplexer2to1
MuxJump
(
	//Input
	.Selector(w_Jump),
	.Data0(w_Mux_Mux),
	.Data1(w_ShiftA_MuxJump),
	//Output
	.OUT(w_MuxJump_PC)
);

DataMemory 
#(	
   .DATA_WIDTH(DATA_WIDTH),
	.MEMORY_DEPTH(MEMORY_DEPTH)

)
RAM
(
	//Input
	.clk(clk),
	.MemWrite(w_MemWrite),
	.Address(w_ALUResult),
	.WriteData(w_Reg_MuxALU),
	.MemRead(w_MemRead),
	//Output
	.ReadData(w_RAM_Mux)
);

Multiplexer2to1
MuxRAM
(
	//Input
	.Selector(w_MemtoReg),
	.Data0(w_ALUResult),
	.Data1(w_RAM_Mux),
	//Output
	.OUT(w_WriteData)
);

Multiplexer2to1JAL
MuxJAL
(
	//Input
	.Selector(w_JAL),
	.Data0(w_JAL_In),
	.Data1(31),
	//Output
	.OUT(w_WriteReg)
);
 
Multiplexer2to1
MuxJR
(
	//Input
	.Selector(w_JR),
	.Data0(w_MuxJump_PC),
	.Data1(w_ALUResult),
	//Output
	.OUT(w_MuxJR)
);

assign ALUResultOut = w_ALUResult;

endmodule

