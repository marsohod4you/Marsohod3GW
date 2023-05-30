// mode com4 baud=12000000 data=8
module com(
	input in,reset,
	input clk,							 //300MHZ
	output rx_byte,				// data strobe
	output reg [47:0] Q,
	output reg [17:0] A,
	output bit_clk
);

reg [2:0] cnt6;
always @(posedge clk) if(rx_byte) cnt6<= (cnt6==5)? 3'b0: cnt6 +1'b1;
always @(posedge clk) A <= reset ? 18'b0 - 18'd9 :(rx_byte&(cnt6==5))? A+1'b1: A ;
reg [7:0] r;
assign bit_clk = div_cnt[4];
localparam    DIV =25; //  
reg in_p,in_pp,receive;
reg [31:0] div_cnt;
reg [3:0] bit_cnt;
wire spad = ~in_p&in_pp;
wire tune = ~receive&spad;
wire bit  = (div_cnt==DIV-1);
wire byte =(bit_cnt==4'd9)&bit;
always @(posedge clk)  {in_pp,in_p} <= {in_p,in};
always @(posedge clk)  receive <= spad ? 1'b1: byte ?1'b0 : receive ;
always @(posedge clk)  div_cnt  <= tune? {1'b0 ,DIV[8:1]}  : bit ? 9'd0 : div_cnt +1'b1;
always @(posedge clk)  bit_cnt  <= tune? 4'd0  : bit_cnt + {3'd0,bit};
always @(posedge clk)  if(bit)  r <= {in_p,r[7:1]};
assign rx_byte = byte&receive;
reg [47:0] q;
always @(posedge clk) if(rx_byte) q <= {r,q[47:8]};
always @(posedge clk) if(rx_byte&(cnt6==1)) Q <= q;//{r,q[47:8]};
endmodule
