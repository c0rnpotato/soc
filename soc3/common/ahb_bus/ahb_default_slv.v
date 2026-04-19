// ahb_default_slv.v — AHB-Lite Default Slave
//
// Returns a two-cycle ERROR response for any active transfer to
// an unmapped address region, per AHB-Lite protocol (IHI 0033B §5.1.3).
//
// Equivalent to ARM CMSDK cmsdk_ahb_default_slave, rewritten with
// explicit case-based next-state logic for simulation tool compatibility.
//
// State encoding:
//   2'b01 — Idle       (HREADYOUT=1, HRESP=0)
//   2'b10 — Error, 1st (HREADYOUT=0, HRESP=1)
//   2'b11 — Error, 2nd (HREADYOUT=1, HRESP=1)
//
// Bit 0 drives HREADYOUT, bit 1 drives HRESP.

module ahb_default_slv (
  input  wire        clk,
  input  wire        rst_n,

  input  wire        hsel_i,
  input  wire [1:0]  htrans_i,
  input  wire        hready_i,

  output wire        hreadyout_o,
  output wire        hresp_o,
  output wire [31:0] hrdata_o
);

  // Read data for unmapped region
  assign hrdata_o = 32'hdeadbeef;

  // Active transfer detected in address phase
  wire trans_req = hsel_i & htrans_i[1] & hready_i;

  // State register
  reg [1:0] resp_state;

  // Next-state logic
  reg [1:0] next_state;
  always @* begin
    case (resp_state)
      2'b01:   next_state = trans_req ? 2'b10 : 2'b01;  // Idle → Error1
      2'b10:   next_state = 2'b11;                       // Error1 → Error2
      2'b11:   next_state = trans_req ? 2'b10 : 2'b01;  // Error2 → Error1/Idle
      default: next_state = 2'b01;
    endcase
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) resp_state <= 2'b01;  // ensure HREADYOUT=1 at reset
    else         resp_state <= next_state;
  end

  // Output connections (direct bit select from registered state)
  assign hreadyout_o = resp_state[0];
  assign hresp_o     = resp_state[1];

endmodule
