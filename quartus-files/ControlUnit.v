module ControlUnit(
	input [5:0] OP, Funct,
	output reg RegToPC, Link, Jump, MemtoReg, MemWrite, Branch,
	output reg [2:0] ULAControl,
	output reg ULASrc, RegDst, RegWrite
);
//



	always@(*)
	begin
		case(OP)
			6'b000000:begin
				RegWrite = 1;
				RegDst = 1;
				ULASrc = 0;
				Branch = 0;
				MemWrite = 0;
				MemtoReg = 0;
				case(Funct)
					6'b100000:begin
						ULAControl = 3'b010;
						Jump = 0;
						Link = 0;
						RegToPC = 0;
					end
					6'b100010:begin
						ULAControl = 3'b110;
						Jump = 0;
						Link = 0;
						RegToPC = 0;
					end
					6'b100100:begin
						ULAControl = 3'b000;
						Jump = 0;
						Link = 0;
						RegToPC = 0;
					end
					6'b100101:begin
						ULAControl = 3'b001;
						Jump = 0;
						Link = 0;
						RegToPC = 0;
					end
					6'b101010:begin
						ULAControl = 3'b111;
						Jump = 0;
						Link = 0;
						RegToPC = 0;
					end
					6'b001000:begin
						ULAControl = 3'b010;
						Jump = 1;
						Link = 0;
						RegToPC = 1;
					end
					default:begin
						ULAControl = 3'b100;
						Jump = 0;
						Link = 0;
						RegToPC = 0;
					end
				endcase
			end
			6'b100011:begin
				RegWrite = 1;
				RegDst = 0;
				ULASrc = 1;
				ULAControl = 3'b010;
				Branch = 0;
				MemWrite = 0;
				MemtoReg = 1;
				Jump = 0;
				Link = 0;
				RegToPC = 0;
			end
			6'b101011:begin
				RegWrite = 0;
				RegDst = 0;
				ULASrc = 1;
				ULAControl = 3'b010;
				Branch = 0;
				MemWrite = 1;
				MemtoReg = 0;
				Jump = 0;
				Link = 0;
				RegToPC = 0;
			end
			6'b000100:begin
				RegWrite = 0;
				RegDst = 0;
				ULASrc = 0;
				ULAControl = 3'b110;
				Branch = 1;
				MemWrite = 0;
				MemtoReg = 0;
				Jump = 0;
				Link = 0;
				RegToPC = 0;
			end
			6'b001000:begin
				RegWrite = 1;
				RegDst = 0;
				ULASrc = 1;
				ULAControl = 3'b010;
				Branch = 0;
				MemWrite = 0;
				MemtoReg = 0;
				Jump = 0;
				Link = 0;
				RegToPC = 0;
			end
			6'b001100:begin
				RegWrite = 1;
				RegDst = 0;
				ULASrc = 1;
				ULAControl = 3'b000;
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
				ULAControl = 3'b001;
				Branch = 0;
				MemWrite = 0;
				MemtoReg = 0;
				Jump = 0;
				Link = 0;
				RegToPC = 0;
			end
			6'b000010:begin  //J
				RegWrite = 0;
				RegDst = 0;
				ULASrc = 0;
				ULAControl = 3'b100;
				Branch = 0;
				MemWrite = 0;
				MemtoReg = 0;
				Jump = 1;
				Link = 0;
				RegToPC = 0;
			end
			6'b000011:begin  //Jal
				RegWrite = 1;
				RegDst = 0;
				ULASrc = 0;
				ULAControl = 3'b100;
				Branch = 0;
				MemWrite = 0;
				MemtoReg = 0;
				Jump = 1;
				Link = 1;
				RegToPC = 0;
			end
			default:begin
				RegWrite = 0;
				RegDst = 0;
				ULASrc = 0;
				ULAControl = 3'b100;
				Branch = 0;
				MemWrite = 0;
				MemtoReg = 0;
				Jump = 0;
				Link = 0;
				RegToPC = 0;
			end
		endcase
	end

endmodule
