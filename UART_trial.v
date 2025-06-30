module UART_trial(
    input wire clk,
    input wire rst,
    input wire rx,
    output wire tx,
    input wire write_en,
    input wire read_en,
    input wire start,
    input wire write_reg,
    output wire [31:0] reg1_out
);

wire [31:0] data_out,data_in; 
Register_rsten#(
    .WIDTH(32)
) reg_1(
    .clk(clk),
    .reset(rst),
    .we(write_reg),
    .DATA(data_out),  // Example data
    .OUT(reg1_out)
);

UART uart_baba(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .data_in(data_in),
    .tx(tx),
    .data_out(data_out),
    .write_en(write_en),
    .read_en(read_en),
    .start(start)
);

Register_rsten#(
    .WIDTH(32)
) reg_2(
    .clk(clk),
    .reset(rst),
    .we(1'b1),
    .DATA(32'h000000FA),  // Example data
    .OUT(data_in)
);
endmodule