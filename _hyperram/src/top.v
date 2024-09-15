
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
	output [2:0] TMDS_D_P,

    //HyperRam interface
    output [1:0]  O_psram_ck,       // Magic ports for PSRAM to be inferred
    output [1:0]  O_psram_ck_n,
    inout  [1:0]  IO_psram_rwds,
    inout  [15:0] IO_psram_dq,
    output [1:0]  O_psram_reset_n,
    output [1:0]  O_psram_cs_n
);

//Serial_RX -> Serial_TX
wire serial_rx; assign serial_rx = FTB0;
wire serial_tx; assign FTB1 = serial_tx;

wire pll_out_clk;
wire pll_out_clk_p;
wire pll_locked;
Gowin_rPLL rpll(
    .clkin( CLK ),
    .clkout( pll_out_clk ),
    .lock( pll_locked )
    );

reg [28:0]cnt = 0;
reg imp = 1'b0;
always @( posedge pll_out_clk )
begin
		cnt <= cnt + 1;
        imp <= cnt[15:0]==0;
end

reg [1:0]key0r;
reg [1:0]key1r;
reg key0rst=1'b0;
reg key1imp=1'b0;
always @( posedge pll_out_clk )
begin
    if(imp)
    begin
        key0r <= { key0r[0],KEY0 };
        key1r <= { key1r[0],KEY1 };
    end
    key0rst <= (key0r==2'b01);
    key1imp <= (key1r==2'b01)&(cnt[15:0]==32);
end

wire [7:0]rbyte;
wire rbyte_ready;
wire rbyte_ready_imp;

wire [7:0]sbyteS;
wire sendS;
wire busy;
wire busyS;

serial serial_(
	.reset( key0rst ),
	.clk( CLK ),	//100MHz
	.rx( serial_rx ),
	.sbyte( sbyteS ),
	.send( sendS ),
	.rx_byte( rbyte ),
	.rbyte_ready(rbyte_ready_imp),
	.rbyte_ready_( rbyte_ready ), //longer signal
	.tx( serial_tx ),
	.busy( busyS ), 
	.rb()
	);

wire MBusy;
wire MClk;
wire [15:0]MData;
wire MDataReady;

wire Start;
wire RdWr;
wire [23:0]Addr;
wire [15:0]WrData;
wire NextWr;
ctrl ctrl_(
	.rst( key0rst ),
	.clk( pll_out_clk ),
	
	.in_data(rbyte),
	.in_data_ready(rbyte_ready),
	
	.start(Start),
	.rdwr(RdWr),
	.addr(Addr),
	.wr_data(WrData),
	.next_wr(NextWr),
	
	.mclk( MClk ),
	.mdata( MData ),
	.mdata_ready( MDataReady ),
	.mbusy( MBusy ),
	
	//to serial port
	.sclk( CLK ),
	.send_byte( sbyteS ),
	.send_imp( sendS ),
	.serial_busy( busyS )
	);

hbc hbc_
	(
		.rstn(~key0rst),
		.clk(pll_out_clk),
		.start( Start ),
		.rdwr(  RdWr ),
		.addr(  Addr ),
        .wdata( WrData ),
		.wdata_next( NextWr ),
		
		.rclk( MClk ),
		.rdata( MData ),
		.rdata_ready( MDataReady ),
        .busy( MBusy ),

		//HyperRam interface
		.o_csn(  O_psram_cs_n[0]   ),
		.o_clk(  O_psram_ck[0]     ),
		.o_clkn( O_psram_ck_n[0]   ),
		.io_dq(  IO_psram_dq[7:0]  ),
		.io_rwds( IO_psram_rwds[0]  ),
		.o_rstn( O_psram_reset_n[0] )
	);

reg [15:0]rd_data;
always @(posedge MClk)
    if( MDataReady )
        rd_data <= MData;

wire [7:0]bAfCgD_e;
wire [3:0]dig_sel;
seg4x7 seg4x7_inst(
	.clk( CLK ),
	.in( rd_data ),
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

assign ADC_CLK = 1'b0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
