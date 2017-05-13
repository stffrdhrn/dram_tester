module tester_ctrl #(
  parameter     ADDR_WIDTH    = 24
)
(
  input         clk,
  input         rst_n,

  output        rd_enable_o,
  output        wr_enable_o,
  input         busy_i,
  input         rd_ready_i,
  input  [15:0] rd_data_i,
  output [15:0] wr_data_o,
  output reg [ADDR_WIDTH-1:0] addr_o,

  output [7:0]  leds_o
);

localparam  INIT    = 4'b0000,
            WR      = 4'b0001,
            WR_WAIT = 4'b0010,
            WR_INC  = 4'b1000,
            RD      = 4'b0100,
            RD_WAIT = 4'b0101,
            VAL     = 4'b0110,
            RD_INC  = 4'b1001,
            PASS    = 4'b0011,
            FAIL    = 4'b0111;

wire	[15:0] checksum;

reg	[15:0] rd_data_r;
wire           rd_valid;

/* Counter to wait until sdram init cycle is complete.  */
reg     [ 5:0] init_cnt;

reg	[ 3:0] next;
reg	[ 3:0] state;

checksum checksum0 ({{32-ADDR_WIDTH{1'b0}}, addr_o}, checksum);

always @ (posedge clk)
if (~rst_n)
  rd_data_r <= 16'd0;
else if (rd_ready_i)
  rd_data_r <= rd_data_i;

assign rd_valid = (checksum == rd_data_r);
assign wr_enable_o = (state == WR);
assign rd_enable_o = (state == RD);
assign wr_data_o = checksum;
assign leds_o = addr_o[ADDR_WIDTH-1:ADDR_WIDTH-8];
assign init_wait = |init_cnt;

always @ (posedge clk)
if (~rst_n)
  init_cnt <= 6'b11_1111;
else if (init_wait)
  init_cnt <= init_cnt - 1'b1;

/* Handle Address INC and LED out */
/* rd_flag is for carry over to signify writes are done */
always @ (posedge clk)
if (~rst_n)
  addr_o <= 0;
else if (state[3]) /* RD_INC || WR_INC */
  addr_o <= addr_o + 1'b1;

/* Validator state machine */

always @ (*)
begin
 next = state;
 case (state)
  INIT:
    if (~init_wait)
      next = WR;
  WR:
    if (busy_i)
      next = WR_WAIT;
  WR_WAIT:
    if (~busy_i)
      next = WR_INC;
  WR_INC:
    if (&addr_o) /* Address has overflowed go to RD */
      next = RD;
    else
      next = WR;
  RD:
    if (busy_i)
      next = RD_WAIT;
  RD_WAIT:
    if (rd_ready_i)
      next = VAL;
  VAL:
    if (~rd_valid)
      next = FAIL;
    else
      next = RD_INC;
  RD_INC:
    if (&addr_o) /* Address has overflowed again done */
      next = PASS;
    else
      next = RD;
  default:
    next = state;
 endcase
end

always @ (posedge clk)
if (~rst_n)
  state <= INIT;
else
  state <= next;


endmodule
