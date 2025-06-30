module RISCV_ALU 
    (
	    input  [31:0] A, B,
        input  [3:0]  ALUControl,
        output reg [31:0] Result
        //output reg [2:0] ALUFlags //Zero flag , Compares
    );
localparam ADD=4'b0000,
		  SUB=4'b0001,
		  AND=4'b0010,
		  OR=4'b0011,
		  XOR=4'b0100,
		  SLL=4'b0101,
		  SRL=4'b0110,
		  SRA=4'b0111,
		  SLT=4'b1000,
		  SLTU=4'b1001;
		  



	 
always@(*) begin


    //ALUFlags[2] = (A == B) ? 1 : 0;    //beq(1), bne(0)
    //ALUFlags[1] = (A < B) ? 1 : 0;     //bltu(1), bgeu(0)
    //ALUFlags[0] = ($signed(A) < $signed(B)) ? 1 : 0; //blt(1), bge(0)

	case(ALUControl)
		ADD:begin
			Result = A + B;
			
		end
		SUB:begin
			Result = A - B;


		end
		AND:begin
			Result = A & B;
		end
		OR:begin
			Result = A | B; 
		end
		XOR:begin
			Result = A ^ B;
		end
		SLL:begin
            Result = A << B[4:0];
        end
			
		SRL:begin
            Result = A >> B[4:0];   
        end
		SRA:begin
			Result = $signed(A) >>> B[4:0]; 
		end
		SLT:begin
			Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
		end
		SLTU:begin
			Result = (A < B) ? 32'd1 : 32'd0;
		end
		
		default:begin
		Result = 32'd0;
		
		
		end
	endcase
end
	 
endmodule	 