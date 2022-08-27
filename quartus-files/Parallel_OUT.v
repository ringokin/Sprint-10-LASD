module Parallel_OUT(
input clk,
	input [15:0] RegData,
	input [14:0] Address,
	input we,
	output reg [15:0] DataOut, DataOut2,
	output wren
);
//
	wire fioA, fioB;
	
	assign fioA = (Address[14:1] == 15'h4FFF)?1:0; //7FFF ou 7FFE
	assign fioB = fioA&we;
	assign wren = ~fioA&we;
	
	always@(posedge (clk&fioB))
	begin
		if (Address[0])
			DataOut = RegData[15:0];
		else
			DataOut2 = RegData[15:0];
	end
endmodule
