
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

wire cordic_rst; assign cordic_rst = ~KEY0;

wire pll_out_clk;
wire pll_locked;
Gowin_rPLL rpll(
    .clkin( CLK ),
    .clkout( pll_out_clk ),
    .lock( pll_locked )
    );

wire clk50;
Gowin_CLKDIV your_instance_name(
        .clkout(clk50), //output clkout
        .hclkin(pll_out_clk), //input hclkin
        .resetn(pll_locked) //input resetn
    );

reg [3:0]rst_cnt = 0;
reg rst = 1'b1;
always @(posedge pll_out_clk or negedge pll_locked)
	if(~pll_locked)
	begin
		rst_cnt<=4'h0;
		rst<=1'b1;
	end
	else
	begin
		if(rst_cnt!=4'hF)
			rst_cnt<=rst_cnt+1;
		rst<=(rst_cnt!=4'hF);
	end

//serial interface to PC
wire [7:0]rx_byte;
wire rbyte_ready;
serial serial_inst(
	.reset(rst),
	.clk(pll_out_clk),	//100MHz
	.rx( FTB0 ),
	.sbyte(8'h00),
	.send(1'b0),
	.rx_byte(rx_byte),
	.rbyte_ready(rbyte_ready),
	.rbyte_ready_(), //longer signal
	.tx(),
	.busy(), 
	.rb()
	);

//receive 5 sequental bytes as packet 
reg [7:0]rxb0;
reg [7:0]rxb1;
reg [7:0]rxb2;
reg [7:0]rxb3;
reg [7:0]rxb4;
reg rbyte_ready_prev = 1'b0;
wire angle_incr_set; assign angle_incr_set = rbyte_ready_prev & rxb0[7];
reg [31:0]angle_incr;
always @(posedge pll_out_clk)
begin
	rbyte_ready_prev <= rbyte_ready;
	if(rbyte_ready)
	begin
		rxb0 <= rxb1;
		rxb1 <= rxb2;
		rxb2 <= rxb3;
		rxb3 <= rxb4;
		rxb4 <= rx_byte;
	end
	if(angle_incr_set)
		angle_incr <= { 
			{rxb0[3],rxb4[6:0]},{rxb0[2],rxb3[6:0]},{rxb0[1],rxb2[6:0]},{rxb0[0],rxb1[6:0]} };
end

wire [16:0]sinw;
wire [16:0]cosw;
wire q0, q1;
nco nco_inst(
	.rst( rst ),
	.clk( clk50 ),
	.angle_incr( angle_incr ),
	.sinwave( sinw ),
	.coswave( cosw ),
    .q0( q0 ),
    .q1( q1 )
);

reg [1:0]q1sr=0;
reg [11:0]q1cnt=0;
always @(posedge clk50)
begin
    q1sr<={q1sr[0],q1};
    if(q1sr==2'b01)
        q1cnt<=q1cnt+1;
end

assign LED = KEY0 ? sinw[16:9] : cosw[16:9];

assign IO = 0;

assign ADC_CLK = 1'b0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
