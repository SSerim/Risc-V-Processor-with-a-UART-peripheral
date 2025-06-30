module RISCV_Datapath (
    input clk,
    input reset,



    //Controllerden gelen sinyaller

    input PCSrc,
    input [1:0] ResultSrc,
    input MemWrite,
    input [3:0] ALUControl, //AluControl 2bit de olablir
    input ALUSrcB,
    input ALUSrcA,
    input [2:0] ImmSrc,
    input RegWrite,
    input Unsigned,
    input [1:0] Size,
    input MemRead,
    // Debug için

    input [4:0] Debug_Select,
    output [31:0] Debug_Out,


    //Contorller Giden Sinyaller
    output [6:0] op,
    output [2:0] funct3,
    output [6:0] funct7,

    output [2:0] ALUFlags,
    output [31:0] PC,

    // UART için
    input clk_100,
    output  tx,
    input  rx,
    input uart_read_en, uart_start, UART_sel,
    output [31:0] addr

);

assign addr = ALUResult;


//PCPLUS4 OR PCTARGET

wire [31:0] PCNext;

Mux_2to1 #(32) PCMUX(
    .select(PCSrc),
    .input_0(PCPlus4),
    .input_1(ALUResult),
    .output_value(PCNext)
    );


// Program Counter Register

Register_reset #(32) Program_Counter(
        .clk(clk),
        .reset(reset),
        .DATA(PCNext),
        .OUT(PC)
    );



wire [31:0] PCPlus4;



wire [31:0] Instr;

//PCPlus4
Adder PCP4(
    .DATA_A(PC),
    .DATA_B(32'h00000004),
    .OUT(PCPlus4)
    );


//Instruction Memory
Instruction_memory #(4,32) Fetching(
    .ADDR(PC),
    .RD(Instr)
    );



//Controller Signals
assign op = Instr[6:0];
assign funct3 = Instr[14:12];
assign funct7 = Instr[31:25]; //Funct7 7 bit





//Register File Input
wire [4:0] A1;
wire [4:0] A2;
wire [4:0] A3;

assign A1 = Instr[19:15];
assign A2 = Instr[24:20];
assign A3 = Instr[11:7];






//Extender Input Output
wire [24:0] Extend_input;

assign Extend_input = Instr[31:7];

wire [31:0] ImmExt;


Extender_RISCV ext(
    .instr(Extend_input), 
    .ImmSrc(ImmSrc),
    .imm_out(ImmExt)
    );


//Register File
Register_file_RISCV reg_file(
        .clk(clk),.reset(reset), .write_enable(RegWrite), // Ensure BL writes to R14
        .Source_select_0(A1), .Source_select_1(A2), 
        .Destination_select(A3), 
        .DATA(Result),
        .out_0(RD1),
        .out_1(RD2),
        .Debug_Source_select(Debug_Select),//Swichtler bağlancakmış wire ata output
        .Debug_out(Debug_Out)
    );


//Register File Output
wire [31:0] RD1,RD2;
wire [31:0] SrcB,SrcA;


Branch_Comparator comparator(
    .A(RD1),
    .B(RD2),
    .ALUFlags(ALUFlags)
);

Mux_2to1 #(32) SRCbbALU(
    .select(ALUSrcB),
    .input_0(RD2),
    .input_1(ImmExt),
    .output_value(SrcB)
    );

Mux_2to1 #(32) SRCaaALU(
    .select(ALUSrcA),
    .input_0(RD1),
    .input_1(PC),
    .output_value(SrcA)
    );



wire [31:0] ALUResult;


RISCV_ALU  alu(
        .A(SrcA),
        .B(SrcB),
        .ALUControl(ALUControl),
        .Result(ALUResult)
        

        
    );





wire [31:0] ReadData;


// UART instantaniaton 
wire [31:0] data_out_buffer;

UART uart_baba(
        .clk(clk_100),
        .rst(reset),
        .rx(rx),
        .tx(tx),
        .data_in(RD2),          //RD2
        .data_out(data_out_buffer),
        .read_en(uart_read_en),     //controllerdan gelcek
        .start(uart_start)        // controllerdan gelcek
);

//-------------------------------

RISCV_Memory data_mem(
        .clk(clk), 
        .MemWrite(MemWrite), 
        .Address(ALUResult), 
        .UnsignedOp(Unsigned),

        .MemRead(MemRead),
        .Size(Size),
        .WriteData(RD2), 
        .ReadData(ReadData)
    );

wire [31:0] last_mux_inp;
Mux_2to1 #(32) uart_mux(
    .select(UART_sel),
    .input_0(ReadData),
    .input_1(data_out_buffer),   //data_out_buffer
    .output_value(last_mux_inp)
    );

wire [31:0] Result;

Mux_4to1 #(32) LastMux(
    .select(ResultSrc),
    .input_0(last_mux_inp), // MEMORY
    .input_1(ALUResult), // ALURESULTS
    .input_2(PCPlus4), // PC PLUS 4 FOR JUMPS
    .input_3(ImmExt),
    .output_value(Result)
    );


endmodule