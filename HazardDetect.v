/**********************************************************************
*
*  Module Hazard detection Unit
*	
********************************************************************/

module HazardDetect
(

		input  IDEXMemRead,
		input  IDEXRt,
		input  IFIDRs,
		input  IFIDRt
		
		output reg HazardMux, //dont convince me 
		output reg IFIDWrite,
		output reg PCWrite    //stall
		//output stall
		
);

always@(IDEXMemRead or IDEXRt or IFIDRs or IFIDRt or PCWrite or IFIDWrite or HazardMux)
	begin
	PCWrite = 1;
	IFIDWrite = 1;
   HazardMux =0;
	 if((IDEXMemRead)&&((IDEXRt == IFIDRs) || (IDEXRt == IFIDRt)))
	 begin
	 PCWrite = 1;
	 IFIDWrite = 1;
    HazardMux =0;
	 end 
	end

	endmodule
