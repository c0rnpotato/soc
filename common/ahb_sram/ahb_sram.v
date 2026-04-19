// ahb_sram.v — AHB-Lite Subordinate: Tightly-Coupled SRAM
//
// Parameters:
//   MEMWIDTH  log2 of byte size (default 16 → 64 KB)
//
// Read data is returned combinatorially (zero-wait-state).
// Byte-enable write is decoded from HSIZE and HADDR[1:0].
//
// Note: code.hex is loaded via $readmemh at simulation start.
//       The hex file must contain 32-bit words (one word per line).

module ahb_sram #(
  parameter MEMWIDTH = 16   // 2^MEMWIDTH bytes
) (
  input  wire        hsel,
  input  wire        clk,
  input  wire        rst_n,
  input  wire        hready,
  input  wire [31:0] haddr,
  input  wire [1:0]  htrans,
  input  wire        hwrite,
  input  wire [2:0]  hsize,
  input  wire [31:0] hwdata,

  output wire        hreadyout,
  output reg  [31:0] hrdata
);

  // Always zero wait states
  assign hreadyout = 1'b1;

  // Memory array
  reg [31:0] mem [0:(2**(MEMWIDTH-2)-1)];

  initial begin
    //$readmemh("code.hex", mem);
    $readmemh("code.mem", mem);
  end

  // Address-phase registers
  reg        aph_hsel;
  reg        aph_hwrite;
  reg [1:0]  aph_htrans;
  reg [31:0] aph_haddr;
  reg [2:0]  aph_hsize;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      aph_hsel   <= 1'b0;
      aph_hwrite <= 1'b0;
      aph_htrans <= 2'b00;
      aph_haddr  <= 32'h0;
      aph_hsize  <= 3'b000;
    end else if (hready) begin
      aph_hsel   <= hsel;
      aph_hwrite <= hwrite;
      aph_htrans <= htrans;
      aph_haddr  <= haddr;
      aph_hsize  <= hsize;
    end
  end

  // Byte-enable decode
  wire tx_byte = ~aph_hsize[1] & ~aph_hsize[0];
  wire tx_half = ~aph_hsize[1] &  aph_hsize[0];
  wire tx_word =  aph_hsize[1];

  wire byte0 = tx_word | (tx_half & ~aph_haddr[1]) | (tx_byte & ~aph_haddr[1] & ~aph_haddr[0]);
  wire byte1 = tx_word | (tx_half & ~aph_haddr[1]) | (tx_byte & ~aph_haddr[1] &  aph_haddr[0]);
  wire byte2 = tx_word | (tx_half &  aph_haddr[1]) | (tx_byte &  aph_haddr[1] & ~aph_haddr[0]);
  wire byte3 = tx_word | (tx_half &  aph_haddr[1]) | (tx_byte &  aph_haddr[1] &  aph_haddr[0]);

  // Write (data phase)
  always @(posedge clk) begin
    if (aph_hsel & aph_hwrite & aph_htrans[1]) begin
      if (byte0) mem[aph_haddr[MEMWIDTH:2]][ 7: 0] <= hwdata[ 7: 0];
      if (byte1) mem[aph_haddr[MEMWIDTH:2]][15: 8] <= hwdata[15: 8];
      if (byte2) mem[aph_haddr[MEMWIDTH:2]][23:16] <= hwdata[23:16];
      if (byte3) mem[aph_haddr[MEMWIDTH:2]][31:24] <= hwdata[31:24];
    end
    // Read: use current haddr for zero-wait combinatorial read
    hrdata <= mem[haddr[MEMWIDTH:2]];
  end

endmodule
