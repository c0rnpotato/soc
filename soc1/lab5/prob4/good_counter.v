`default_nettype none

module good_counter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    input  logic [1:0] mode,
    input  logic [7:0] load_val,
    output logic [7:0] count,
    output logic       is_zero
);

    // TODO: Fix bad_counter.v issues AND convert to SystemVerilog
    //
    // Checklist:
    //   [ ] logic instead of wire/reg
    //   [ ] always_ff for sequential logic
    //   [ ] snake_case naming (already done in port list)
    //   [ ] _n suffix for active-low reset
    //   [ ] Proper if/else chain (not multiple if)
    //   [ ] Nonblocking assignment (<=) in always_ff
    //   [ ] assign for zero flag
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)  begin   count <= '0;    end
        else if(en) begin
            case(mode)
                2'b01:  count <= count + 8'd1;
                2'b10:  count <= count - 8'd1;
                2'b11:  count <= load_val;
                default:count <= count;
            endcase
        end
    end
    assign is_zero = (count == 0);
endmodule
