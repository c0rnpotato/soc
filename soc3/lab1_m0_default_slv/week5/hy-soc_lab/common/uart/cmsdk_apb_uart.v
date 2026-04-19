//-----------------------------------------------------------------------------
// Clean rewrite of ARM CMSDK APB UART (2-state simulator friendly)
//
// Maintains 100% register-map and hardware-architecture compatibility with
// the original cmsdk_apb_uart (Cortex-M System Design Kit r1p1).
//
// Changes from original:
//   - OVL assertion section removed entirely
//   - X-propagation replaced with 0 (Verilator 2-state)
//   - PCLKG kept in port list for drop-in compatibility but unused
//   - Combinational blocks use always @*
//   - Coding style cleaned up for 2-state simulators
//
// Register map (unchanged):
//   0x00  DATA      W: TX[7:0]  R: RX[7:0]
//   0x04  STATE     [3:0] = {rx_ovr, tx_ovr, rx_full, tx_full}
//   0x08  CTRL      [6]=HSTM [5:4]=ovr_int_en [3:2]=int_en [1:0]=en
//   0x0C  INTSTATUS/INTCLEAR  [3:0]
//   0x10  BAUDDIV   [19:0]  (minimum 16)
//   0x3E0-0x3FC  PID/CID
//-----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
module cmsdk_apb_uart (
  input  wire        PCLK,
  input  wire        PCLKG,    // unused — kept for interface compatibility
  input  wire        PRESETn,

  input  wire        PSEL,
  input  wire [11:2] PADDR,
  input  wire        PENABLE,
  input  wire        PWRITE,
  input  wire [31:0] PWDATA,

  input  wire [3:0]  ECOREVNUM,

  output wire [31:0] PRDATA,
  output wire        PREADY,
  output wire        PSLVERR,

  input  wire        RXD,
  output wire        TXD,
  output wire        TXEN,
  output wire        BAUDTICK,

  output wire        TXINT,
  output wire        RXINT,
  output wire        TXOVRINT,
  output wire        RXOVRINT,
  output wire        UARTINT
);

// ============================================================================
// ID registers — APB UART part number 0x821
// ============================================================================
localparam [7:0] PID4 = 8'h04, PID5 = 8'h00, PID6 = 8'h00, PID7 = 8'h00;
localparam [7:0] PID0 = 8'h21, PID1 = 8'hB8, PID2 = 8'h1B;
localparam [3:0] PID3 = 4'h0;
localparam [7:0] CID0 = 8'h0D, CID1 = 8'hF0, CID2 = 8'h05, CID3 = 8'hB1;

// ============================================================================
// APB read/write control
// ============================================================================
wire read_enable  = PSEL & ~PWRITE;
wire write_enable = PSEL & ~PENABLE & PWRITE;

wire write_enable00 = write_enable & (PADDR[11:2] == 10'h000);
wire write_enable04 = write_enable & (PADDR[11:2] == 10'h001);
wire write_enable08 = write_enable & (PADDR[11:2] == 10'h002);
wire write_enable0c = write_enable & (PADDR[11:2] == 10'h003);
wire write_enable10 = write_enable & (PADDR[11:2] == 10'h004);

// ============================================================================
// Control registers
// ============================================================================
reg  [6:0] reg_ctrl;
reg  [7:0] reg_tx_buf;
reg  [7:0] reg_rx_buf;
reg [19:0] reg_baud_div;

// TX data buffer
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)       reg_tx_buf <= 8'h00;
  else if (write_enable00) reg_tx_buf <= PWDATA[7:0];

// Control register
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)       reg_ctrl <= 7'h00;
  else if (write_enable08) reg_ctrl <= PWDATA[6:0];

// Baud rate divider
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)       reg_baud_div <= 20'h0_0000;
  else if (write_enable10) reg_baud_div <= PWDATA[19:0];

// ============================================================================
// Status — overrun registers
// ============================================================================
reg  reg_rx_overrun;
reg  reg_tx_overrun;
wire rx_overrun;  // set by RX logic
wire tx_overrun;  // set by TX logic

wire nxt_rx_overrun = (reg_rx_overrun & ~((write_enable04 | write_enable0c) & PWDATA[3])) | rx_overrun;
wire nxt_tx_overrun = (reg_tx_overrun & ~((write_enable04 | write_enable0c) & PWDATA[2])) | tx_overrun;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    reg_rx_overrun <= 1'b0;
  else if (rx_overrun | write_enable04 | write_enable0c)
    reg_rx_overrun <= nxt_rx_overrun;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    reg_tx_overrun <= 1'b0;
  else if (tx_overrun | write_enable04 | write_enable0c)
    reg_tx_overrun <= nxt_tx_overrun;

// Forward declarations (VCS requires declare-before-use)
wire rx_buf_full;
wire tx_buf_full;
wire tx_buf_clear;
wire [3:0] intr_state;

wire [3:0] uart_status = {reg_rx_overrun, reg_tx_overrun, rx_buf_full, tx_buf_full};

// ============================================================================
// APB read mux (two-stage, identical to original)
// ============================================================================
reg  [7:0] read_mux_byte0;
reg  [7:0] read_mux_byte0_reg;

// First level — combinational
always @* begin
  if (PADDR[11:5] == 7'h00) begin
    case (PADDR[4:2])
      3'h0: read_mux_byte0 = reg_rx_buf;
      3'h1: read_mux_byte0 = {4'h0, uart_status};
      3'h2: read_mux_byte0 = {1'b0, reg_ctrl};
      3'h3: read_mux_byte0 = {4'h0, intr_state};
      3'h4: read_mux_byte0 = reg_baud_div[7:0];
      default: read_mux_byte0 = 8'h00;
    endcase
  end
  else if (PADDR[11:6] == 6'h3F) begin
    case (PADDR[5:2])
      4'h0, 4'h1, 4'h2, 4'h3: read_mux_byte0 = 8'h00;
      4'h4: read_mux_byte0 = PID4;
      4'h5: read_mux_byte0 = PID5;
      4'h6: read_mux_byte0 = PID6;
      4'h7: read_mux_byte0 = PID7;
      4'h8: read_mux_byte0 = PID0;
      4'h9: read_mux_byte0 = PID1;
      4'hA: read_mux_byte0 = PID2;
      4'hB: read_mux_byte0 = {ECOREVNUM[3:0], PID3};
      4'hC: read_mux_byte0 = CID0;
      4'hD: read_mux_byte0 = CID1;
      4'hE: read_mux_byte0 = CID2;
      4'hF: read_mux_byte0 = CID3;
      default: read_mux_byte0 = 8'h00;
    endcase
  end
  else begin
    read_mux_byte0 = 8'h00;
  end
end

// Register first-level result
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)      read_mux_byte0_reg <= 8'h00;
  else if (read_enable) read_mux_byte0_reg <= read_mux_byte0;

// Second level — BAUDDIV upper bits
wire [31:0] read_mux_word;
assign read_mux_word[ 7: 0] = read_mux_byte0_reg;
assign read_mux_word[19: 8] = (PADDR[11:2] == 10'h004) ? reg_baud_div[19:8] : 12'h000;
assign read_mux_word[31:20] = 12'h000;

assign PRDATA  = read_enable ? read_mux_word : 32'h0000_0000;
assign PREADY  = 1'b1;
assign PSLVERR = 1'b0;

// ============================================================================
// Baud rate generator (integer + fractional divider)
// ============================================================================
reg  [15:0] reg_baud_cntr_i;
reg   [3:0] reg_baud_cntr_f;
reg         reg_baud_tick;
reg         baud_updated;

wire baud_div_en   = (reg_ctrl[1:0] != 2'b00);
wire [3:0] mapped_cntr_f = {reg_baud_cntr_f[0], reg_baud_cntr_f[1],
                             reg_baud_cntr_f[2], reg_baud_cntr_f[3]};

// Integer counter reload condition
wire reload_i = baud_div_en &
    (((mapped_cntr_f >= reg_baud_div[3:0]) & (reg_baud_cntr_i[15:1] == 15'h0000)) |
     (reg_baud_cntr_i == 16'h0000));

wire [15:0] nxt_baud_cntr_i = (baud_updated | reload_i) ? reg_baud_div[19:4]
                             : (reg_baud_cntr_i - 16'h0001);

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    reg_baud_cntr_i <= 16'h0000;
  else if (baud_updated | baud_div_en)
    reg_baud_cntr_i <= nxt_baud_cntr_i;

// Fractional counter
wire reload_f = baud_div_en & (reg_baud_cntr_f == 4'h0) & reload_i;

wire [3:0] nxt_baud_cntr_f = (reload_f | baud_updated) ? 4'hF
                            : (reg_baud_cntr_f - 4'h1);

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    reg_baud_cntr_f <= 4'h0;
  else if (baud_updated | reload_f | reload_i)
    reg_baud_cntr_f <= nxt_baud_cntr_f;

// Baud-updated pulse (one cycle after APB write to BAUDDIV)
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    baud_updated <= 1'b0;
  else if (write_enable10 | baud_updated)
    baud_updated <= write_enable10;

// Tick output
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    reg_baud_tick <= 1'b0;
  else if (reload_i | reg_baud_tick)
    reg_baud_tick <= reload_i;

assign BAUDTICK = reg_baud_tick;

// ============================================================================
// Transmitter
// ============================================================================
reg  [3:0] tx_state;
reg  [4:0] nxt_tx_state;
reg  [3:0] tx_tick_cnt;
reg  [7:0] tx_shift_buf;
reg        tx_buf_full_r;
reg        reg_txd;

assign tx_buf_full = tx_buf_full_r;

// Buffer full
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    tx_buf_full_r <= 1'b0;
  else if (write_enable00 | tx_buf_clear)
    tx_buf_full_r <= write_enable00;

// Tick counter
wire [4:0] nxt_tx_tick_cnt = ((tx_state == 4'h1) & reg_baud_tick) ? 5'h00
                           : {1'b0, tx_tick_cnt} + {4'h0, reg_baud_tick};

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)      tx_tick_cnt <= 4'h0;
  else if (reg_baud_tick) tx_tick_cnt <= nxt_tx_tick_cnt[3:0];

// State increment (every 16 ticks, or every cycle in HSTM)
wire tx_state_inc = ((&tx_tick_cnt | (tx_state == 4'h1)) & reg_baud_tick) | reg_ctrl[6];

// Clear buffer full when data is loaded into shift register
assign tx_buf_clear = ((tx_state == 4'h0) & tx_buf_full) |
                      ((tx_state == 4'hB) & tx_buf_full & tx_state_inc);

// TX FSM: 0=Idle, 1=WaitTick, 2=Start, 3-10=D0-D7, 11=Stop
always @* begin
  case (tx_state)
    4'h0:    nxt_tx_state = (tx_buf_full & reg_ctrl[0]) ? 5'h01 : 5'h00;
    4'h1, 4'h2, 4'h3, 4'h4, 4'h5,
    4'h6, 4'h7, 4'h8, 4'h9, 4'hA:
             nxt_tx_state = {1'b0, tx_state} + {4'h0, tx_state_inc};
    4'hB:    nxt_tx_state = tx_state_inc ? (tx_buf_full ? 5'h02 : 5'h00) : {1'b0, tx_state};
    default: nxt_tx_state = 5'h00;
  endcase
end

wire tx_state_update = tx_state_inc |
                       ((tx_state == 4'h0) & tx_buf_full & reg_ctrl[0]) |
                       (tx_state > 4'd11);

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)         tx_state <= 4'h0;
  else if (tx_state_update) tx_state <= nxt_tx_state[3:0];

// Shift register load/shift
wire tx_buf_ctrl_load  = ((tx_state == 4'h0) & tx_buf_full) |
                         ((tx_state == 4'hB) & tx_buf_full & tx_state_inc);
wire tx_buf_ctrl_shift = (tx_state > 4'h2) & tx_state_inc;

wire [7:0] nxt_tx_shift_buf = tx_buf_ctrl_load ? reg_tx_buf : {1'b1, tx_shift_buf[7:1]};

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    tx_shift_buf <= 8'h00;
  else if (tx_buf_ctrl_shift | tx_buf_ctrl_load)
    tx_shift_buf <= nxt_tx_shift_buf;

// TXD output
wire nxt_txd = (tx_state == 4'h2) ? 1'b0 :
               (tx_state >  4'h2) ? tx_shift_buf[0] : 1'b1;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)          reg_txd <= 1'b1;
  else if (nxt_txd != reg_txd) reg_txd <= nxt_txd;

// TX overrun
assign tx_overrun = tx_buf_full & ~tx_buf_clear & write_enable00;

assign TXD  = reg_txd;
assign TXEN = reg_ctrl[0];

// ============================================================================
// Receiver — synchronizer + low-pass filter
// ============================================================================
reg       rxd_sync_1, rxd_sync_2;
reg [2:0] rxd_lpf;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn) begin
    rxd_sync_1 <= 1'b1;
    rxd_sync_2 <= 1'b1;
  end
  else if (reg_ctrl[1]) begin
    rxd_sync_1 <= RXD;
    rxd_sync_2 <= rxd_sync_1;
  end

wire [2:0] nxt_rxd_lpf = {rxd_lpf[1:0], rxd_sync_2};

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)       rxd_lpf <= 3'b111;
  else if (reg_baud_tick) rxd_lpf <= nxt_rxd_lpf;

// Majority-of-3 vote
wire rx_shift_in = (rxd_lpf[1] & rxd_lpf[0]) |
                   (rxd_lpf[1] & rxd_lpf[2]) |
                   (rxd_lpf[0] & rxd_lpf[2]);

// ============================================================================
// Receiver FSM
// ============================================================================
reg  [3:0] rx_state;
reg  [4:0] nxt_rx_state;
reg  [3:0] rx_tick_cnt;
reg  [6:0] rx_shift_buf;
reg        rx_buf_full_r;

assign rx_buf_full = rx_buf_full_r;

// Tick counter
wire [4:0] nxt_rx_tick_cnt = ((rx_state == 4'h0) & ~rx_shift_in) ? 5'h08
                           : {1'b0, rx_tick_cnt} + {4'h0, reg_baud_tick};

wire update_rx_tick_cnt = ((rx_state == 4'h0) & ~rx_shift_in) | reg_baud_tick;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)             rx_tick_cnt <= 4'h0;
  else if (update_rx_tick_cnt) rx_tick_cnt <= nxt_rx_tick_cnt[3:0];

// State increment
wire rx_state_inc = (&rx_tick_cnt) & reg_baud_tick;

// Sample and read signals
wire rxbuf_sample = (rx_state == 4'h9) & rx_state_inc;
wire rx_data_read = PSEL & ~PENABLE & (PADDR[11:2] == 10'h000) & ~PWRITE;

wire nxt_rx_buf_full = rxbuf_sample | (rx_buf_full & ~rx_data_read);

// RX overrun
assign rx_overrun = rx_buf_full & rxbuf_sample & ~rx_data_read;

// RX FSM: 0=Idle, 1=StartDetect, 2-9=D0-D7, 10=Stop
always @* begin
  case (rx_state)
    4'h0:    nxt_rx_state = (~rx_shift_in & reg_ctrl[1]) ? 5'h01 : 5'h00;
    4'h1, 4'h2, 4'h3, 4'h4, 4'h5,
    4'h6, 4'h7, 4'h8, 4'h9:
             nxt_rx_state = {1'b0, rx_state} + {4'h0, rx_state_inc};
    4'hA:    nxt_rx_state = rx_state_inc ? 5'h00 : 5'h0A;
    default: nxt_rx_state = 5'h00;
  endcase
end

wire rx_state_update = rx_state_inc | (~rx_shift_in & reg_ctrl[1]);

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)         rx_state <= 4'h0;
  else if (rx_state_update) rx_state <= nxt_rx_state[3:0];

// Buffer full
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    rx_buf_full_r <= 1'b0;
  else if (rxbuf_sample | rx_data_read)
    rx_buf_full_r <= nxt_rx_buf_full;

// RX data buffer
wire [7:0] nxt_rx_buf = {rx_shift_in, rx_shift_buf};

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)       reg_rx_buf <= 8'h00;
  else if (rxbuf_sample) reg_rx_buf <= nxt_rx_buf;

// Shift register
wire [6:0] nxt_rx_shift_buf = {rx_shift_in, rx_shift_buf[6:1]};

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)         rx_shift_buf <= 7'h00;
  else if (rx_state_inc) rx_shift_buf <= nxt_rx_shift_buf;

// ============================================================================
// Interrupts
// ============================================================================
reg reg_txintr, reg_rxintr;

wire [1:0] intr_stat_set   = {reg_ctrl[3] & rxbuf_sample,
                               reg_ctrl[2] & reg_ctrl[0] & tx_buf_full & tx_buf_clear};
wire [1:0] intr_stat_clear = {2{write_enable0c}} & PWDATA[1:0];

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    reg_txintr <= 1'b0;
  else if (intr_stat_set[0] | intr_stat_clear[0])
    reg_txintr <= intr_stat_set[0];

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    reg_rxintr <= 1'b0;
  else if (intr_stat_set[1] | intr_stat_clear[1])
    reg_rxintr <= intr_stat_set[1];

wire rx_overflow_intr = reg_rx_overrun & reg_ctrl[5];
wire tx_overflow_intr = reg_tx_overrun & reg_ctrl[4];

assign intr_state = {rx_overflow_intr, tx_overflow_intr, reg_rxintr, reg_txintr};

assign TXINT    = reg_txintr;
assign RXINT    = reg_rxintr;
assign TXOVRINT = tx_overflow_intr;
assign RXOVRINT = rx_overflow_intr;
assign UARTINT  = reg_txintr | reg_rxintr | tx_overflow_intr | rx_overflow_intr;

endmodule
