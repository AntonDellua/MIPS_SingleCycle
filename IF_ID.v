module IF_ID
(
	input clk,
	input [31:0] Instruction_In,
	input [31:0] PC_4_In,
	input [31:0] PC,
	
	output reg [31:0] Instruction_Out,
	output reg [31:0] PC_4_Out,
	output reg [31:0] PC_Out
);



	always@(negedge clk)
	begin
		
		Instruction_Out = Instruction_In;
		PC_4_Out = PC_4_In;		
		PC_Out = PC;

	end

endmodule