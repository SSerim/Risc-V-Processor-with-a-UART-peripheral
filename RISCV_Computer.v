module RISCV_Computer(
    input clk,
    input reset,
    input [4:0] debug_reg_select,
    output [31:0] fetchPC,
    
    output [31:0] debug_reg_out,

    input rx,clk_100,
    output tx
);

    wire [2:0] ALUFlags;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [6:0] op;
    
    wire [3:0] ALUControl;
    wire RegWrite,MemWrite,PCSrc,ALUSrcB,ALUSrcA,Unsigned,MemRead;

    wire [2:0] ImmSrc;
    wire [1:0] Size;
    wire [1:0] ResultSrc;

    wire UART_sel,uart_start,uart_read_en;
    wire [31:0] addr;
    
    
    // Controller Module
    RISCV_Controller Controller(
        
        .ALUFlags(ALUFlags),
       
        .opcode(op),
        .funct3(funct3),
        .funct7(funct7),

        .ALUControl(ALUControl),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ImmSrc(ImmSrc),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .Size(Size),
        .Unsigned(Unsigned),
        .MemRead(MemRead),
        .UART_sel(UART_sel),
        .uart_start(uart_start),
        .uart_read_en(uart_read_en),
        .addr(addr)
        
    );
    
    // Datapath Module
    RISCV_Datapath Datapath(
        .clk(clk),
        .reset(reset),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ALUControl(ALUControl),
        .ALUSrcB(ALUSrcB),
        .ALUSrcA(ALUSrcA),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .Unsigned(Unsigned),
        .Size(Size),
        .PC(fetchPC),
        .ALUFlags(ALUFlags),
       
        .op(op),
        .funct3(funct3),
        .funct7(funct7),

        .Debug_Select(debug_reg_select),
        .Debug_Out(debug_reg_out),
        .uart_read_en(uart_read_en),
        .uart_start(uart_start),
        .UART_sel(UART_sel),
        .addr(addr),
        .clk_100(clk_100),
        .rx(rx),
        .tx(tx)
    );
    
endmodule
