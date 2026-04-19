`default_nettype none

module priority_enc (
    input  wire [3:0] req,
    output reg  [1:0] enc,
    output reg        valid
);

    // TODO: Implement priority encoder using always @(*) with if/else
    // req[3] has highest priority, req[0] has lowest
    // Don't forget default assignments to prevent latch inference!
    always @(*) begin
        if(req[3])      begin enc = 2'b11; valid = 1'b1; end
        else if(req[2]) begin enc = 2'b10; valid = 1'b1; end
        else if(req[1]) begin enc = 2'b01; valid = 1'b1; end
        else if(req[0]) begin enc = 2'b00; valid = 1'b1; end
        else            begin enc = 2'b00; valid = 1'b0; end
    end
endmodule
