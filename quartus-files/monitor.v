module monitor(
input [3:0] num,
output reg [0:6] img
);

always @ (num) begin
	case (num[3:0])
		'b0000: img = 'b0000001;
		'b0001: img = 'b1001111;
		'b0010: img = 'b0010010;
		'b0011: img = 'b0000110;
		'b0100: img = 'b1001100;
		'b0101: img = 'b0100100;
		'b0110: img = 'b0100000;
		'b0111: img = 'b0001111;
		'b1000: img = 'b0000000;
		'b1001: img = 'b0000100;
		'b1010: img = 'b0001000;
		'b1011: img = 'b1100000;
		'b1100: img = 'b0110001;
		'b1101: img = 'b1000010;
		'b1110: img = 'b0110000;
		'b1111: img = 'b0111000;
		default: img = 'b1111111;
	endcase
end
endmodule
