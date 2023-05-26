
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

//Max serial baud for FTDI 2232H is 12Mbit, get it from PLL
wire pll_out_clk;
wire pll_locked;
Gowin_rPLL rpll(
    .clkin( CLK ),
    .clkout( pll_out_clk ), //12MHz
    .lock( pll_locked )
    );

//count serial bits: 1 start, 8 data, 3 stop bits -> 12 bits per serial byte
reg [3:0]cnt_div12;
always @(posedge pll_out_clk)
	if(cnt_div12==11)
		cnt_div12<=0;
	else
		cnt_div12<=cnt_div12+1;

//pass clk to external ADC chip
assign ADC_CLK = pll_out_clk;

//capture ADC data
reg [7:0]adc_data;
always @(posedge pll_out_clk)
    adc_data <= ADC_D;

//show ADC data on LEDs
assign LED = adc_data;

reg [11:0]serial_out_reg;
always @(posedge pll_out_clk)
	if(cnt_div12==0)
		serial_out_reg <= { 3'b111, adc_data, 1'b0 }; //load
	else
		serial_out_reg <= { 1'b1, serial_out_reg[11:1] }; //shift out, LSB first

//Serial_TX
assign FTB1 = serial_out_reg[0]; //FTB0;
assign FTB3 = FTB2;

assign IO = 0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
