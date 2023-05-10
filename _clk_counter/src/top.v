
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

reg [28:0]cnt = 0;
always @( posedge CLK )
	if( KEY0==1'b0)
		cnt <= 0;
	else
	if( KEY1==1'b1)
		cnt <= cnt + 1;

assign LED = cnt[28:21];

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
