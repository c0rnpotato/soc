`default_nettype none

module decoder2to4 (
    input  logic [1:0] in,
    input  logic       en,
    output logic [3:0] out
);

    // TODO: Implement 2-to-4 decoder using always_comb
    always_comb
        if(en)
            case(in)
                2'b00:  out=4'b0001;
                2'b01:  out=4'b0010;
                2'b10:  out=4'b0100;
                2'b11:  out=4'b1000;
                default:out=4'b0000;
            endcase
        else            out=4'b0000;
endmodule
