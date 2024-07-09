
module top(
	input  CLK, KEY0, KEY1,
	input  [7:0] ADC_D,
	input  [7:0] FTD,
	input  [7:0] FTC,
	input  FTB0,
	output FTB1,
	output ADC_CLK,
	output [7:0] LED,
	inout  [19:0] IO,
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

reg [31:0]cnt = 0;
reg [7:0]moving_bit;
always @( posedge pll_out_clk )
begin
		cnt <= cnt + 1;
        moving_bit <= cnt[28] ? 
                            8'h01 << cnt[27:25] :
                            8'h80 >> cnt[27:25] ;
end

wire [15:0]seg7_out;
assign seg7_out = 
    (IO[ 8]==1'b0) ? 16'h1111 :
    (IO[ 9]==1'b0) ? 16'h2222 :
    (IO[10]==1'b0) ? 16'h3333 :
    (IO[11]==1'b0) ? 16'h4444 :
                        cnt[31:16];

wire [7:0]bAfCgD_e;
wire [3:0]dig_sel;
seg4x7 seg4x7_inst(
	.clk(pll_out_clk),
	.in( seg7_out ),
	.digit_sel(dig_sel),
	.out(bAfCgD_e)
);

assign IO[6]= bAfCgD_e[6]; //A
assign IO[7]= bAfCgD_e[7]; //B
assign IO[4]= bAfCgD_e[4]; //C
assign IO[2]= bAfCgD_e[2]; //D
assign IO[0]= bAfCgD_e[0]; //E
assign IO[5]= bAfCgD_e[5]; //F
assign IO[3]= bAfCgD_e[3]; //G
assign IO[1]= bAfCgD_e[1]; //Dot

assign IO[15]= dig_sel[0];
assign IO[13]= dig_sel[1];
assign IO[12]= dig_sel[2];
assign IO[14]= dig_sel[3];

assign IO[19:16]= 4'b0000;

assign LED = KEY0 ? cnt[28:21] : moving_bit;

//Serial_RX -> Serial_TX
assign FTB1 = FTB0;

assign ADC_CLK = 1'b0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
