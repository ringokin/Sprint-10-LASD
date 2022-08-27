module ExeTimer(
input clk, reset, H, //posedge clock; NBA H; NAA reset
output reg [31:0] ExTime
);
//
wire CLK;
assign CLK = clk & (~H) & (~reset);

always@(posedge CLK or posedge reset)
begin
	if (reset)
		ExTime = 0;
	else
		ExTime = ExTime + 1;
end

endmodule
