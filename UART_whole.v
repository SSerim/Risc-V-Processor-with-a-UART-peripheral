module UART(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire [31:0] data_in,
    output wire tx,
    output wire [31:0] data_out,
    input wire read_en,
    input wire start
);

wire data_ready__write_en_fifo;
wire [7:0] buffer_data_in;
wire [7:0] transmitter_data = data_in[7:0]; // Assuming we only want to send the first byte
UART_FIFO FIFO(
    .clk(clk),
    .rst(rst),
    .read_en(read_en),
    .write_en(data_ready__write_en_fifo),
    .data_in(buffer_data_in),
    .data_out(data_out),
    .full(),
    .empty()
);
wire rx_busy_out;
wire tx_busy_out;
UART_receiver receiver(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .data_out(buffer_data_in),
    .data_ready(data_ready__write_en_fifo),
    .rx_busy(rx_busy_out),
    .tx_busy(tx_busy_out)
);

UART_transmitter transmitter(
    .clk(clk),
    .rst(rst),
    .start(start),              // Start transmission
    .data_in(transmitter_data),      // Byte to transmit    //transmitter_data
    .tx(tx),                 // Serial output
    .rx_busy(rx_busy_out),
    .tx_busy(tx_busy_out)             // High while sending
);
endmodule