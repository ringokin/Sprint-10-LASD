module clock_1Hz(
input clk, reset,
output clk1Hz
);
wire modulo;
contador25bit(clk, reset, modulo);
somador1bit(modulo, reset, clk1Hz);

endmodule
