
module beeper(
	input wire clk,			//example 50MHz
    input wire rst,
	input wire beep_freq,	//one of 2 
	input wire beep_tone,	//one of 2 
	output reg [7:0]beep	//modulated beep
);

wire [4:0]sinwave[0:31];
assign sinwave[ 0] = 5'h10;
assign sinwave[ 1] = 5'h13;
assign sinwave[ 2] = 5'h15;
assign sinwave[ 3] = 5'h18;
assign sinwave[ 4] = 5'h1A;
assign sinwave[ 5] = 5'h1C;
assign sinwave[ 6] = 5'h1E;
assign sinwave[ 7] = 5'h1F;
assign sinwave[ 8] = 5'h1F;
assign sinwave[ 9] = 5'h1F;
assign sinwave[10] = 5'h1E;
assign sinwave[11] = 5'h1C;
assign sinwave[12] = 5'h1A;
assign sinwave[13] = 5'h18;
assign sinwave[14] = 5'h15;
assign sinwave[15] = 5'h13;
assign sinwave[16] = 5'h10;
assign sinwave[17] = 5'h0C;
assign sinwave[18] = 5'h0A;
assign sinwave[19] = 5'h07;
assign sinwave[20] = 5'h05;
assign sinwave[21] = 5'h03;
assign sinwave[22] = 5'h01;
assign sinwave[23] = 5'h00;
assign sinwave[24] = 5'h00;
assign sinwave[25] = 5'h00;
assign sinwave[26] = 5'h01;
assign sinwave[27] = 5'h03;
assign sinwave[28] = 5'h05;
assign sinwave[29] = 5'h07;
assign sinwave[30] = 5'h0A;
assign sinwave[31] = 5'h0C;

reg [31:0]cnt;
always @(posedge clk)
	cnt<=cnt+1'b1;

wire [4:0]addr_a; assign addr_a = cnt[4:0];
wire [4:0]addr_b; assign addr_b = beep_tone ? cnt[14:10] : cnt[15:11];
wire x;
//assign x = beep_freq ? cnt[25] : cnt[26];
assign x = cnt[25];

reg [4:0]sa;
reg [4:0]sb;
always @*
begin
	sa = sinwave[addr_a];
	sb = x ? 5'h00 : sinwave[addr_b];
end

always @(posedge clk)
	beep <= sa*sb[4:2]+sa; //-8'h80;

endmodule
