module UART_receiver(
//REPRESENTED BY SECO BABA
    input wire clk,
    input wire rst,
    input wire rx,
    output reg [7:0] data_out,
    output reg data_ready,
    output reg rx_busy,
    input wire tx_busy
);

// UART config
parameter CLKS_PER_BIT = 10417;  // For 50MHz clk & 9600 baud
parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;

reg [1:0] state = IDLE;
reg [13:0] clk_count = 0;
reg [2:0] bit_index = 0;
reg [7:0] rx_shift = 0;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        clk_count <= 0;
        bit_index <= 0;
        rx_shift <= 0;
        data_out <= 0;
        data_ready <= 0;
        rx_busy <= 0;
    end else if (~(tx_busy))begin
        case (state)
            IDLE: begin
            // emin değilim değiştirilmesi gerekebilir

                data_ready <= 0;
                rx_busy <= 0;
                clk_count <= 0;
                bit_index <= 0;
                if (~rx) begin // Detect start bit
                    state <= START;
                    rx_busy <= 1;
                end
            end

            START: begin
                if (clk_count == CLKS_PER_BIT / 2) begin
                    if (~rx) begin  // Confirm it's still low (valid start bit)
                        clk_count <= 0;
                        state <= DATA;
                    end else begin
                        state <= IDLE;  // False start bit
                    end
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DATA: begin
                if (clk_count == CLKS_PER_BIT  - 1 ) begin
                    clk_count <= 0;
                    rx_shift[bit_index] <= rx;
                    if (bit_index == 7) begin
                        bit_index <= 0;
                        state <= STOP;
                    end else begin
                        bit_index <= bit_index + 1;
                    end
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            STOP: begin
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    state <= IDLE;
                    data_out <= rx_shift;
                    data_ready <= 1;
                    rx_busy <= 0;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            default: begin
                state <= IDLE;
            end
        endcase
    end
end
endmodule
