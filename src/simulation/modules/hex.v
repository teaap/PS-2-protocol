module hex (input [4:0] in, output reg [6:0] out);
    always @(*)
        case (in)
            5'b00000: out = ~7'h3F;
            5'b00001: out = ~7'h06;
            5'b00010: out = ~7'h5B;
            5'b00011: out = ~7'h4F;
            5'b00100: out = ~7'h66;
            5'b00101: out = ~7'h6D;
            5'b00110: out = ~7'h7D;
            5'b00111: out = ~7'h07;
            5'b01000: out = ~7'h7F;
            5'b01001: out = ~7'h6F;
            5'b01010: out = ~7'h77;
            5'b01011: out = ~7'h7C;
            5'b01100: out = ~7'h39;
            5'b01101: out = ~7'h5E;
            5'b01110: out = ~7'h79;
            5'b01111: out = ~7'h71;
            default: out = ~7'h00;
    endcase
endmodule

