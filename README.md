# Alterações feitas:
## Funções com imediato:
##### Como a maioria das funções seguem o mesmo padrão, foi simples implementá-las, principalmente tomando como base o código addi, o qual já estava implementado. Dessa forma, implementei andi e ori no circuito.
```v
// Dentro do case(OP)
  6'b001100:begin
    RegWrite = 1;
    RegDst = 0;
    ULASrc = 1;
    ULAControl = 3'b000; //amd
    Branch = 0;
    MemWrite = 0;
    MemtoReg = 0;
    Jump = 0;
    Link = 0;
    RegToPC = 0;
  end
  6'b001101:begin
    RegWrite = 1;
    RegDst = 0;
    ULASrc = 1;
    ULAControl = 3'b001; //or
    Branch = 0;
    MemWrite = 0;
    MemtoReg = 0;
    Jump = 0;
    Link = 0;
    RegToPC = 0;
  end
```
## Função jal:
##### Nesse caso, foi necessário adicionar uma saída à ControlUnit, para salvar o PCp1 antes do jump, que foi utilizada nas entradas de 'write adderess' e 'write data' do RegisterFile.
```v
// ControlUnit:
// Dentro do case(OP)
  6'b000011:begin
    RegWrite = 1; //Altera o valor de um registrador ($15)
    RegDst = 0;
    ULASrc = 0;
    ULAControl = 3'b100;
    Branch = 0;
    MemWrite = 0;
    MemtoReg = 0;
    Jump = 1;   //Pula
    Link = 1;   //Salva o PC (no reg $15)
    RegToPC = 0;
  end
```
##### w_Ewd3 e w_Ewa3 substituem w_wd3 e w_wa3, respectivamente, na entrada do RegisterFile.
```v
// TopLevel:
assign w_Ewd3 = w_Link? w_PCp1: w_wd3;
assign w_Ewa3 = w_Link? 4'd15: w_wa3;

```

## Função jr:
##### Foi preciso adicionar mais uma saída saída à ControlUnit, RegToPC. Essa saída atua na entrada do MUX que altera a entrada do RegPC em caso de jumps, adicionando um mux para, em caso de jr, o valor de PC tornar-se o da primeira saída do RegisterFile, rd1.
```v
// ControlUnit
// Dentro do case(Funct)
    6'b001000:begin
      ULAControl = 3'b010;
      Jump = 1;    // Pula
      Link = 0;
      RegToPC = 1; // Usa um registrador para fornecer o novo valor de PC
    end
```
##### w_PCJump entra na entrada 1 do mux cuja entrada de controle recebe w_Jump. Dessa forma, o MUX a seguir seleciona entre pular para um valor imediato ou para a saída 1 do RegisterFile, também determinada na instrução.
```v
// TopLevel:
assign w_PCJump = w_RegToPC? w_rd1SrcA : w_Inst[7:0];
```
## Número de registradores:
##### Como 2 dos 8 registradores que temos são exclusivos, aumentei o número de registradores, aumentando a quantidade dentro do RegisterFile, assim como aumentando 1 bit na largura das entradas de endereçamento desse módulo.
```v
module RegisterFile(
input [15:0] wd3,
>input [3:0] wa3, ra1, ra2, 
input we3, clk,
output [15:0] rd1, rd2,
output reg [7:0] mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7 //Saída para debugging
);
//
reg [15:0] saida1, saida2;
>reg [15:0] memoria [15:0]; 

assign rd1 = saida1;
assign rd2 = saida2;
...
```
## Tamanho da memória e da palavra:
##### Para implementar o filtro de imagem, seria necessária uma memória muito grande para armazenar a imagem. Porém, com uma palavra de 1 byte, não seria possível endereçar posições de memória altos. Portanto, aumentei o tamanho da palavra para 2 bytes (0x0000 a 0xffff) e o número de endereços da memória para 32767 (0x0000 a 0x 7fff) (não fiz até 0xffff porque não cabia, segundo as especificações da placa). Entretanto, também devido às limitações da placa, o tamanho da palavra armazenada na memória precisou ser aumentando somente para 12 bits (0x000 a 0xfff). Essas alterações foram feitas alterando a maioria dis fios de [7:0] para [15:0] e substituindo o módulo de memória por RamDataMem2, que possui as especificações citadas.
#### Wires
```v
wire [3:0] w_Ewa3, w_wa3; // Endereçamento de registradores
wire [7:0] w_PCp1, w_PC, w_m1, w_nPC, w_PCJump, w_PCBranch; // Fios relacionados ao PC se mantiveram inalterados
>wire [15:0] w_Ewd3, w_wd3, w_rd2, w_rd1SrcA, w_ULAResultWd3, w_SrcB, w_DataOut, w_DataOut2, w_DataIn, w_DataIn2, w_RegData, w_RData; //Palavras
```
#### Módulos
```v
module RegisterFile(
>input [15:0] wd3,
input [3:0] wa3, ra1, ra2, 
input we3, clk,
>output [15:0] rd1, rd2,
output reg [7:0] mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7
);
//
>reg [15:0] saida1, saida2;
>reg [15:0] memoria [15:0]; 

assign rd1 = saida1;
assign rd2 = saida2;

always@(posedge clk)
begin
	>if (wa3 != 4'b0000)
	begin
		if (we3)
		begin
		memoria[wa3] = wd3;
		end
	end
end
always@(*)
begin
	>memoria[0] = 16'b0;
	saida1 = memoria[ra1];
	saida2 = memoria[ra2];
	
	>{mem0, mem1} = memoria[1];
	>{mem2, mem3} = memoria[2];
	>{mem4, mem5} = memoria[3];
	>{mem6, mem7} = memoria[15];
end

endmodule
```
```v
module ULA(
>input [15:0] SrcA, SrcB,
input [2:0] ULActrl,
>output [15:0] ULArslt,
output Z
);
//
>wire [15:0] andR, orR, addR, subtR, SLTR, saida;
assign ULArslt = saida;

>mux16bit1p8 saida8bit(andR, orR, addR, 16'b0, 16'b0, 16'b0, subtR, SLTR, ULActrl, saida);
...
```
```v
module mux16bit1p8(
>input [15:0] entrada1, entrada2, entrada3, entrada4, entrada5, entrada6, entrada7, entrada8, 
input [2:0] ctrl,
>output [15:0] saida
);
//

assign saida = ctrl[2]?ctrl[1]?ctrl[0]?entrada8:entrada7:
										 ctrl[0]?entrada6:entrada5:
							  ctrl[1]?ctrl[0]?entrada4:entrada3:
										 ctrl[0]?entrada2:entrada1;


endmodule
```
...
## Nova saída e entrada seriais:
##### Tendo memória em abundância devido à nova memória e a necessidade de uma conexão direta da CPU com os módulos UART, foi necessário adicionar uma nova saída e uma nova entrada seriais.
```v
module Parallel_IN(
	input [15:0] MemData,
	input [14:0] Address,
	input [15:0] DataIn, DataIn2,
	output[15:0] RegData
);
//
	assign RegData = (Address == 15'h7FFF)? DataIn:((Address == 15'h7FFE)? DataIn2:MemData); // 0x7ffe adicionado como outra entrada
endmodule
```
```v
module Parallel_OUT(
  input clk,
	input [15:0] RegData,
	input [14:0] Address,
	input we,
	output reg [15:0] DataOut, DataOut2,
	output wren
);
//
	wire fioA, fioB;
	// Para adicionarmos 7ffe, ignoramos o bit menos significativo:
	assign fioA = (Address[14:1] == 15'h4FFF)?1:0; //FFFF ou FFFE
	assign fioB = fioA&we;
	assign wren = ~fioA&we;
	
	always@(posedge (clk&fioB))
	begin
		if (Address[0]) // Diferenciamos as saídas seriais baseado no bit menos significativo
			DataOut = RegData[15:0];
		else
			DataOut2 = RegData[15:0];
	end
endmodule
```
## Circuito redutor de clock:
##### Esse circuito reduz o clock para o que será utilizado nos módulos UART dependendo do Baud rate utilizado, sendo resetado sempre que a leitura acabar. O clock é um contador cujo módulo é o quociente da frequência do clock utilizado como base (50MHz) e o Baud rate solicitado (200, 9600, 38400 ou 115200). Por questões de precisão sobre o clock, utilizei o dobro da frequência solicitada para alimentar um segundo somador, cujo resultado viria a ser a saída.
```v
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

  assign divisor = opFreq[1]? (opFreq[0]? 17'd217:17'd651):(opFreq[0]? 17'd2604:17'd125000); //Define o divisor de cada Baud rate

  assign mod = (contagem[16:0] == divisor[16:0]);
  //assign mod = (contagem[13:0] == 25'd25000);
  always @(posedge clkIn or posedge mod or posedge reset) begin //mod = clock com o dobro da frequência
   if (mod | reset)begin
		contagem <= 17'd0;
	end
	else begin
		contagem <= contagem + 17'd1;
	end
  end
  
  always @(posedge mod or posedge reset) begin //usa mod para gerar o clock com a frequência certa
    if (reset)
    {clkOut, outAux} = 2'd0;
    else
    {clkOut, outAux} = {clkOut, outAux} + 2'd1;
  end
endmodule 
```

## Módulo de entrada UART:
##### Esse circuito é uma máquina de estados:
#### IDLE: Utiliza o clock original de 50MHz para detectar quando aparecer o bit 0 na entrada. Nesse momento, o clock de 50MHz é "desativado" e o clock no Baud rate é ativado;
#### INICIO: Verifica se o primeiro bit lido é realmente 0 ou se foi um erro de leitura ou transmissão. Em caso, de erro, retorna para o IDLE com as mudanças revertidas. Caso contrário, ele desabilita a flag de permissão de leitura e zera o contador que determina as posições onde cada bit será salvo;
#### LEITURA: Lê cada um dos bits transmitidos, do menos significativo para o mais significativo, e armazena cada um em seu devido registrador de saída. No 8° bit a leitura é encerrada;
#### FIM: Verifica se o último bit é realmente 1 ou se houve erro na recepção dos bits. Além disso, atualiza o valor da flag de leitura para, nesse momento, permitir a leitura do bit, desativa o clock no Baud rate e ativa novamente o clock de 50MHz.
##### Os 3 últimos estados utilizam a borda de descida do clock. Isso porque, como o clock possui frequência igual à Baud rate e é sincronizado praticamente na borda de subida do start bit da transmissão, a borda de subida do clock ocorrerá ao mesmo tempo que a mudança de valor da entrada e poderia nos dar valores inconfiáveis. Por outro lado, a borda de descida do clock aparecerá praticamente no meio da transmissão do bit e, portanto, no momento mais confiável para a obtenção da informação.
```v
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
  
  >always@(negedge clk or posedge reset or posedge (clock&!resetCLKaux))begin
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
        >resetCLKaux = 1;
      end
    end
	 else if (estado == INICIO)begin
      BitLido = SerialIn;
      >if (BitLido)
        estado = IDLE;
      else begin
      	>flag = 0;
        estado = LEITURA;
        >PosAtual = 3'b000;
      end
    end
    else if (estado == LEITURA)begin
      BitLido = SerialIn;
      >ParalelOut[PosAtual] = BitLido;
      if (PosAtual == 3'b111)
        estado = FIM;
      >PosAtual = PosAtual + 1;
    end
    else if (estado == FIM) begin
      BitLido = SerialIn;
      if (!BitLido)
        erro = 1;
      >flag = 1;
      estado = IDLE;
      >resetCLKaux = 0;
    end
	end
  end
endmodule
```

## Módulo de saída UART:
##### Também é composto por uma máquina de estados:
#### IDLE: Nesse estado, ele espera a permissão para escrever. Quando recebida a permissão (H == 1), a entrada do módulo, paralela, é salva em um byte de registradores para ser posteriormente transmitida e o contador que determina as posições dos bits que serão escritos é zerado;
#### INICIO: Transmite o start bit;
#### ESCRITA: Transmite cada um dos bits salvos;
#### FIM: Transmite o end bit;
##### Uma das saídas é uma flag que fica ligada quando o módulo está em IDLE e está apto a receber um novo byte para transmitir.
```v
module saidaUART(
  input reset,
  input [7:0] ParalelIn,
  input H, clock, 
  output reg SerialOut,
  output Idle
);
  parameter IDLE = 0;
  parameter INICIO = 1;
  parameter ESCRITA = 2;
  parameter FIM = 3;
  
  reg resetCLK;
  reg [1:0] estado;
  reg [3:0] PosAtual;
  reg [7:0] entrada;
  wire clkAux;
  
  assign Idle = (estado == IDLE)?1:0;
  
  always@(negedge clock or posedge reset)begin
	 if (reset) begin
		 resetCLK = 0;
		 estado = 0;
		 PosAtual = 0;
     SerialOut = 1;
	 end
	 >else if ((estado == IDLE) & H)begin
      >entrada = ParalelIn;
      >PosAtual = 3'b000;
      estado = INICIO;
    end
    else if (estado == INICIO)begin
      >SerialOut = 0;
      estado = ESCRITA;
    end
    else if (estado == ESCRITA)begin
      >SerialOut = entrada[PosAtual];
      if (PosAtual == 3'b111)
        estado = FIM;
      >PosAtual = PosAtual + 1;
    end
    else if (estado == FIM) begin
      >SerialOut = 1;
      estado = IDLE;
    end
  end
  
endmodule
```
