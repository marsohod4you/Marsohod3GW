
module hbc
	(
		input	rstn,
		input	clk,	//2x of actual clock
		input	start,
		input	rdwr,	//read 1, write 0
		input	[23:0]addr,
		input   [15:0]wdata,
		output  wdata_next,
		
		output  rclk,	//half of input clk
		output  rdata_ready,
		output  [15:0]rdata,

		output	busy,

		//HyperRam interface
		output  o_csn,
		output  o_clk,
		output  o_clkn,
		inout   [7:0]io_dq,
		inout	io_rwds,
		output reg o_rstn
	);

parameter CLK_FREQ = 250; //input clk, MHz
parameter LATENCY = 5;
parameter BURST_LENGTH = 4; //possible values are 64, 32, 16, 8 (also 4, 2, 1, but not defined by HyperRam doc)

//hyperram will be configured for this latency
wire [3:0]cfg_reg0_latency_val;
assign cfg_reg0_latency_val = 	(LATENCY==3) ? 4'b1110 :
								(LATENCY==4) ? 4'b1111 :
								(LATENCY==5) ? 4'b0000 :
								(LATENCY==6) ? 4'b0001 :
								4'b0001; //reserved, should not be here

//calc CFG REG bit value for different burst length
wire [1:0]cfg_reg0_burst_length;
assign cfg_reg0_burst_length =  (BURST_LENGTH==64) ? 2'b00 :
								(BURST_LENGTH==32) ? 2'b01 :
								(BURST_LENGTH== 8) ? 2'b10 :
								(BURST_LENGTH== 4) ? 2'b10 :
								(BURST_LENGTH== 2) ? 2'b10 :
								(BURST_LENGTH== 1) ? 2'b10 :
								(BURST_LENGTH==16) ? 2'b11 : 2'b11;

//pass local reset to HypreRAM chip
//reg o_rstn = 1'b0;
always @(posedge clk)
	o_rstn <= rstn;

//make half clock for HyperRam
reg clk_out_enable  = 1'b0;
reg clk_out_enable_ = 1'b0;
reg half_clk  = 1'b0; //enabled by clk_out_enable
reg half_clk_ = 1'b0; //continuous
assign rclk = ~half_clk_;
//ELVDS_OBUF clk_obuf( .I(half_clk), .O(o_clk), .OB(o_clkn) );
assign o_clk  =  half_clk;
assign o_clkn = ~half_clk;
always @(negedge clk)
	if(rstn==1'b0)
	begin
		half_clk  <= 1'b0;
		half_clk_ <= 1'b1;
	end
	else
	begin
		half_clk  <= (~half_clk ) & clk_out_enable ;
		half_clk_ <= (~half_clk_) & clk_out_enable_;
	end

//after reset need to wait for POWER-UP, not less then 150 usec
localparam POWER_UP_TIME = CLK_FREQ * 160;
reg [15:0]power_up_cnt = 0;
wire power_up_done; assign power_up_done = (power_up_cnt==POWER_UP_TIME);
reg  power_up_done_ = 1'b0;
always @(posedge clk)
begin
	if( rstn==1'b0 )
		power_up_cnt <= 0;
	else
	if( ~power_up_done )
		power_up_cnt <= power_up_cnt+1;
	power_up_done_ <= power_up_done;
end

//after POWER-UP cycles do program RAM for specific latency and disable Fixed Latency
//make start_cfg signal
reg start_cfg = 1'b0;
always @(posedge clk)
	if( rstn==1'b0 )
		start_cfg <= 1'b0;
	else
		start_cfg <= power_up_done ^ power_up_done_;

wire start_io; assign start_io = start | start_cfg;

//make busy signal depending on initial configuration and cs signal
assign busy = ~power_up_done_ | start_io | clk_out_enable_;

//DDR IO Tristate data bus
wire [7:0]odqH;
wire [7:0]odqL;
wire [7:0]dq_out;

reg cs;
assign o_csn = ~cs;
always @(posedge clk)
	if(rstn==1'b0 )
		cs <= 1'b0;
	else
		cs <= start_io ? 1'b1 : 
			(state_burst_io_ | (write_cfg_reg & state_wr0_) )? 1'b0 : cs;

reg [2:0]clk_out_enable_r=3'b000;
always @(posedge clk)
begin
	if( rstn==1'b0 )
		clk_out_enable <= 1'b0;
	else
	if( start_io )
		clk_out_enable <= 1'b1;
	else
	if( state_burst_io | (write_cfg_reg & state_wr0_))
		clk_out_enable <= 1'b0;
	if( rstn==1'b0 )
		clk_out_enable_ <= 1'b0;
	else
	if( start_io | clk_out_enable | clk_out_enable_r[0] )
		clk_out_enable_ <= 1'b1;
	else
	if( clk_out_enable_r[2]==1'b0 )
		clk_out_enable_ <= 1'b0;
	clk_out_enable_r <= {clk_out_enable_r[1:0],clk_out_enable};
end

wire [7:0]idqH;
wire [7:0]idqL;
genvar i;
generate
    for (i=0; i<=7; i=i+1) begin: io_ddr
		IDDR iddr_dq( .CLK( rclk ), .D(io_dq[i]), .Q0(idqH[i]), .Q1(idqL[i]) );
	end
endgenerate

wire irwdsH;
wire irwdsL;
IDDR iddr_rwds( .CLK( rclk ), .D(io_rwds), .Q0(irwdsH), .Q1(irwdsL));

reg [95:0]state = 0;

reg add_latency = 1'b0;
wire state_capture_add_latency; assign state_capture_add_latency = state[5];
always @(posedge clk)
	if(state_capture_add_latency)
		add_latency <= irwdsH;

wire state_idle; assign state_idle = (state==8'h00);
wire state_ca; assign state_ca = |state[5:0];
wire state_wr0; assign state_wr0 = |state[7:6];
wire state_wr0_; assign state_wr0_ = state[7];

wire state_next_wr1; assign state_next_wr1 = state[LATENCY*2+3+0] | state[LATENCY*2+3+2] | state[LATENCY*2+3+4];
wire state_next_wr2; assign state_next_wr2 = state[LATENCY*4+4+0] | state[LATENCY*4+4+2] | state[LATENCY*4+4+4];
wire state_next_wr;  assign state_next_wr  = add_latency ? state_next_wr2 : state_next_wr1;

wire state_fix_wr1; assign state_fix_wr1 = state[LATENCY*2+3+2] | state[LATENCY*2+3+4] | state[LATENCY*2+3+6];
wire state_fix_wr2; assign state_fix_wr2 = state[LATENCY*4+3+2] | state[LATENCY*4+3+4] | state[LATENCY*4+3+6];
wire state_fix_wr;  assign state_fix_wr  = add_latency ? state_fix_wr2 : state_fix_wr1;

wire state_burst_wr1; assign state_burst_wr1 = |state[LATENCY*2+3+BURST_LENGTH*2:LATENCY*2+4];
wire state_burst_wr2; assign state_burst_wr2 = |state[LATENCY*4+3+BURST_LENGTH*2:LATENCY*4+4];
wire state_burst_wr;  assign state_burst_wr  = add_latency ? state_burst_wr2 : state_burst_wr1;

wire state_burst_io;  assign state_burst_io  = add_latency ? state[LATENCY*4+3+BURST_LENGTH*2] : state[LATENCY*2+3+BURST_LENGTH*2];
wire state_burst_io_; assign state_burst_io_ = add_latency ? state[LATENCY*4+4+BURST_LENGTH*2] : state[LATENCY*2+4+BURST_LENGTH*2];

wire state_burst_io_capture1; assign state_burst_io_capture1 = |state[LATENCY*2+7+BURST_LENGTH*2:LATENCY*2+7];
wire state_burst_io_capture2; assign state_burst_io_capture2 = |state[LATENCY*4+7+BURST_LENGTH*2:LATENCY*4+7];
wire state_burst_io_capture;  assign state_burst_io_capture  = add_latency ? state_burst_io_capture2 : state_burst_io_capture1;

always @(posedge clk)
	if( rstn==1'b0 )
		state <= 0;
	else
	if( state_idle)
		state <= { 94'h0, start_io };
	else
	if( ~clk_out_enable_ )
		state <= 0;
	else
		state <= { state[94:0], 1'b0 };

//at begin of transfer remember type
localparam RDWR_TYPE_READ  = 1'b1;
localparam RDWR_TYPE_WRITE = 1'b0;
localparam ADDR_TYPE_REG   = 1'b1;
localparam ADDR_TYPE_MEM   = 1'b0;
reg rdwr_type = 1'b0; //current operation type Read (1) or Write (0)
reg addr_type = 1'b0; //register (1) or memory (0)
wire write_cfg_reg; assign write_cfg_reg = (rdwr_type==RDWR_TYPE_WRITE) & (addr_type==ADDR_TYPE_REG);
wire write_mem;     assign write_mem     = (rdwr_type==RDWR_TYPE_WRITE) & (addr_type==ADDR_TYPE_MEM);
always @(posedge clk)
	if(state_idle && start_io )
	begin
		if(start_cfg)
		begin
			rdwr_type <= RDWR_TYPE_WRITE;
			addr_type <= ADDR_TYPE_REG;
		end
		else
		begin
			rdwr_type <= rdwr;
			addr_type <= ADDR_TYPE_MEM;
		end
	end

reg [63:0]dout = 0;
always @(posedge clk)
begin
	if(state_idle && start_io )
	begin
		dout <= start_cfg ? 
			{ 8'h60, 8'h00, 8'h01, 8'h00, 8'h00, 8'h00, 8'h8F, cfg_reg0_latency_val, 2'b01, cfg_reg0_burst_length } :
			{ rdwr, 1'b0, 1'b0, 3'b000, 8'h00, addr[20:19],
				  addr[18:11], addr[10:9],addr[8:3],
				  12'h000, 1'b0,addr[2:0],
				  wdata };
	end
	else
	if( state_ca | (state_wr0 & write_cfg_reg) )
	begin
		dout <= { dout[55:0], dout[7:0] };
	end
	else
	if(write_mem & state_burst_wr)
	begin
		if(state_fix_wr)
			dout <= { wdata, dout[47:0] };
		else
			dout <= { dout[55:40], dout[47:0] };
	end
end

//wire odata_ready; 
assign rdata_ready = 
		//state_single_io_capture  & irwdsH;
		state_burst_io_capture & irwdsH & (rdwr_type==RDWR_TYPE_READ);
assign rdata = { idqH, idqL };

wire dq_oen; assign dq_oen = state_ca | (write_cfg_reg & state_wr0) | (write_mem & state_burst_wr);
assign io_dq = dq_oen ? dout[63:56] : 8'bzz;

wire rwds_out; assign rwds_out = 1'b0; //state_burst_wr;
wire rwds_oen; assign rwds_oen = state_burst_wr & write_mem;
assign io_rwds = rwds_oen ? rwds_out : 1'bz;

assign wdata_next = state_next_wr & (rdwr_type==RDWR_TYPE_WRITE);

endmodule


