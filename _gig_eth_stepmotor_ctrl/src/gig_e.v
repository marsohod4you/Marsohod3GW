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
    output wire io19,

    input [7:0]ADC_D,
    output ADC_CLK
);

assign MDC = 1'b0;
assign PHYRST = 1'b1;

reg [25:0] cnt;
always @(posedge clk)
    cnt <=  cnt + 1'b1 ;

/*
assign ADC_CLK = cnt[2];
reg [7:0]adc_data;
always @(posedge ADC_CLK)
    adc_data <= ADC_D;
*/
assign ADC_CLK = 1'b0;

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
wire [7:0] rx_ddr_in;
Gowin_DDR  inst2(
  .din({Rx_dv,Rx_D}),
  .clk(r_clk),
  .q({Rx_dv_p,rx_ddr_in[7:4],Rx_dv_pp,rx_ddr_in[3:0]})
);

wire [10:0]byte_cnt;
wire [2:0]pkt_cnt;
wire [7:0]rx_crc32_err_cnt;
wire rx_crc32_ok;
wire [12:0]memwr_addr_;
wire [15:0]memwr_data_;
wire memwr_;
rx_crc32 rx_crc32_inst(
	.clk(r_clk),
	.data_valid(Rx_dv_p),
	.data(rx_ddr_in),
    .byte_count(byte_cnt),
    .pkt_head(pkt_cnt),
    .memwr_addr(memwr_addr_),
    .memwr_data(memwr_data_),
    .memwr(memwr_),
	.crc32_ok(rx_crc32_ok),
    .err_cnt(rx_crc32_err_cnt)
);

wire [8:0]rd_addr;
wire [255:0]rd_data;
Gowin_DPB dpram_inst(
        .reseta( 1'b0 ),    //input reseta
        .clka(r_clk),       //input clka
        .douta(),           //output [7:0] douta
        .ocea(1'b1),        //input ocea
        .cea(1'b1),         //input cea
        .wrea(memwr_),      //input wrea
        .ada(memwr_addr_),  //input [12:0] ada
        .dina(memwr_data_), //input [15:0] dina

        .resetb( 1'b0 ),    //input resetb
        .clkb(r_clk),       //input clkb
        .oceb(1'b1),        //input oceb
        .ceb(1'b1),         //input ceb
        .wreb( 1'b0 ),      //input wreb
        .dinb(256'd0),      //input [255:0] dinb
        .adb(rd_addr),      //input [8:0] adb
        .doutb(rd_data)     //output [255:0] doutb
    );

wire [6:0]ad_i;
wire [11:0]dout_o;
Gowin_pROM prom_inst(
        .reset(1'b0),   //input reset
        .clk(r_clk),    //input clk
        .oce(1'b1),     //input oce
        .ce(1'b1),      //input ce
        .ad(ad_i),      //input [11:0] ad
        .dout(dout_o)  //output [11:0] dout
    );

wire [7:0]wr_fifo_data;
wire wr_fifo;
wire [63:0]udp_payload;
pkt_reader pkt_reader_inst(
	.clk(r_clk),
	.raddr(rd_addr),
	.data(rd_data),
	.head(pkt_cnt),
	.rom_addr(ad_i),
    .rom_byte(dout_o),
	.send_byte(wr_fifo_data),
	.send(wr_fifo),
	.broadcast(),
	.led(),
	.crc32(),
    .udp_payload(udp_payload)
);

//udp_payload is data received from UDP command
assign led[7:0] = udp_payload[7:0];
wire [23:0]motor_step_time;
assign motor_step_time = udp_payload[55:32];

assign Tx_clk = clkout;

wire Empty_o;
wire [7:0]t_data;
reg fifo_rd_req = 1'b0;
reg t_ena_ = 1'b0;
reg t_ena  = 1'b0;
always @(posedge Tx_clk)
begin
    fifo_rd_req <= !Empty_o;
    t_ena_ <= fifo_rd_req;
    t_ena  <= t_ena_ & fifo_rd_req;
end
    
FIFO_HS_Top fifo_inst(
		.WrClk(r_clk),          //input WrClk
		.Data(wr_fifo_data),    //input [7:0] Data
		.WrEn(wr_fifo),         //input WrEn
		.RdClk(Tx_clk),         //input RdClk
		.RdEn(fifo_rd_req),     //input RdEn
		.Rnum(),                //output [11:0] Rnum
		.Almost_Empty(),        //output Almost_Empty
		.Almost_Full(),         //output Almost_Full
		.Q(t_data),             //output [7:0] Q
		.Empty(Empty_o),        //output Empty
		.Full()                 //output Full
	);

//////////////////////////////////////////////////////////////

ddr_out inst5(
	.din({t_ena,t_data[7:4],t_ena,t_data[3:0]}), //input [9:0] din
	.clk(Tx_clk), //input clk
	.q({Tx_ena,Tx_D}) //output [4:0] q
);

//////////////////////////////////////////////////////////////
reg [23:0]mcnt = 24'd0;
reg [2:0]mcnt8 = 3'b000;

always @(posedge clk)
begin
    if( mcnt==motor_step_time )
        mcnt<=0;
    else
        mcnt<=mcnt+1;

    if( motor_step_time==24'd0 )
        mcnt8<=24'd0;
    else
    if( mcnt==motor_step_time )
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
