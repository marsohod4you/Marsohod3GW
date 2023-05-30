
module top(
	input  CLK, KEY0, KEY1,
	input  [7:0] ADC_D,
	input  [7:0] FTD,
	input  [7:0] FTC,
	input  FTB0,
	input  FTB2,
	output FTB1,
	output FTB3,
	output ADC_CLK,
	output reg [7:0] LED,
	output [18:0] IO,
	output       TMDS_CLK_N,
	output       TMDS_CLK_P,
	output [2:0] TMDS_D_N,
	output [2:0] TMDS_D_P,

    output [1:0] O_psram_ck,
    output [1:0] O_psram_ck_n,
    inout [15:0] IO_psram_dq,
    inout [1:0]  IO_psram_rwds,
    output [1:0] O_psram_cs_n,
    output [1:0] O_psram_reset_n
);

reg KEY0_p;
always @(posedge w_vsync ) KEY0_p <= KEY0;
wire press_key = ~KEY0_p&KEY0;
always @(posedge w_vsync ) if(press_key)  LED[2:0] <= LED[2:0] + 1'b1;

reg [1:0] div_cnt;
always @(posedge CLK) div_cnt <= div_cnt + 1'b1;
wire clk25 = div_cnt[1];

wire clk_out;
wire pll_lock;
wire pixel_clk_x5;
Gowin_rPLL u_pll(
	.clkin(clk_out),
	.clkout( pixel_clk_x5 ),
	.lock( pll_lock )
	);
wire pixel_clk;
Gowin_CLKDIV u_clkdiv(
	.hclkin( pixel_clk_x5 ),
	.clkout( pixel_clk ),
	.resetn( pll_lock )
    );
wire init_calib1,init_calib0;
wire w_hsync, w_vsync, w_active;
wire [11:0]w_pixel_cnt;
wire [11:0]w_line_cnt;
hvsync u_hvsync (
	.reset(~init_calib1),
	.pixel_clock( pixel_clk ),
	.hsync( w_hsync ),
	.vsync( w_vsync ),
	.active( w_active ),
	.pixel_count( w_pixel_cnt ),
	.line_count( w_line_cnt ),
	.dbg()
	);
wire [17:0] wr_adr;
wire [47:0] q;
com COM( .in(FTB0),.reset(press_key),.clk(pixel_clk),.rx_byte(),.Q(q),.A(wr_adr),.bit_clk());
wire wr_rd =com_cnt>630;
wire [20:0]adr=wr_rd?{LED[2:0],wr_adr[17:6],wr_adr[4:0],1'b0}:{LED[2:0],w_line_cnt[8:0],com_cnt[9:7],6'b0};
reg [11:0] com_cnt;
always @(posedge pixel_clk) com_cnt <= (w_pixel_cnt==768)? 12'b0:com_cnt+1'b1;
wire cmd0 = (com_cnt[6:1]==0)&(com_cnt[11:1]!=384);
wire cmd1 = (com_cnt[6:1]==32);
wire rd_data_valid0,rd_data_valid1; 
wire [31:0] rd_data0,rd_data1;
wire [31:0] wr_data = {q[47:43],q[39:34],q[31:27],q[23:19],q[15:10],q[7:3]};

reg [23:0] reset_cnt;
always @(posedge CLK) reset_cnt <= reset_cnt + !reset_cnt[23]; 
	PSRAM_Memory_Interface_HS_2CH_Top PSRAM_HS_2CH(
		.clk(clk25), //input clk
		.rst_n(reset_cnt[23]), //input rst_n 
		.memory_clk(clk25), //input memory_clk
		.pll_lock(1'b1), //input pll_lock
		.O_psram_ck(O_psram_ck), //output [1:0] O_psram_ck
		.O_psram_ck_n(O_psram_ck_n), //output [1:0] O_psram_ck_n
		.IO_psram_rwds(IO_psram_rwds), //inout [1:0] IO_psram_rwds
		.O_psram_reset_n(O_psram_reset_n), //output [1:0] O_psram_reset_n
		.IO_psram_dq(IO_psram_dq), //inout [15:0] IO_psram_dq
		.O_psram_cs_n(O_psram_cs_n), //output [1:0] O_psram_cs_n
		.init_calib0(init_calib0), //output init_calib0
		.init_calib1(init_calib1), //output init_calib1
		.clk_out(clk_out), //output clk_out
		.cmd0(~wr_adr[5]&wr_rd), //input cmd0
		.cmd1(wr_adr[5]&wr_rd), //input cmd1
		.cmd_en0(cmd0), //input cmd_en0
		.cmd_en1(cmd1), //input cmd_en1
		.addr0(adr), //input [20:0] addr0
		.addr1(adr), //input [20:0] addr1
		.wr_data0(wr_data), //input [31:0] wr_data0
		.wr_data1(wr_data), //input [31:0] wr_data1
		.rd_data0(rd_data0), //output [31:0] rd_data0
		.rd_data1(rd_data1), //output [31:0] rd_data1
		.rd_data_valid0(rd_data_valid0), //output rd_data_valid0
		.rd_data_valid1(rd_data_valid1), //output rd_data_valid1
		.data_mask0({4{~cmd0}}), //input [3:0] data_mask0
		.data_mask1({4{~cmd1}}) //input [3:0] data_mask1
	);

wire [23:0] rgb0 = w_pixel_cnt[0]?{rd_data0[31:27],3'b0,rd_data0[26:21],2'b0,rd_data0[20:16],3'b0}:
                                  {rd_data0[15:11],3'b0,rd_data0[10:5],2'b0, rd_data0[4:0],3'b0};
wire [23:0] rgb1 = w_pixel_cnt[0]?{rd_data1[31:27],3'b0,rd_data1[26:21],2'b0,rd_data1[20:16],3'b0}:
                                  {rd_data1[15:11],3'b0,rd_data1[10:5],2'b0, rd_data1[4:0],3'b0};
reg [23:0] RGB;
always @(posedge pixel_clk)
case(w_line_cnt)
//244: RGB <= {24{cmd0}};
//246: RGB <= {24{cmd1}};
//248: RGB <= {24{rd_data_valid1}};
//250: RGB <= {24{clk_out}};
default : RGB <= rd_data_valid0 ? rgb0 : rgb1;
endcase
	
HDMI u_hdmi(
	.clk_pixel( pixel_clk ),
	.clk_5x_pixel( pixel_clk_x5 ),
	.hsync( ~w_hsync ),
	.vsync( ~w_vsync ),
	.active( w_active ),
	.red( RGB[23:16] ),
	.green( RGB[15:8] ),
	.blue( RGB[7:0]  ),
	.tmds_clk_n( TMDS_CLK_N ),
	.tmds_clk_p( TMDS_CLK_P ),
	.tmds_d_n( TMDS_D_N ),
	.tmds_d_p( TMDS_D_P )
	);

assign FTB3 = FTB2;
assign IO = 0;

endmodule
