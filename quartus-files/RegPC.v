module RegPC(
	input [7:0] PCin,
	input clk,
	output reg [7:0] PC
);
//
	always@(posedge clk)
		PC = PCin;
endmodule
