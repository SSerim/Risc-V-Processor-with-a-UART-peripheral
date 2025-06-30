module UART_transmitter(
//REPRESENTED BY SECO BABA
    input wire clk,
    input wire rst,
    input wire start,              // Start transmission
    input wire [7:0] data_in,      // Byte to transmit
    output reg tx,                 // Serial output
    output reg tx_busy,                // High while sending
    input wire rx_busy
);

reg start_prev;
wire start_pulse;



    parameter CLKS_PER_BIT = 10417;  // For 50 MHz clock, 9600 baud
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3, CLEANUP = 4;

    reg [2:0] state = IDLE;
    reg [13:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data_buf = 0;

    always @(posedge clk) begin
        start_prev <= start;
        end
assign start_pulse = ~start & start_prev;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            tx <= 1;           // UART line is idle high
            tx_busy <= 0;
        end else if (~(rx_busy))begin   //~(rx_busy)
            case (state)
                IDLE: begin
                    tx_busy <= 0;
                    clk_count <= 0;
                    bit_index <= 0;

                    if (start_pulse) begin
                        data_buf <= data_in;
                        tx_busy <= 1;
                        state <= START;
                    end
                end

                START: begin
                    tx <= 0;  // Start bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx <= data_buf[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx <= 1;  // Stop bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= CLEANUP;
                    end
                end

                CLEANUP: begin
                    tx_busy <= 0;
                    tx <= 1;
                    state <= IDLE;  // Back to idle, ready for next byte
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
