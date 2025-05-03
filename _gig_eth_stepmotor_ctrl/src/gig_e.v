// 1G Ethernet rec&send example 
module gig_e(
    input  clk,key0,key1,
    input Rx_dv,
    input [3:0]Rx_D,
    input Rx_clk,
    output Tx_clk,
    output [3:0]Tx_D,
    output Tx_ena,
    output PHYRST,
    output MDC,
    inout MDIO,
    output XTAL,
    output [7:0] led,
    output wire io16,
    output wire io17,
    output wire io18,
    output wire io19
);

assign MDC = 1'b0;
assign PHYRST = 1'b1;

reg [25:0] cnt;
always @(posedge clk)
    cnt <=  cnt + 1'b1 ;

assign XTAL = cnt[1];

reg [25:0] R_cnt;
always @(posedge Rx_clk)
    R_cnt <=  R_cnt + 1'b1 ;

wire clkout;
wire clkoutp;
Gowin_rPLL inst1(
    .clkin(Rx_clk), //input clkin
    .clkout(clkout), //output clkout
    .clkoutp(clkoutp) //output clkout
);

wire r_clk = clkoutp;
wire Rx_dv_p,Rx_dv_pp;
wire [7:0] ddr_in;
Gowin_DDR  inst2(
  .din({Rx_dv,Rx_D}),
  .clk(r_clk),
  .q({Rx_dv_p,ddr_in[7:4],Rx_dv_pp,ddr_in[3:0]})
);

wire [127:0]rx_data;
wire [10:0]byte_count_;
wire my_packet_;
wire my_data_;
wire [5:0]err_cnt;
rec_packet	inst3(
	.clk(r_clk),
	.data_valid(Rx_dv_p),
	.data(ddr_in),		
	.rx_data(rx_data),
    .my_packet(my_packet_),
    .my_data(my_data_),
    .byte_count(byte_count_),
    .err_cnt(err_cnt)
);

assign led[7:0]  = key0 ? rx_data [7:0] : { err_cnt, R_cnt[25], cnt[25] };

//////////////////////////////////////////////////////////////
assign Tx_clk = clkout;
reg [25:0] T_cnt;
always @(posedge Tx_clk)
    T_cnt <= key1 ? 26'b0: T_cnt + 1'b1 ;

wire [9:0] ram_rd_adr;
wire [7:0] t_data;
wire t_ena;
send_packet	inst4(
	.clk(Tx_clk),
	.send(&{T_cnt[18:11]|rx_data [15:8],T_cnt[10:0]}),
	.padding(1'b0),
	.data({6'b0,ram_rd_adr}),
	.tx_en(t_ena),			
	.ram_adr(ram_rd_adr),
	.tx_data(t_data));

ddr_out inst5(
	.din({t_ena,t_data[7:4],t_ena,t_data[3:0]}), //input [9:0] din
	.clk(Tx_clk), //input clk
	.q({Tx_ena,Tx_D}) //output [4:0] q
);

reg [23:0]mcnt = 24'd0;
reg [2:0]mcnt8 = 3'b000;

always @(posedge clk)
begin
    if( mcnt==rx_data[23:0] )
        mcnt<=0;
    else
        mcnt<=mcnt+1;

    if( rx_data[23:0]==24'd0 )
        mcnt8<=24'd0;
    else
    if( mcnt==rx_data[23:0] )
        mcnt8<=mcnt8+1;
end

motor m(
    .clk( clk ),
	.enable( 1'b1 ),
	.dir( 1'b0 ),
	.cnt8( mcnt8 ),
	.f0( io16 ),
	.f1( io17 ),
	.f2( io18 ),
	.f3( io19 )
);

endmodule
