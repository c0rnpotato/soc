// ahb_uart.v — AHB-Lite UART Peripheral (CMSDK IP wrapper)
//
// AHB-Lite adapter for cmsdk_apb_uart.  One wait state per access.
// All register-level behavior (TX/RX FSMs, baud generator, interrupts)
// comes from the CMSDK APB UART IP.
//
// Students see this module as "ahb_uart" without needing to understand
// the APB protocol.
//
// CMSDK register map (base 0x5100_0000):
//   0x00  DATA          W: TX data [7:0]   R: RX data [7:0]
//   0x04  STATE         [3]=rx_ovr [2]=tx_ovr [1]=rx_full [0]=tx_full
//   0x08  CTRL          [6]=HSTM [5:4]=ovr_int_en [3:2]=int_en [1:0]=en
//   0x0C  INTSTATUS/INTCLEAR   [3:0] interrupt status(R) / clear(W)
//   0x10  BAUDDIV       [19:0] baud rate divider (min 16)
//
// APB adapter (1 wait state):
//   IDLE  → (trans_valid) → SETUP  : HREADYOUT=0
//   SETUP →                 ACCESS : HREADYOUT=1, PRDATA valid
//   ACCESS→ (trans_valid) → SETUP / → IDLE

module ahb_uart (
  // AHB-Lite slave interface
  input  wire        hclk,
  input  wire        hrst_n,
  input  wire        hsel_i,
  input  wire        hready_i,
  input  wire [31:0] haddr_i,
  input  wire [1:0]  htrans_i,
  input  wire        hwrite_i,
  input  wire [31:0] hwdata_i,
  output reg         hreadyout_o,
  output wire [31:0] hrdata_o,

  // UART serial interface
  input  wire        uart_rx_i,
  output wire        uart_tx_o,

  // Interrupt (active-high, combined OR of TXINT/RXINT/TXOVRINT/RXOVRINT)
  output wire        uart_irq_o,

  // Baud tick output (for simulation monitor)
  output wire        baudtick_o
);

  // --------------------------------------------------------------------------
  // AHB address-phase detection
  // --------------------------------------------------------------------------
  wire trans_valid = hsel_i & htrans_i[1] & hready_i;

  // --------------------------------------------------------------------------
  // APB FSM
  // --------------------------------------------------------------------------
  localparam S_IDLE   = 2'd0;
  localparam S_SETUP  = 2'd1;   // APB setup: PSEL=1, PENABLE=0
  localparam S_ACCESS = 2'd2;   // APB access: PSEL=1, PENABLE=1

  reg  [1:0]  state;
  reg  [11:2] apb_addr;
  reg         apb_wr;

  always @(posedge hclk or negedge hrst_n) begin
    if (!hrst_n) begin
      state       <= S_IDLE;
      hreadyout_o <= 1'b1;
      apb_addr    <= 10'd0;
      apb_wr      <= 1'b0;
    end else begin
      case (state)
        S_IDLE: begin
          hreadyout_o <= 1'b1;
          if (trans_valid) begin
            state       <= S_SETUP;
            hreadyout_o <= 1'b0;
            apb_addr    <= haddr_i[11:2];
            apb_wr      <= hwrite_i;
          end
        end

        S_SETUP: begin
          state       <= S_ACCESS;
          hreadyout_o <= 1'b1;
        end

        S_ACCESS: begin
          if (trans_valid) begin
            state       <= S_SETUP;
            hreadyout_o <= 1'b0;
            apb_addr    <= haddr_i[11:2];
            apb_wr      <= hwrite_i;
          end else begin
            state       <= S_IDLE;
            hreadyout_o <= 1'b1;
          end
        end

        default: begin
          state       <= S_IDLE;
          hreadyout_o <= 1'b1;
        end
      endcase
    end
  end

  // --------------------------------------------------------------------------
  // APB signals (all from registered state)
  // --------------------------------------------------------------------------
  wire psel    = (state == S_SETUP) | (state == S_ACCESS);
  wire penable = (state == S_ACCESS);

  // HRDATA: combinational from PRDATA (safe — PADDR is registered)
  wire [31:0] prdata;
  assign hrdata_o = prdata;

  // --------------------------------------------------------------------------
  // CMSDK APB UART
  // --------------------------------------------------------------------------
  cmsdk_apb_uart u_apb_uart (
    .PCLK       (hclk),
    .PCLKG      (hclk),
    .PRESETn    (hrst_n),
    .PSEL       (psel),
    .PADDR      (apb_addr),
    .PENABLE    (penable),
    .PWRITE     (apb_wr),
    .PWDATA     (hwdata_i),
    .ECOREVNUM  (4'h0),
    .PRDATA     (prdata),
    .PREADY     (),
    .PSLVERR    (),
    .RXD        (uart_rx_i),
    .TXD        (uart_tx_o),
    .TXEN       (),
    .BAUDTICK   (baudtick_o),
    .TXINT      (),
    .RXINT      (),
    .TXOVRINT   (),
    .RXOVRINT   (),
    .UARTINT    (uart_irq_o)
  );

endmodule
