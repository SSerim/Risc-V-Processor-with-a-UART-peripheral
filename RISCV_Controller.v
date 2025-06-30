module RISCV_Controller (
    input  [6:0] opcode,

    input  [2:0] funct3,

    input  [6:0] funct7,
    input  [2:0] ALUFlags,
    
    output   reg   RegWrite,
    output   reg   MemWrite,
    output   reg   MemRead,
    output   reg   PCSrc,
    output   reg [1:0]    ResultSrc,
    output   reg [3:0]     ALUControl,
    output   reg      ALUSrcB,
    output   reg      ALUSrcA,
    output   reg [1:0] Size, // LB , LW ,LH onlar icin
    output   reg  Unsigned, // belki memory için lazım olabilir
    output   reg[2:0]   ImmSrc ,
    // UART
    output reg UART_sel, uart_start, uart_read_en,
    input [31:0] addr
);

// Internal signal to determine ALU operation type
reg [3:0] alu_op;


reg Cond;

reg Branch;
reg Jump;


always @(*) begin
    PCSrc = (Branch && Cond) || Jump;
    ALUControl = alu_op;
end



always @(*) begin
    // Default values
    Unsigned = 0;
    RegWrite = 0;
    MemWrite = 0;
    MemRead = 0;
    Cond = 0;
    ALUSrcA = 0;
    ALUSrcB = 0;
    Branch = 0;
    Jump = 0;
    ResultSrc = 2'b00; // 00 = ALU, 01 = Memmory
    ImmSrc = 3'b000;
    alu_op = 4'b0000;
    UART_sel = 0;
    uart_start = 0;
    uart_read_en = 0;
    Size = 2'b00;
    case (opcode)
        7'b0110011: begin // R-type
            RegWrite = 1;
            ResultSrc = 2'b01;
            ALUSrcA = 0;
            ALUSrcB = 0;
            case ({funct7, funct3})
                10'b0000000_000: alu_op = 4'b0000; // ADD
                10'b0100000_000: alu_op = 4'b0001; // SUB
                10'b0000000_111: alu_op = 4'b0010; // AND
                10'b0000000_110: alu_op = 4'b0011; // OR
                10'b0000000_100: alu_op = 4'b0100; // XOR
                10'b0000000_001: alu_op = 4'b0101; // SLL
                10'b0000000_101: alu_op = 4'b0110; // SRL
                10'b0100000_101: alu_op = 4'b0111; // SRA
                10'b0000000_010: alu_op = 4'b1000; // SLT
                10'b0000000_011: alu_op = 4'b1001; // SLTU
                default:         alu_op = 4'b1111; // Invalid
            endcase
        end

        7'b0010011: begin // I-type ALU (ADDI, ANDI, etc.)
            RegWrite = 1;
            ResultSrc = 2'b01;
            ALUSrcA = 0;
            ALUSrcB = 1;
            ImmSrc = 3'b000;
            case (funct3)
                3'b000: alu_op = 4'b0000; // ADDI
                3'b111: alu_op = 4'b0010; // ANDI
                3'b110: alu_op = 4'b0011; // ORI
                3'b100: alu_op = 4'b0100; // XORI
                3'b001: alu_op = 4'b0101; // SLLI
                3'b101: begin
                    if (funct7 == 7'b0000000) alu_op = 4'b0110; // SRLI
                    else if (funct7 == 7'b0100000) alu_op = 4'b0111; // SRAI
                end
                3'b010: alu_op = 4'b1000; // SLTI
                3'b011: alu_op = 4'b1001; // SLTIU
            endcase
        end

        7'b0000011: begin // Load (LW, LH[U], LB[U])
            RegWrite = 1;
            MemWrite = 0;
            ALUSrcB = 1;
            MemRead = 1;
            ResultSrc = 2'b00;  // Select memory data (input_0) from LastMux
            ImmSrc = 3'b000;
            alu_op = 4'b0000; // ADD for address calc

            case (funct3)
                3'b000:   Size = 2'b00;            // LB
                3'b001:   Size = 2'b01;       // LH
                3'b010:   begin //LW
                    
                    Size = 2'b10; 
                    if (addr == 32'h00000404) begin
                        UART_sel = 1;
                        uart_read_en = 1;
                end        

                end
                3'b100:   begin
                    Size = 2'b00;      // LBU
                    Unsigned = 1;
                end
                3'b101:  begin 
                    Size = 2'b01;       // LHU  
                    Unsigned = 1;  
                end
                               
            endcase

        end

        7'b0100011: begin // Store (SW, SH, SB)
            MemWrite = 1;
            ALUSrcB = 1;
            MemRead = 0;
            ImmSrc = 3'b001; // S- TYPE
            alu_op = 4'b0000;   // ADD for address calc
            if (funct3 == 3'b000)begin //SB
                Size  = 2'b00;
                uart_start = (addr == 32'h00000400);
            end else if (funct3 == 3'b001)begin //SH
                Size  = 2'b01;
            end else if (funct3 == 3'b010)begin //SW
                Size  = 2'b10;
            end
        end

        7'b1100011: begin // Branch
            Branch = 1;
            ALUSrcA = 1;
            ALUSrcB = 1;
            ImmSrc = 3'b010; // B - TYPE
            alu_op = 4'b0000; // ALU ADD

            case (funct3)
                3'b000: Cond = ALUFlags[2];               // BEQ: equal
                3'b001: Cond = ~ALUFlags[2];              // BNE: not equal
                3'b100: Cond = ALUFlags[0];              // BLT: not equal
                3'b101: Cond = ~ALUFlags[0];            // BGE: not equal
                3'b110: Cond = ALUFlags[1];            // BLTU: not equal  
                3'b111: Cond = ~ALUFlags[1];            // BGEU: not equal
            
                default: Cond = 1;               // always
            endcase
        end

        7'b1101111: begin // JAL
            RegWrite = 1;
            Jump = 1;
            ALUSrcA = 1;
            ALUSrcB = 1;
            ResultSrc = 2'b10;
            ImmSrc = 3'b100;
        end

        7'b1100111: begin // JALR
            RegWrite = 1;
            Jump = 1;
            ALUSrcA = 0;
            ALUSrcB = 1;
            ResultSrc = 2'b10;
            ImmSrc = 3'b000;
        end

        7'b0110111: begin // LUI
            RegWrite = 1;
            
            
            ResultSrc = 2'b11; // Custom: Imm upper bits
            ImmSrc = 3'b011;
        end

        7'b0010111: begin // AUIPC
            RegWrite = 1;
            ALUSrcA = 1;
            ALUSrcB = 1;
            ResultSrc = 2'b01; // PC + imm
            ImmSrc = 3'b011;
        end

        default: begin
            // Handle unknown opcode
        end
    endcase
end

endmodule
