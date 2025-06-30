module Mux_32to1 #(parameter WIDTH=4)
(
    input [4:0] select,
    input [WIDTH-1:0] input_0,  input_1,  input_2,  input_3,
    input [WIDTH-1:0] input_4,  input_5,  input_6,  input_7,
    input [WIDTH-1:0] input_8,  input_9,  input_10, input_11,
    input [WIDTH-1:0] input_12, input_13, input_14, input_15,
    input [WIDTH-1:0] input_16, input_17, input_18, input_19,
    input [WIDTH-1:0] input_20, input_21, input_22, input_23,
    input [WIDTH-1:0] input_24, input_25, input_26, input_27,
    input [WIDTH-1:0] input_28, input_29, input_30, input_31,
    output reg [WIDTH-1:0] output_value
);

always @(*) begin
    case(select)
        5'd0:  output_value = input_0;
        5'd1:  output_value = input_1;
        5'd2:  output_value = input_2;
        5'd3:  output_value = input_3;
        5'd4:  output_value = input_4;
        5'd5:  output_value = input_5;
        5'd6:  output_value = input_6;
        5'd7:  output_value = input_7;
        5'd8:  output_value = input_8;
        5'd9:  output_value = input_9;
        5'd10: output_value = input_10;
        5'd11: output_value = input_11;
        5'd12: output_value = input_12;
        5'd13: output_value = input_13;
        5'd14: output_value = input_14;
        5'd15: output_value = input_15;
        5'd16: output_value = input_16;
        5'd17: output_value = input_17;
        5'd18: output_value = input_18;
        5'd19: output_value = input_19;
        5'd20: output_value = input_20;
        5'd21: output_value = input_21;
        5'd22: output_value = input_22;
        5'd23: output_value = input_23;
        5'd24: output_value = input_24;
        5'd25: output_value = input_25;
        5'd26: output_value = input_26;
        5'd27: output_value = input_27;
        5'd28: output_value = input_28;
        5'd29: output_value = input_29;
        5'd30: output_value = input_30;
        5'd31: output_value = input_31;
        default: output_value = {WIDTH{1'b0}};
    endcase
end

endmodule
