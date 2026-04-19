`default_nettype none

module barrel_shifter (
    input  wire [7:0] data,
    input  wire [2:0] shamt,
    output reg  [7:0] y
);
reg [7:0] s1, s2; // Intermediate stages

always @(*) begin
    // Stage 1: Rotate by 1 if shamt[0] is 1
    s1 = shamt[0] ? {data[6:0], data[7]} : data;
    
    // Stage 2: Rotate by 2 if shamt[1] is 1
    s2 = shamt[1] ? {s1[5:0], s1[7:6]} : s1;
    
    // Stage 3: Rotate by 4 if shamt[2] is 1
    y  = shamt[2] ? {s2[3:0], s2[7:4]} : s2;
end

endmodule
