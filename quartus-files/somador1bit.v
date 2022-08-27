module somador1bit(
input clk, reset,
output reg saida
);

always @(posedge clk or posedge reset) begin
	if (reset)
		saida = 1'd0;
	else
		saida = saida + 1'd1;
end

endmodule 