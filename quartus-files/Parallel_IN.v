module Parallel_IN(
	input [15:0] MemData,
	input [14:0] Address,
	input [15:0] DataIn, DataIn2,
	output[15:0] RegData
);
//
	assign RegData = (Address == 15'h7FFF)?DataIn:((Address == 15'h7FFE)? DataIn2:MemData);
endmodule
