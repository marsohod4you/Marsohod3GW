
module ctrl(
	input wire rst,
	input wire clk,
	
	//from serial port
	input wire [7:0]in_data,
	input wire in_data_ready,
	
	//to HyperRam controller
	output reg start,
	output wire rdwr,
	output wire [23:0]addr,
	output wire [15:0]wr_data,
	input wire next_wr,
	
	//from HyperRam controller, read data
	input wire mclk,
	input wire [15:0]mdata,
	input wire mdata_ready,
	input wire mbusy,
	
	//to serial port
	input wire sclk,
	output reg [7:0]send_byte,
	output reg send_imp,
	input  wire serial_busy
	);

reg rdwr_ = 1'b0;
always @(posedge clk)
	if(start)
		rdwr_ <= rdwr;

reg [63:0]mdata_;
reg [1:0]mdata_cnt;
always @(posedge mclk)
begin
	if(mdata_ready)
		mdata_ <= { mdata_[47:0],mdata };
	if(mdata_ready)
		mdata_cnt <= mdata_cnt+1;
	else
		mdata_cnt<=2'b00;
end

reg [2:0]mbusy_sr;
reg reply_start=1'b0;
always @(posedge sclk)
begin
	mbusy_sr <= {mbusy_sr[1:0],mbusy};
	reply_start <= (mbusy_sr[2:1]==2'b10) & (rdwr_==1'b1);
end

reg [1:0]sbusy_sr=2'b00;
always @(posedge sclk)
	sbusy_sr <= {sbusy_sr[0],serial_busy};
wire was_sent; assign was_sent = sbusy_sr==2'b10;

reg [3:0]num_sent;
always @(posedge sclk)
	if(reply_start)
		num_sent<=0;
	else
	if(was_sent)
		num_sent<=num_sent+1;

always @(posedge sclk)
	send_imp <= reply_start | (was_sent&(num_sent<7));
		
always @*
begin
	case(num_sent)
		0: send_byte = mdata_[63:56];
		1: send_byte = mdata_[55:48];
		2: send_byte = mdata_[47:40];
		3: send_byte = mdata_[39:32];
		4: send_byte = mdata_[31:24];
		5: send_byte = mdata_[23:16];
		6: send_byte = mdata_[15: 8];
		7: send_byte = mdata_[ 7: 0];
	endcase
end

reg [2:0]cap_sr = 3'b000;
reg cap = 1'b0;
always @(posedge clk)
	if(rst)
	begin
		cap_sr <= 3'b000;
		cap <= 1'b0;
	end
	else
	begin
		cap_sr <= { cap_sr[1:0], in_data_ready };
		cap <= cap_sr[2:1]==2'b01;
	end

reg [1:0]nb12 = 2'b00;
reg [3:0]num_bytes = 0;
reg [95:0]adr_data = 0;
always @(posedge clk)
	if( rst )
	begin
		num_bytes <= 0;
		nb12 <= 2'b00;
		start <= 1'b0;
	end
	else
	begin
		if(cap)
			num_bytes <= num_bytes+1;
		else
		if(start)
			num_bytes <= 0;
		nb12 <= {nb12[0],(num_bytes==12)};
		start <= (nb12==2'b01);
	end

always @(posedge clk)
	if(cap)
		adr_data <= {adr_data[87:0],in_data};
	else
	if(next_wr)
		adr_data <= {adr_data[79:0],16'h0000};

assign rdwr = adr_data[95];
assign addr = adr_data[87:64];
assign wr_data = adr_data[63:48];

endmodule
