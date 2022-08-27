module mux16bit1p8(
input [15:0] entrada1, entrada2, entrada3, entrada4, entrada5, entrada6, entrada7, entrada8, 
input [2:0] ctrl,
output [15:0] saida
);
//

assign saida = ctrl[2]?ctrl[1]?ctrl[0]?entrada8:entrada7:
										 ctrl[0]?entrada6:entrada5:
							  ctrl[1]?ctrl[0]?entrada4:entrada3:
										 ctrl[0]?entrada2:entrada1;


endmodule
