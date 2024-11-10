  
module serial(
	input wire reset,
	input wire clk,	//100MHz
	input wire rx,
	input wire [7:0]sbyte,
	input wire send,
	output reg [7:0]rx_byte,
	output reg rbyte_ready,
	output reg rbyte_ready_, //longer signal
	output reg tx,
	output reg busy, 
	output wire [7:0]rb
	);

parameter CLK_FREQ = 100;	//input clk, MHz
parameter BAUD = 12;		//wanted baud, MHz

localparam NUMBITS = 10;
localparam BIT_TIME = 256;
localparam BSTEP = BIT_TIME * BAUD / CLK_FREQ +1;

//---------RECV PART ------------------------------------
reg  [8:0]cntxr; //measure bit time by adding BSTEP
wire [8:0]cntxw;  assign cntxw = cntxr+BSTEP;

assign rb = {1'b0,rx_byte[7:1]};

reg [1:0]shr;
always @(posedge clk)
	shr <= {shr[0],rx};
wire rxf; assign rxf = shr[1];
wire rx_neg_edge; assign rx_neg_edge = (shr==2'b10);
wire rx_pos_edge; assign rx_pos_edge = (shr==2'b01);
wire rx_edge; assign rx_edge = rx_neg_edge || rx_pos_edge;

reg [3:0]num_bits;

wire eobit; assign eobit = cntxr[8];
reg [1:0]cap=2'b00;
always @( posedge clk )
begin
	if(reset)
	begin
		cntxr <= 9'h000;
		cap <=2'b00;
	end
	else
	begin
		if( rx_edge || num_bits==NUMBITS)
			cntxr <= BSTEP*2;
		else
			cntxr <= cntxr[8] ? {1'b0,cntxw[7:0]} : cntxw;
		cap <= {cap[0],cntxr[7:0]>BIT_TIME/3};
	end
end

reg [7:0]shift_reg;
//wire capture; assign capture = (cnt==RCONST/2);
wire capture; assign capture = cap==2'b01;

always @( posedge clk )
begin
	if(reset)
	begin
		num_bits <= NUMBITS;
		shift_reg <= 0;
	end
	else
	begin
		if(num_bits==NUMBITS && rx_neg_edge )
			num_bits <= 0;
		else
		if( capture )
			num_bits <= num_bits + 1'b1;
		
		if( capture )
			shift_reg <= {rxf,shift_reg[7:1]};
	end
end

reg [3:0]ready_sr = 4'b0000;
always @( posedge clk )
	if( reset )
	begin
		rbyte_ready  <= 1'b0;
		rbyte_ready_ <= 1'b0;
		ready_sr     <= 4'b0000;
	end
	else
	begin
		ready_sr <= {ready_sr[2:0],num_bits==9};
		rbyte_ready  <= (ready_sr==4'b0001);
		rbyte_ready_ <= (~ready_sr[3]) & (|ready_sr[2:0]);
	end

always @( posedge clk )
	if(reset)
		rx_byte <= 0;
	else
	if(num_bits==9)
		rx_byte <= shift_reg[7:0];

//---------SEND PART ------------------------------------
reg [8:0]send_reg;
reg [3:0]send_num;
reg [15:0]send_cnt;

reg  [8:0]cntsr; //measure bit time by adding BSTEP
wire [8:0]cntsw;  assign cntsw = cntsr+BSTEP;

wire send_time; assign send_time = cntsr[8];

always @( posedge clk )
begin
	if(reset)
	begin
		send_reg <= 9'h1FF;
		send_num <= NUMBITS;
		send_cnt <= 0;
		cntsr    <= 0;
	end
	else
	begin
		if(send)
			cntsr <= BSTEP*2;
		else
		if( send_num!=NUMBITS )
			cntsr <= send_time ? {1'b0,cntsw[7:0]} : cntsw;

		if(send)
		begin
			send_reg <= {sbyte,1'b0};
			send_num <= 0;
		end
		else
		if(send_time && send_num!=NUMBITS)
		begin
			send_reg <= {1'b1,send_reg[8:1]};
			send_num <= send_num + 1'b1;
		end
	end
end

always @*
begin
	busy = send_num!=NUMBITS;
	tx = send_reg[0];
end
	
endmodule
