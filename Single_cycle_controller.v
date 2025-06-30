module Single_cycle_controller (
    input clk,
    input reset,
    input [3:0] Cond,         // Instruction condition
    input [1:0] OP,           // Bits [27:26] of instruction
    input [5:0] Funct,        // Bits [25:20]
    input [3:0] ALUFlags,     // {N,Z,C,V}
    input [3:0] Rd,

    
    
    output reg MemWrite,
    output reg RegWrite,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg PCSrc,
    
    output reg [1:0] RegSrc,
    output reg [1:0] ImmSrc,
    
    output reg [3:0] ALUControl,
    output reg link,
    output reg bx_signal,
    output reg rot_signal
    
    
);

    //Internal Signals
    reg CondEx;
    reg ALUOp;
    reg RegW;
    reg MemW;
    
    reg Branch;
    reg [1:0] Flags;

    wire zero;

    //ALU Decoder

    always @(*) begin
        Flags = 2'b00;
        case(ALUOp)
        1'b1: begin //Data Processing
                case (Funct[4:1])
                    4'b0100: begin
                        ALUControl = 4'b0100; // ADD

                        end
                    4'b0010: ALUControl = 4'b0010; // SUB
                    4'b0000: ALUControl = 4'b0000; // AND
                    4'b1100: ALUControl = 4'b1100; // ORR
                    4'b1010: begin // CMP
                            ALUControl = 4'b0010;
                            Flags = 2'b11;
                        end
                    4'b1101: begin // MOV
                            ALUControl = 4'b1101;
                        
                        end

                    
                    endcase

        end
        1'b0: begin // Memory not DP
            ALUControl = 4'b0100; //addition

        end
        default ALUControl = 4'b0100;
        endcase

    end
  

    //Conditional logic for controller 
    //Flags Register
    Register_rsten #(1) Flags3_2 (
        .clk(clk),
        .reset(reset),
        .we(Flags[1]),
        .DATA(ALUFlags[2]),
        .OUT(zero)
    );
    

    always @(*) begin
        CondEx = 0;
        case (Cond)
            4'b0000: CondEx = zero;               // EQ: equal
            4'b0001: CondEx = ~zero;              // NE: not equal

            4'b1110: CondEx = 1;               // AL: always
            default: CondEx = 1;               // always
        endcase
    end



    wire PCS = ((Rd == 4'b1111) && RegW ) || Branch; //Important FOR PC WRITING

    
    always @(*) begin
        RegWrite = RegW & CondEx;
        MemWrite = MemW & CondEx;
        PCSrc = PCS & CondEx;
    end

    // --- Control signals default ---

    //Main Decoder
    always @(*) begin
        // Defaults (everything off unless needed)
        
        
        Branch = 0;
        
        MemW = 0;
        RegW = 0;
        MemtoReg = 0;
        ALUSrc = 0;
        ImmSrc= 2'b00;
        
        RegSrc = 2'b00;

        rot_signal = 0;
        bx_signal = 0;
        link = 0;
        
        ALUOp= 0;
        

        case (OP)
            2'b00: begin // Data-Processing
                RegW     = 1;
                if (Funct[5]) begin
                    ImmSrc= 2'b00;
                    ALUSrc= 1'b1;
                    rot_signal = 1'b1;
                end
                case (Funct[4:1])

                    4'b1010: begin //CMP
                        RegW = 0;

                    end
                    4'b1101:begin //MOV
                        RegW = 1;
                        MemtoReg = 0;
                        link=0;
                         if (Funct[5]) begin
                                
                            ALUSrc = 1'b1;
                            rot_signal = 1'b1;
                        end else begin
                            ALUSrc = 1'b0;
                        end
                    end  

                endcase

                ALUOp    = 1;
                
               
                
                if ((Rd == 4'b1111)&(Funct[5:0]== 6'b010010)) begin
                        bx_signal = 1; // BX
                end else begin
                        bx_signal = 0; // BX
                end
            end
            2'b01: begin // Memory
                ALUOp    = 0;


                if (!Funct[5])begin
                    ALUSrc= 1'b1;
                    rot_signal = 1'b0;
                    ImmSrc = 2'b01;
                end else begin
                    ALUSrc = 0;;       
                end
                
                if (Funct[0]) begin
                        MemtoReg = 1; // LDR
                        RegW = 1;
                end else begin
                        MemW = 1; // STR
                        RegSrc = 2'b10;
                end
            end
            2'b10: begin // Branch
                Branch= 1;
                ImmSrc = 2'b10;
                rot_signal = 1'b0;
                RegSrc = 2'b01;
                ALUSrc = 1'b1;
                
                MemtoReg= 1'b0;
                if (Funct[4]) begin // BL
                    link = 1;
                    RegW = 1;
                end
            end
        endcase
    end


endmodule