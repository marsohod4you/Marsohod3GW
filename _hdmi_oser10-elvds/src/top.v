`include "resolution.v"

module top(
	input  CLK, KEY0, KEY1,
	input  [7:0] ADC_D,
	input  [7:0] FTD,
	input  [7:0] FTC,
	input  FTB0,
	output FTB1,
	output ADC_CLK,
	output [7:0] LED,
	output [19:0] IO,
	output       TMDS_CLK_N,
	output       TMDS_CLK_P,
	output [2:0] TMDS_D_N,
	output [2:0] TMDS_D_P
);

wire pll_lock;
wire pixel_clk_x5;

`ifdef Res640x480
Gowin_rPLL u_pll(
	.clkin( CLK ),
	.clkout( pixel_clk_x5 ),
	.lock( pll_lock )
	);
`endif

`ifdef Res800x600
Gowin_rPLL200 u_pll(
	.clkin( CLK ),
	.clkout( pixel_clk_x5 ),
	.lock( pll_lock )
	);
`endif

wire pixel_clk;
Gowin_CLKDIV u_clkdiv(
	.hclkin( pixel_clk_x5 ),
	.clkout( pixel_clk ),
	.resetn( pll_lock )
    );

wire w_hsync, w_vsync, w_active;
wire [11:0]w_pixel_cnt;
wire [11:0]w_line_cnt;
hvsync u_hvsync (
	.reset(),
	.pixel_clock( pixel_clk ),
	.hsync( w_hsync ),
	.vsync( w_vsync ),
	.active( w_active ),
	.pixel_count( w_pixel_cnt ),
	.line_count( w_line_cnt ),
	.dbg()
	);

//make Red, Green, Blue from pixel count, as vertical color stripes
reg [7:0]R;
reg [7:0]G;
reg [7:0]B;
always @(posedge pixel_clk)
begin
	if( w_pixel_cnt[8:6]==0 )
	begin
		//First vertical stripe is black 3'b000,
		//Use Dark Gray instead of Black
		R <= 8'h10;
		G <= 8'h10;
		B <= 8'h10;
	end
	else
	begin
		R <= w_pixel_cnt[8] ? { w_pixel_cnt[5:0], 2'b00 } : 8'h00;
		G <= w_pixel_cnt[7] ? { w_pixel_cnt[5:0], 2'b00 } : 8'h00;
		B <= w_pixel_cnt[6] ? { w_pixel_cnt[5:0], 2'b00 } : 8'h00;
	end
end
	
HDMI u_hdmi(
	.clk_pixel( pixel_clk ),
	.clk_5x_pixel( pixel_clk_x5 ),
	.hsync( ~w_hsync ),
	.vsync( ~w_vsync ),
	.active( w_active ),
	.red( R ),
	.green( G ),
	.blue( B ),
	.tmds_clk_n( TMDS_CLK_N ),
	.tmds_clk_p( TMDS_CLK_P ),
	.tmds_d_n( TMDS_D_N ),
	.tmds_d_p( TMDS_D_P )
	);

assign FTB1 = FTB0;
assign IO = 0;

endmodule
