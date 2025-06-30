module UART_FIFO(
    input wire clk,
    input wire rst,
    input wire read_en,     // bu sinyal controllerdan gelmeli ---- data_out'u okuma sinyali
    input wire write_en,
    input wire [7:0] data_in,
    output reg [31:0] data_out,
    output wire full,
    output wire empty
);

    reg [7:0] fifo_mem [0:15];  // 16-byte memory
    reg [3:0] read_ptr = 0;
    reg [3:0] write_ptr = 0;
    reg [4:0] count = 0;        // 5 bits to count up to 16

    assign full = (count == 16);
    assign empty = (count == 0);


    reg  write_en_prv;
    reg  write_en_now;

    reg read_en_prv;
    reg read_en_now;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            write_en_prv <= 0;
            write_en_now <= 0;
            write_en_prv <= 0;
            write_en_now <= 0;
        end else begin
            write_en_prv <= write_en;
            write_en_now <= write_en;
            read_en_prv <= read_en;
        end
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            read_ptr <= 0;
            write_ptr <= 0;
            count <= 0;
            data_out <= 0;
        end else begin
            // WRITE
            if ((write_en == 1) && (write_en_prv == 0) && ~full) begin
                fifo_mem[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1;
                count <= count + 1;
            end

            // READ
            if ((read_en_prv == 0 ) && (read_en == 1) && ~empty) begin //&& ~empty (read_en_prv == 1 ) && (read_en == 0)
                data_out <= {24'h000000 , fifo_mem[read_ptr]};  //{24'h000000 , fifo_mem[read_ptr]};
                read_ptr <= read_ptr + 1;
                count <= count - 1;
            end
            if (empty) begin
                data_out <= 32'hffffffff;  // Clear output if empty
            end
        end
    end
endmodule
