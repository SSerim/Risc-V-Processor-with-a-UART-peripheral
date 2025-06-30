module RISCV_Memory (
    input         clk,
    input         MemWrite,
    input         MemRead,
    input  [1:0]  Size,         // 00 = byte, 01 = half, 10 = word
    input         UnsignedOp,   // 1 = unsigned, 0 = signed
    input  [31:0] Address,
    input  [31:0] WriteData,
    output reg [31:0] ReadData
);

reg [31:0] memory [1031:0]; // 1KB memory

// Align address based on access size
integer i ;
initial begin
    for (i = 0; i < 1032; i = i + 1) begin
        memory[i] = 32'd0;  // Initialize all memory to zero
    end
    // Optionally load program code here
end

// Write operation - synchronous
always @(posedge clk) begin
    if (MemWrite) begin
        case (Size)
            2'b00: begin // SB - can write to any byte address
                memory[Address] <= {24'b0, WriteData[7:0]};
            end
            2'b01: begin // SH - must be 2-byte aligned
                
                    memory[Address]     <= {16'b0, WriteData[15:0]};
                    
                
            end
            2'b10: begin // SW - must be 4-byte aligned
                
                    memory[Address]     <= WriteData[31:0];
                     
                
            end
        endcase
    end
end

// Read operation - combinational
always @(*) begin
    if (MemRead) begin
        case (Size)
            2'b00: begin // LB/LBU
                ReadData = UnsignedOp ? 
                    {24'b0, memory[Address][7:0]} :
                    {{24{memory[Address][7]}}, memory[Address][7:0]};
            end
            2'b01: begin // LH/LHU
                ReadData = UnsignedOp ? 
                    {16'b0, memory[Address][15:0]} :
                    {{16{memory[Address][15]}}, memory[Address][15:0]};
            end
            2'b10: begin // LW
                ReadData = memory[Address];
            end
            default: ReadData = 32'd0;
        endcase
    end else begin
        ReadData = 32'd0;
    end
end

endmodule