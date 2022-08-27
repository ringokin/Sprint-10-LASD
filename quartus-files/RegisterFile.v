module RegisterFile(
input [15:0] wd3,
input [3:0] wa3, ra1, ra2, 
input we3, clk,
output [15:0] rd1, rd2,
output reg [7:0] mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7
);
//
reg [15:0] saida1, saida2;
reg [15:0] memoria [15:0]; 

assign rd1 = saida1;
assign rd2 = saida2;

always@(posedge clk)
begin
	if (wa3 != 4'b0000)
	begin
		if (we3)
		begin
		memoria[wa3] = wd3;
		end
	end
end
always@(*)
begin
	memoria[0] = 16'b0;
	saida1 = memoria[ra1];
	saida2 = memoria[ra2];
	
	{mem0, mem1} = memoria[1];
	{mem2, mem3} = memoria[2];
	{mem4, mem5} = memoria[3];
	{mem6, mem7} = memoria[15];
end

endmodule
