
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

wire pll_out_clk;
wire pll_locked;
Gowin_rPLL rpll(
    .clkin( CLK ),
    .clkout( pll_out_clk ),
    .lock( pll_locked )
    );

reg [28:0]cnt = 0;
reg [7:0]moving_bit;
always @( posedge pll_out_clk )
begin
		cnt <= cnt + 1;
        moving_bit <= cnt[26] ? 
                            8'h01 << cnt[25:23] :
                            8'h80 >> cnt[25:23] ;
end

assign LED = KEY0 ? cnt[28:21] : moving_bit;

//Serial_RX -> Serial_TX
assign FTB1 = FTB0;
assign FTB3 = FTB2;

assign IO = 0;

assign ADC_CLK = 1'b0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
