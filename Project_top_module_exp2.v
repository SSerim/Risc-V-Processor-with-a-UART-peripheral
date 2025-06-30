
//SON SECO BABA
module Nexys_A7(
    //////////// GCLK //////////
    input wire                  CLK100MHZ,
	//////////// BTN //////////
	input wire		     		BTNU, 
	                      BTNL, BTNC, BTNR,
	                            BTND,
	//////////// SW //////////
	input wire	     [15:0]		SW,
	//////////// LED //////////
	output wire		 [15:0]		LED,
    //////////// 7 SEG //////////
    output wire [7:0] AN,
    output wire CA, CB, CC, CD, CE, CF, CG, DP,
    
    output wire UART_RXD_OUT,
    input wire UART_TXD_IN
    
);

wire [31:0] reg_out, PC;
wire [4:0] buttons;

assign LED = SW;

MSSD mssd_0(
        .clk        (CLK100MHZ                      ),
        .value      ({PC[7:0], reg_out[23:0]}       ),
        .dpValue    (8'b01000000                    ),
        .display    ({CG, CF, CE, CD, CC, CB, CA}   ),
        .DP         (DP                             ),
        .AN         (AN                             )
    );

debouncer debouncer_0(
        .clk        (CLK100MHZ                      ),
        .buttons    ({BTNU, BTNL, BTNC, BTNR, BTND} ),
        .out        (buttons                        )
    );

RISCV_Computer my_computer(
        .clk                (buttons[4]             ),
        .reset              (buttons[0]             ),
        .debug_reg_select   (SW[4:0]                ),
        .debug_reg_out      (reg_out                ),
        .fetchPC            (PC                     ),
        .clk_100(CLK100MHZ),
        .rx(UART_TXD_IN),
        .tx(UART_RXD_OUT)
);

endmodule
