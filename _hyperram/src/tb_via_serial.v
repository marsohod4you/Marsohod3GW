
`timescale 1ns/1ps 

module tb;

reg rst=1'b0;
reg i_clk  =1'b0;
reg i_clk2 =1'b0;
always @(*) begin
	i_clk  <= #5 ~i_clk;
	i_clk2 <= #4 ~i_clk2;
end 

reg [7:0]sbyte = 8'h00;
reg send = 1'b0;
wire line_tx;

serial tbS(
	.reset( rst ),
	.clk( i_clk ),	//100MHz
	.rx( 1'b1 ),
	.sbyte( sbyte ),
	.send( send ),
	.rx_byte(),
	.rbyte_ready(),
	.rbyte_ready_(),
	.tx(line_tx),
	.busy(busy), 
	.rb()
	);


wire [7:0]rbyte;
wire rbyte_ready;
wire [7:0]sbyteS;
wire sendS;
wire busy;
reg  line_rx;
wire line_tx_S;
wire busyS;
serial S(
	.reset( rst ),
	.clk( i_clk ),	//100MHz
	.rx( line_rx ),
	.sbyte( sbyteS ),
	.send( sendS ),
	.rx_byte(rbyte),
	.rbyte_ready(),
	.rbyte_ready_(rbyte_ready), //longer signal
	.tx(line_tx_S),
	.busy(busy_S), 
	.rb()
	);

wire MClk;
wire [15:0]MData;
wire MDataReady;
wire Start;
wire RdWr;
wire [23:0]Addr;
wire [15:0]WrData;
wire NextWr;
ctrl ctrl_(
	.rst( rst ),
	.clk( i_clk2 ),
	
	.in_data(rbyte),
	.in_data_ready(rbyte_ready),
	
	.start(Start),
	.rdwr(RdWr),
	.addr(Addr),
	.wr_data(WrData),
	.next_wr(NextWr),
	
	.mclk(MClk),
	.mdata(MData),
	.mdata_ready(MDataReady),
	.mbusy(hr_busy),
	
	//to serial port
	.sclk(i_clk),
	.send_byte(sbyteS),
	.send_imp(sendS),
	.serial_busy(busy_S)
	);

always @(posedge i_clk)
	line_rx <= line_tx;

wire read_clk;
wire [15:0]read_data;
wire read_data_ready;
wire hr_busy;

wire o_rstn;
wire o_csn;
wire o_clk;
wire o_clkn;
wire o_resetn;

// Bidirs
wire [7:0] io_dq;
wire io_rwds;
	
hbc hbc_
	(
		.rstn( ~rst ),
		.clk( i_clk2 ),
		.start(Start),
		.rdwr(RdWr),
		.addr(Addr),
		.wdata(WrData),
		.wdata_next(NextWr),

		.rclk( MClk ),
		.rdata_ready(MDataReady),
		.rdata(MData),
		
		.busy( hr_busy ),

		//HyperRam interface
		.o_csn(o_csn),
		.o_clk(o_clk),
		.o_clkn(o_clkn),
		.io_dq(io_dq),
		.io_rwds(io_rwds),
		.o_rstn(o_rstn)
	);

s27kl0641 
	#(.TimingModel("S27KL0641DABHI000"))
	hyperram (
    .DQ7(io_dq[7]), 
    .DQ6(io_dq[6]), 
    .DQ5(io_dq[5]), 
    .DQ4(io_dq[4]), 
    .DQ3(io_dq[3]), 
    .DQ2(io_dq[2]), 
    .DQ1(io_dq[1]), 
    .DQ0(io_dq[0]), 
    .RWDS(io_rwds), 
    .CSNeg(o_csn), 
    .CK(o_clk), 
    .RESETNeg(o_rstn)
    );

initial
begin
	$dumpfile("out.vcd");
	$dumpvars(0,tb);

	rst = 1'b1;
	#20;
	rst = 1'b0;
	
	#1;
	@(negedge hr_busy);
	
	#10;
	send_byte( 8'h00 );	//write addr
	send_byte( 8'h00 );
	send_byte( 8'h01 );
	send_byte( 8'h08 );

	send_byte( 8'hAA );
	send_byte( 8'h55 );
	send_byte( 8'hBB );
	send_byte( 8'h66 );
	send_byte( 8'hCC );
	send_byte( 8'h77 );
	send_byte( 8'hDD );
	send_byte( 8'h88 );
	
	send_byte( 8'h80 );	//read addr
	send_byte( 8'h00 );
	send_byte( 8'h01 );
	send_byte( 8'h08 );

	send_byte( 8'h11 );
	send_byte( 8'h22 );
	send_byte( 8'h33 );
	send_byte( 8'h44 );
	send_byte( 8'h55 );
	send_byte( 8'h66 );
	send_byte( 8'h77 );
	send_byte( 8'h88 );
	
	#50000;
	$finish(0);
end

task send_byte;
input [7:0]sb;
begin
	@(posedge i_clk); #0.1;
	sbyte = sb;
	send = 1'b1;
	@(posedge i_clk); #0.1;
	sbyte = 8'h00;
	send = 1'b0;
	@(negedge busy); #20;
end
endtask

endmodule