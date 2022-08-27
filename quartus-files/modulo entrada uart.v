// Code your design here
module redutorCLK(
  input [1:0] opFreq,
input reset, clkIn,
output reg clkOut
);
  //parameter Baud200 = 2'b00;
  //parameter Baud9600 = 2'b01;
  //parameter Baud38400 = 2'b10;
  //parameter Baud115200 = 2'b11;

  //parameter Baud200 = 18'd250000; //17'd125000
  //parameter Baud9600 = 18'd5208;  //17'd2604
  //parameter Baud38400 = 18'd1302; //17'd651
  //parameter Baud115200 = 18'd434; //17'd217

  reg [16:0] contagem;
  reg outAux;
  wire mod;
  wire [16:0] divisor;

  assign divisor = opFreq[1]? (opFreq[0]? 17'd217:17'd651):(opFreq[0]? 17'd2604:17'd125000);

  assign mod = (contagem[16:0] == divisor[16:0]);
  //assign mod = (contagem[13:0] == 25'd25000);
  always @(posedge clkIn or posedge mod or posedge reset) begin
   if (mod | reset)begin
		contagem <= 17'd0;
	end
	else begin
		contagem <= contagem + 17'd1;
	end
  end
  
  always @(posedge mod or posedge reset) begin
    if (reset)
    {clkOut, outAux} = 2'd0;
    else
    {clkOut, outAux} = {clkOut, outAux} + 2'd1;
  end
  

endmodule 


//redutorCLK(opFreq[1:0], resetCLK, clock50M, clockRed);
//assign resetCLK = direct? resetCLKin: 0;


module entradaUART(
  input reset,
  input SerialIn, clock, clk,
  //input [13:0] divisorCLK, 
  output reg[7:0] ParalelOut,
  output resetCLK,
  output reg erro, flag
  );
  
  
  parameter IDLE = 0;
  parameter INICIO = 1;
  parameter LEITURA = 2;
  parameter FIM = 3;
  
  reg BitLido, resetCLKaux;
  reg [1:0] estado;
  reg [3:0] PosAtual;
  assign resetCLK = ~resetCLKaux;
  
  //redutorCLK(divisorCLK[13:0], resetCLK&reset, clock, clk);
  //assign flag = ~estado[0] & ~estado[1];
  
  
  always@(negedge clk or posedge reset or posedge (clock&!resetCLKaux))begin
	if(reset) begin
    erro = 0;
    BitLido = 0;
    resetCLKaux = 0;
    estado = 0;
    PosAtual = 0;
    flag = 0;
	end
	else if (!clk) begin
    erro = 0;
    if (estado == IDLE) begin
      BitLido = SerialIn;
      if (!BitLido) begin
        estado = INICIO;
        resetCLKaux = 1;
      end
    end
	 else if (estado == INICIO)begin
      BitLido = SerialIn;
      if (BitLido)
        estado = IDLE;
      else begin
      	flag = 0;
        estado = LEITURA;
        PosAtual = 3'b000;
      end
    end
    else if (estado == LEITURA)begin
      BitLido = SerialIn;
      ParalelOut[PosAtual] = BitLido;
      if (PosAtual == 3'b111)
        estado = FIM;
      PosAtual = PosAtual + 1;
    end
    else if (estado == FIM) begin
      BitLido = SerialIn;
      if (!BitLido)
        erro = 1;
      flag = 1;
      estado = IDLE;
      resetCLKaux = 0;
    end
	end
  end
  
  
  
endmodule
  
  
  
  
  
  
  
