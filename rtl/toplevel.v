module toplevel (
  input         btn_n_pad_i, // KEY 1

  /* SDRAM INTERFACE */
  output [1:0]  sdram_ba_pad_o,
  output [12:0] sdram_a_pad_o,
  inout  [15:0] sdram_dq_pad_io,
  output [1:0]  sdram_dqm_pad_o,
  output        sdram_cas_pad_o,
  output        sdram_ras_pad_o,
  output        sdram_we_pad_o,
  output        sdram_cs_n_pad_o,
  output        sdram_cke_pad_o,
  output        sdram_clk_pad_o,

  /* DIP SWITCHES */
  input [3:0]   gpio1_i,

  /* LEDS */
  output [7:0]  gpio0_io,

  input         sys_clk_pad_i,	/* 50 Mhz */
  input         rst_n_pad_i  	// KEY 0

);

wire 	[23:0] addr;

wire	[15:0] wr_data;
wire           wr_enable;

wire	[15:0] rd_data;
wire           rd_enable;

wire           clk100;
wire           rd_ready;
wire           busy;

/* PLL */
pll plli (
  .inclk0    (sys_clk_pad_i),
  .c0        (clk100),
  .c1        (),
  .c2        ()
);

assign sdram_clk_pad_o = clk100;

/* Tester */
tester_ctrl tester_ctrl0 (
  .clk         (clk100),
  .rst_n       (rst_n_pad_i),

  .rd_enable_o (rd_enable),
  .wr_enable_o (wr_enable),
  .busy_i      (busy),
  .rd_ready_i  (rd_ready),
  .rd_data_i   (rd_data),
  .wr_data_o   (wr_data),
  .addr_o      (addr),

  .leds_o      (gpio0_io)
);

/* SDRam */
sdram_controller sdram_controlleri (
    /* HOST INTERFACE */
    .wr_addr(addr),
    .wr_data(wr_data),
    .wr_enable(wr_enable),

    .rd_addr(addr),
    .rd_data(rd_data),
    .rd_ready(rd_ready),
    .rd_enable(rd_enable),

    .busy(busy), .rst_n(rst_n_pad_i), .clk(clk100),

    /* SDRAM SIDE */
    .addr          (sdram_a_pad_o),
    .bank_addr     (sdram_ba_pad_o),
    .data          (sdram_dq_pad_io),
    .clock_enable  (sdram_cke_pad_o),
    .cs_n          (sdram_cs_n_pad_o),
    .ras_n         (sdram_ras_pad_o),
    .cas_n         (sdram_cas_pad_o),
    .we_n          (sdram_we_pad_o),
    .data_mask_low (sdram_dqm_pad_o[0]),
    .data_mask_high(sdram_dqm_pad_o[1])
);


endmodule
