`default_nettype none //Comando para desabilitar declaração automática de wires
module Mod_Teste (
//Clocks
input CLOCK_27, CLOCK_50,
//Chaves e Botoes
input [3:0] KEY,
input [17:0] SW,
//Displays de 7 seg e LEDs
output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
output [8:0] LEDG,
output [17:0] LEDR,
//Serial
output UART_TXD,
input UART_RXD,
inout [7:0] LCD_DATA,
output LCD_ON, LCD_BLON, LCD_RW, LCD_EN, LCD_RS,
//GPIO
inout [35:0] GPIO_0, GPIO_1
);

// Início da edição

wire w_ULASrc, w_RegDst, w_RegWrite, clk, w_MemtoReg, w_MemWrite, w_PCSrc, w_Jump, w_Branch, w_Z, w_We, w_RegToPC, w_Link;
wire [2:0] w_ULAControl;
wire [3:0] w_Ewa3, w_wa3; //sprint 10
wire [7:0] w_PCp1, w_PC, w_m1, w_nPC, w_PCJump, w_PCBranch;
wire [15:0] w_Ewd3, w_wd3, w_rd2, w_rd1SrcA, w_ULAResultWd3, w_SrcB, w_DataOut, w_DataOut2, w_DataIn, w_DataIn2, w_RegData, w_RData; //sprint 10
wire [31:0] w_Inst;

assign w_PCp1 = w_PC + 1;
assign w_PCBranch = w_PCp1 + w_Inst[7:0];
assign w_m1 = w_PCSrc? w_PCBranch : w_PCp1;
assign w_nPC = w_Jump? w_PCJump : w_m1;
assign w_PCJump = w_RegToPC? w_rd1SrcA : w_Inst[7:0];  //sprint 10
RegPC(w_nPC, clk, w_PC);

	RamDataMem2(w_ULAResultWd3, CLOCK_50, w_rd2, w_We, w_RData); //sprint 10
	RomInstMem(w_PC, CLOCK_50, w_Inst);
	assign w_wd3 = w_MemtoReg? w_RegData : w_ULAResultWd3;
	
	ControlUnit(w_Inst[31:26], w_Inst[5:0], w_RegToPC, w_Link, w_Jump, w_MemtoReg, w_MemWrite, w_Branch,w_ULAControl, w_ULASrc, w_RegDst, w_RegWrite);
	RegisterFile(w_Ewd3, w_Ewa3, w_Inst[25:21], w_Inst[20:16], w_RegWrite, clk, w_rd1SrcA, w_rd2, w_d0x0, w_d0x1, w_d0x2, w_d0x3, w_d1x0, w_d1x1, w_d1x2, w_d1x3);
	assign w_Ewd3 = w_Link? w_PCp1: w_wd3; //sprint 10
	assign w_Ewa3 = w_Link? 4'd15: w_wa3;  //sprint 10
	
		Parallel_OUT(clk, w_rd2, w_ULAResultWd3, w_MemWrite, w_DataOut, w_DataOut2, w_We); //sprint 10
		Parallel_IN(w_RData, w_ULAResultWd3, w_DataIn, w_DataIn2, w_RegData); //sprint 10
		assign w_d1x4 = w_DataOut[7:0];
		
		
assign w_wa3 = w_RegDst? w_Inst[15:11]:w_Inst[20:16];
assign w_SrcB = w_ULASrc? w_Inst[15:0]:w_rd2;
ULA(w_rd1SrcA, w_SrcB, w_ULAControl, w_ULAResultWd3, w_Z);

assign w_PCSrc = w_Branch & w_Z;


//assign clk = KEY[1];
//clock_1Hz(CLOCK_50, 0, clk);

assign clk = CLOCK_50;
//assign clk = SW[8];


assign LEDG[0] = w_Z;
//assign LEDR[0] = w_Jump;
assign LEDR[0] = w_DataOut[0];
assign LEDR[3] = w_Branch;

assign w_d0x4 = w_PC;
assign LEDR[9:4] = {w_RegWrite, w_RegDst, w_ULASrc, w_ULAControl[2:0]};

assign LEDR[1] = w_MemtoReg;
assign LEDR[2] = w_MemWrite;

//desnecessario:



//Debugging para testar a entrada serial
//wire [7:0] qqrcs0, qqrcs1, qqrcs2, qqrcs3, qqrcs4, qqrcs5, qqrcs6, qqrcs7;
//reg [63:0] contador_teste;
//always@(posedge UART_RXD)begin
//	contador_teste <= contador_teste + 64'd1;
//end
//assign {w_d0x0, w_d0x1, w_d0x2, w_d0x3, w_d1x0, w_d1x1, w_d1x2, w_d1x3} = contador_teste;
//
//assign LEDG[6] = UART_RXD;

reg erroUART, UARTler, UARTescrever;
wire SerialIn, SerialOut, direct, resetCLKuart, erroUARTin, flagUARTin, flagUARTout, UARToutIdle, FlagFiltro, FlagLido, FlagEscrever, redCLK, resetCLKin;
wire [1:0] opFreq;
wire [7:0] ParalelIn, ParalelOut;

assign w_DataIn2[10] = direct;
assign w_DataIn2[9] = UARToutIdle;
assign w_DataIn2[8] = 1;
//assign w_DataIn2[8] = UARTler;
assign w_DataIn2[7:0] = ParalelIn;
assign ParalelOut = w_DataOut2[7:0];
assign FlagFiltro = w_DataOut2[8];
assign FlagLido = w_DataOut2[9];
assign FlagEscrever = w_DataOut2[10];



always@(posedge UARToutIdle or posedge FlagEscrever)begin
	UARTescrever = ~UARTescrever;
end

always@(posedge FlagLido or posedge flagUARTin)begin
	UARTler = ~UARTler;
end

assign {direct, opFreq} = SW[16:14]; 
//assign LEDG[1] = erroUART;
//always@(posedge erroUARTin or posedge KEY[1])begin
//	if (KEY[1])
//		erroUART = 0;
//	else
//		erroUART = 1;
//end

redutorCLK(opFreq, resetCLKuart, CLOCK_50, redCLK);
assign resetCLKuart = direct? resetCLKin: 0;
assign SerialIn = UART_RXD;
assign UART_TXD = SerialOut;
entradaUART(0, SerialIn, CLOCK_50, redCLK, ParalelIn, resetCLKin, erroUARTin, flagUARTin);
saidaUART(0, ParalelOut, UARTescrever, redCLK, SerialOut, UARToutIdle);


//Fim da edição

assign GPIO_1 = 36'hzzzzzzzzz;
assign GPIO_0 = 36'hzzzzzzzzz;
assign LCD_ON = 1'b1;
assign LCD_BLON = 1'b1;
wire [7:0] w_d0x0, w_d0x1, w_d0x2, w_d0x3, w_d0x4, w_d0x5,
w_d1x0, w_d1x1, w_d1x2, w_d1x3, w_d1x4, w_d1x5;
LCD_TEST MyLCD (
.iCLK ( CLOCK_50 ),
.iRST_N ( KEY[0] ),
.d0x0(w_d0x0),.d0x1(w_d0x1),.d0x2(w_d0x2),.d0x3(w_d0x3),.d0x4(w_d0x4),.d0x5(w_d0x5),
.d1x0(w_d1x0),.d1x1(w_d1x1),.d1x2(w_d1x2),.d1x3(w_d1x3),.d1x4(w_d1x4),.d1x5(w_d1x5),
.LCD_DATA( LCD_DATA ),
.LCD_RW ( LCD_RW ),
.LCD_EN ( LCD_EN ),
.LCD_RS ( LCD_RS )
);
//---------- modifique a partir daqui --------
endmodule
