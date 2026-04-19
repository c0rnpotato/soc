// ahb_brom.v — AHB-Lite Boot ROM (read-only)
//
// Initialized at simulation time via $readmemh(ROMFILE).
// For FPGA synthesis: Vivado initializes BRAM from the same hex file.
//
// Single-cycle read, write ignored.
// haddr[AMSB:2] selects the word; upper bits are decoded by the SoC.

module ahb_brom #(
  parameter ROMFILE = "brom.hex",
  parameter DEPTH   = 1024        // 4 KB = 1024 × 32-bit words
) (
  input  wire        hclk,
  input  wire        hrst_n,

  input  wire        hsel_i,
  input  wire        hready_i,
  input  wire [31:0] haddr_i,
  input  wire [1:0]  htrans_i,

  output wire        hreadyout_o,
  output wire [31:0] hrdata_o
);

  // ROM storage: initialised from hex file
  reg [31:0] mem [0:DEPTH-1];
//  initial $readmemh(ROMFILE, mem);
initial $readmemh("C:/Users/dsald/Desktop/hy-soc/edu/lab4_m0_boot/sw/bootloader/gcc/brom_fpga.hex", mem);
  // Always ready — no wait states (read-only, no write path needed)
  assign hreadyout_o = 1'b1;

  // Latch word address at address phase
  reg [$clog2(DEPTH)-1:0] addr_lat;

  always @(posedge hclk) begin
    if (hsel_i && hready_i && htrans_i[1])
      addr_lat <= haddr_i[$clog2(DEPTH)+1:2];
  end

  assign hrdata_o = mem[addr_lat];

endmodule
