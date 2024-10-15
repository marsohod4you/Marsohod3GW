
module top(
	input  CLK, KEY0, KEY1,
	input  [7:0] ADC_D,
	input  [7:0] FTD,

	//inout  [7:0] FTC,

    input  FT_CLK,
    input  FT_RXF,
    output FT_OEN,
    output FT_RD,
    output FT_WR,

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

wire clkout_o;
wire lock_o;
Gowin_rPLL your_instance_name(
        .clkout(clkout_o), //output clkout
        .lock(lock_o), //output lock
        .clkin(FT_CLK) //input clkin
    );

reg  ft_oen; assign FT_OEN = ft_oen;
reg  ft_rd;  assign FT_RD  = ft_rd;
assign FT_WR = 1'b1;

always @(posedge clkout_o)
begin
    ft_oen <= FT_RXF;
    ft_rd  <= ft_oen | FT_RXF;
end

reg [7:0]ft_data;
always @(posedge clkout_o)
    if( ~(FT_RXF | ft_rd) )
        ft_data <= FTD;

assign LED = ft_data;

//Serial_RX -> Serial_TX
assign FTB1 = FTB0;

assign IO = 0;

assign ADC_CLK = 1'b0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
