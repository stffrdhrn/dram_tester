`timescale 1ns / 1ps

module dram_tester_tb();

vlog_tb_utils vlog_tb_utils0();

reg rst_n, clk;

initial
begin
  rst_n = 1;
  clk = 0;
end

always
  #1  clk <= ~clk;

initial
begin
  #4 rst_n = 0;
  #4 rst_n = 1;

  #1000 $finish;
end

wire 	[23:0] addr;

wire	[15:0] wr_data;
wire           wr_enable;

wire	[15:0] rd_data;
wire           rd_enable;

wire           rd_ready;
wire           busy;

wire [1:0]  sdram_ba_pad_o;
wire [12:0] sdram_a_pad_o;
wire [15:0] sdram_dq_pad_io;
wire [1:0]  sdram_dqm_pad_o;
wire        sdram_cas_pad_o;
wire        sdram_ras_pad_o;
wire        sdram_we_pad_o;
wire        sdram_cs_n_pad_o;
wire        sdram_cke_pad_o;

wire [7:0]  gpio0_io;

assign addr[23:4] = 20'd0;

/* Tester */
tester_ctrl #(
  .ADDR_WIDTH  (4)
) tester_ctrl0 (
  .clk         (clk),
  .rst_n       (rst_n),

  .rd_enable_o (rd_enable),
  .wr_enable_o (wr_enable),
  .busy_i      (busy),
  .rd_ready_i  (rd_ready),
  .rd_data_i   (rd_data),
  .wr_data_o   (wr_data),
  .addr_o      (addr[3:0]),

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

    .busy(busy), .rst_n(rst_n), .clk(clk),

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

//Memory model
mt48lc16m16a2 mt48lc16m16a20 (
    .Dq    (sdram_dq_pad_io),
    .Addr  (sdram_a_pad_o),
    .Ba    (sdram_ba_pad_o),
    .Clk   (clk),
    .Cke   (sdram_cke_pad_o),
    .Cs_n  (sdram_cs_n_pad_o),
    .Ras_n (sdram_ras_pad_o),
    .Cas_n (sdram_cas_pad_o),
    .We_n  (sdram_we_pad_o),
    .Dqm   (sdram_dqm_pad_o)
);

endmodule
