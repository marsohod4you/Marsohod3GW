
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
	output [7:0] LED,
	output [18:0] IO,
	output       TMDS_CLK_N,
	output       TMDS_CLK_P,
	output [2:0] TMDS_D_N,
	output [2:0] TMDS_D_P
);

wire pll_lock;
wire pixel_clk_x5;
Gowin_rPLL u_pll(
	.clkin( CLK ),
	.clkout( pixel_clk_x5 ),
	.lock( pll_lock )
	);

wire pixel_clk;
Gowin_CLKDIV u_clkdiv(
	.hclkin( pixel_clk_x5 ),
	.clkout( pixel_clk ),
	.resetn( pll_lock )
    );

reg div2=1'b0;
assign ADC_CLK = div2;
always @(posedge pixel_clk)
	div2 <= ~div2;

reg [7:0]adc_r0;
reg [8:0]adc_r1;
reg hi_lo = 1'b0;
reg [10:0]rocketY = 0;
always @(posedge div2)
begin
	hi_lo <= ~hi_lo;
	if( ~hi_lo)
		adc_r0 <= ADC_D;
	if( hi_lo)
		adc_r1 <= adc_r0+ADC_D;
		
	if(adc_r1<8)
		rocketY<= 8;
	else
	if(adc_r1>(480-64-8))
		rocketY<= (480-64-8);
	else
		rocketY<=adc_r1;
end
assign LED=adc_r0;

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

reg [31:0]cnt;
wire cnt_end; assign cnt_end = (cnt==32'h20000);
reg imp = 1'b0;
always @(posedge pixel_clk)
begin
	if( cnt_end )
		cnt<=0;
	else
		cnt <= cnt+1;
	imp <= cnt_end;
end

reg [10:0]X = 64;
reg [10:0]Y = 32;
reg dirX = 1'b1;
reg dirY = 1'b1;

reg ball = 1'b0;
always @(posedge pixel_clk)
begin
	ball <=( w_pixel_cnt>=X  && w_pixel_cnt<(X+16) ) && ( w_line_cnt>=Y  && w_line_cnt<(Y+16) ) ;
	if( imp )
	begin
		if( (Y==8 && dirY==0) ||  (Y==462 && dirY==1)) dirY <= ~dirY;
		if( (X==8 && dirX==0) ||  (X==624 && dirX==1) || (X==600 && dirX==1 && Y>rocketY && Y<(rocketY+64)) ) dirX <= ~dirX;
		if( dirX ) X<=X+1; else X<=X-1; 
		if( dirY ) Y<=Y+1; else Y<=Y-1; 
	end
end

reg border=1'b0;
always @(posedge pixel_clk)
	border <=( w_pixel_cnt<8 || w_line_cnt<8 || w_line_cnt>472 );

reg rocket = 1'b0;
always @(posedge pixel_clk)
	rocket <= ( w_pixel_cnt>=616 && w_pixel_cnt<632 ) && (w_line_cnt>rocketY && w_line_cnt<(rocketY+64));

//make Red, Green, Blue from pixel count, as vertical color stripes
reg [7:0]R;
reg [7:0]G;
reg [7:0]B;
always @(posedge pixel_clk)
begin
	if( border )
	begin
		R <= 8'hFF;
		G <= 8'h40;
		B <= 8'h40;
	end
	else
	if( ball )
	begin
		R <= 8'hFF;
		G <= 8'hFF;
		B <= 8'h00;
	end
	else
	if( rocket )
	begin
		R <= 8'h10;
		G <= 8'h10;
		B <= 8'hFF;
	end
	else
	begin
		R <= 8'h40;
		G <= 8'h80;
		B <= 8'h40;
	end
end
	
HDMI u_hdmi(
	.clk_pixel( pixel_clk ),
	.clk_5x_pixel( pixel_clk_x5 ),
	.hsync(  ~w_hsync ),
	.vsync(  ~w_vsync ),
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
assign FTB3 = FTB2;
assign IO = 0;

endmodule
