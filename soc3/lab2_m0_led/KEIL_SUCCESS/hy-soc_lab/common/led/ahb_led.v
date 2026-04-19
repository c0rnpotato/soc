// ahb_led.v — AHB-Lite LED Controller
//
// Single 8-bit register at offset 0x00.
// Lower 4 bits [3:0] drive LED output pins.
// Read returns current LED state.

module ahb_led (
  input  wire        hclk,
  input  wire        hrst_n,
  input  wire        hsel_i,
  input  wire        hready_i,
  input  wire [31:0] haddr_i,
  input  wire [1:0]  htrans_i,
  input  wire        hwrite_i,
  input  wire [31:0] hwdata_i,
  output wire        hreadyout_o,
  output wire [31:0] hrdata_o,

  output wire [3:0]  led_o
);

  assign hreadyout_o = 1'b1;

  // Address phase capture
  wire trans_valid = hsel_i & htrans_i[1] & hready_i;

  reg wr_en;
  always @(posedge hclk or negedge hrst_n) begin
    if (!hrst_n)
      wr_en <= 1'b0;
    else
      wr_en <= trans_valid & hwrite_i;
  end

  // LED register
  reg [7:0] led_reg;

  always @(posedge hclk or negedge hrst_n) begin
    if (!hrst_n)
      led_reg <= 8'h00;
    else if (wr_en)
      led_reg <= hwdata_i[7:0];
  end

  assign hrdata_o = {24'h0, led_reg};
  assign led_o    = led_reg[3:0];

endmodule
