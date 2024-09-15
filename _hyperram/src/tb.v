
`timescale 1ns/1ps 

module tb;

reg rstn=1'b0;
reg i_clk =1'b0;
always @(*) begin
	i_clk  <= #5 ~i_clk;
end 

wire o_rstn;
wire o_csn;
wire o_clk;
wire o_clkn;
wire o_resetn;

// Bidirs
wire [7:0] io_dq;
wire io_rwds;

reg test_imp=1'b0;
wire [15:0]read_data;
wire read_data_ready;
wire read_clk;

reg RdWr = 1'b0;
reg [20:0]Addr  = 0;
reg [20:0]Addr2 = 0;
reg [15:0]WrData;
reg [15:0]ExpData;
reg [15:0]WrData2;
wire NextWr;

wire busy;

reg [15:0]rd0;
reg [15:0]rd1;
reg [15:0]rd2;
reg [15:0]rd3;
always @(posedge read_clk)
begin
	if(read_data_ready)
	begin
		rd3 <= rd2;
		rd2 <= rd1;
		rd1 <= rd0;
		rd0 <= read_data;
	end
end

hbc hbc_
	(
		.rstn(rstn),
		.clk(i_clk),
		.start(test_imp),
		.rdwr(RdWr),
		.addr(Addr),
		.wdata(WrData),
		.wdata_next(NextWr),

		.rclk( read_clk ),
		.rdata_ready(read_data_ready),
		.rdata(read_data),
		
		.busy( busy ),

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

reg WrDataInc = 1'b0;
always @(posedge i_clk)
	if(NextWr | WrDataInc)
		WrData <= WrData+16'h0101;

integer i,j;

initial
begin
	$dumpfile("out.vcd");
	$dumpvars(0,tb);

	test_imp=1'b0;
	rstn=1'b0;
	#40;
	rstn=1'b1;

	#10;
	@(negedge busy);
	#1;

	//Write
	Addr2 = 4;
	WrData  = 16'hAA55;
	WrData2 = WrData;
	for(j=0; j<4; j=j+1)
	begin
		$display("Try write %d",j);
		
		//write
		@(posedge i_clk);
		#0.1;
		//@(posedge i_clk);
		//#0.1;
		test_imp=1'b1;
		RdWr = 1'b0;
		Addr = Addr2;
		@(posedge i_clk);
		#0.1;
		test_imp=1'b0;
		Addr = 21'h0;
		
		#20;
		@(negedge busy);
		#1;
		
		@(posedge i_clk);
		#0.1;
		WrDataInc=1'b1;
		@(posedge i_clk);
		#0.1;
		WrDataInc=1'b0;

		for(i=0; i<4; i=i+1)
		begin
			if( hyperram.Mem[Addr2+i]!=WrData2 )
				$display("Error at Addr %X %X expect %X",Addr2+i,hyperram.Mem[i],WrData2);
			else
				$display("OK at Addr %X %X",Addr2+i,hyperram.Mem[Addr2+i]);
			WrData2 = WrData2 + 16'h0101;
		end
		Addr2 = Addr2+21'h100;
		
		#40;
	end

	//read
	Addr2 = 4;
	ExpData  = 16'hAA55;
	RdWr = 1'b1;
	for(j=0; j<4; j=j+1)
	begin
		$display("Try read %d",j);
		
		//read
		@(posedge i_clk);
		#0.1;
		//@(posedge i_clk);
		//#0.1;
		test_imp=1'b1;
		Addr = Addr2;
		@(posedge i_clk);
		#0.1;
		test_imp=1'b0;
		Addr = 21'h0;
		
		#20;
		@(negedge busy);
		#1;
		
		begin
			i=0;
			if( rd3!=ExpData )
				$display("Error read Addr %X %X expect %X",Addr2+i,rd3,ExpData);
			else
				$display("OK read Addr %X %X",Addr2+i,rd3);
			ExpData = ExpData + 16'h0101;
			
			i=1;
			if( rd2!=ExpData )
				$display("Error read Addr %X %X expect %X",Addr2+i,rd2,ExpData);
			else
				$display("OK read Addr %X %X",Addr2+i,rd2);
			ExpData = ExpData + 16'h0101;

			i=2;
			if( rd1!=ExpData )
				$display("Error read Addr %X %X expect %X",Addr2+i,rd1,ExpData);
			else
				$display("OK read Addr %X %X",Addr2+i,rd1);
			ExpData = ExpData + 16'h0101;
			
			i=3;
			if( rd0!=ExpData )
				$display("Error read Addr %X %X expect %X",Addr2+i,rd0,ExpData);
			else
				$display("OK read Addr %X %X",Addr2+i,rd0);
			ExpData = ExpData + 16'h0101;
			
			Addr2 = Addr2+21'h100;
		end
		#40;
	end

	$finish(0);
end
	
endmodule