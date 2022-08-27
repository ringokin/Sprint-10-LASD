module ULA(
input [15:0] SrcA, SrcB,
input [2:0] ULActrl,
output [15:0] ULArslt,
output Z
);
//
wire [15:0] andR, orR, addR, subtR, SLTR, saida;
assign ULArslt = saida;

mux16bit1p8 saida8bit(andR, orR, addR, 16'b0, 16'b0, 16'b0, subtR, SLTR, ULActrl, saida);

assign andR = SrcA & SrcB;
assign orR  = SrcA | SrcB;
assign addR = SrcA + SrcB;
assign subtR= SrcA + ~(SrcB) + 16'b1;
assign SLTR[0] = SrcA < SrcB;
assign SLTR[15:1] = 15'b0;


assign Z = !saida;


endmodule
