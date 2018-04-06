/******************************************************************
* Description
*	This performs a shift left opeartion in roder to calculate the brances.
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
module ShiftLeft2Cat
(   
	input [31:0]  DataInput,
   output reg [31:0] DataOutput

);
   always @ (DataInput)
     DataOutput = {4'b0000, DataInput[25:0], 1'b0, 1'b0};

endmodule // leftShift2Cat