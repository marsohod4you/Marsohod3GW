
//numerically controlled oscillator
module nco(
	input	rst,
	input	clk,
	input	[31:0]angle_incr,
	output	reg [16:0]sinwave, //signed
	output	reg [16:0]coswave, //signed
	output  q0,
	output  q1
);

/* Python code to calc Pi/2 in fixed point format
>>> from fxpmath import Fxp
>>> x = Fxp(1.5707963267948, True, 17, 15)
>>> x.bin(frac_dot=True)
'01.100100100001111'
*/

//angle_acc and angle_incr are always positive "fixed point" where
//.AB000000 00000000 00000000 00000000
//32'h40000000 corresponds to Pi/2
//32'h80000000 corresponds to Pi
//32'hC0000000 corresponds to (Pi/2)*3
reg [31:0]angle_acc = 0;
reg [17:0]angle_acc_rndu = 0; //rounded up
reg [31:0]angle_scaled;
wire [15:0]angle_scaled_rndu; //rounded up
reg [16:0]q0_delay = 0;
reg [16:0]q1_delay = 0;
always @(posedge clk)
begin
	angle_acc <= angle_acc + angle_incr;
    angle_acc_rndu <= angle_acc[31:14]+(|angle_acc[13:0]);
	angle_scaled <= 16'b1100100100001111 * angle_acc_rndu[15:0]; //multiply Pi/2
	q0_delay <= {q0_delay[15:0],angle_acc_rndu[16]};
	q1_delay <= {q1_delay[15:0],angle_acc_rndu[17]};
end
	
reg [16:0]x_i = 17'd19898;  //cordic gain constant 0.607253 in fixed point format
reg [16:0]y_i = 17'd0;
assign angle_scaled_rndu = angle_scaled[31:16] + (|angle_scaled[15:0]);
wire [16:0]theta_i; assign theta_i = { 1'b0, angle_scaled_rndu };

wire [16:0]x_o;
wire [16:0]y_o;
wire [16:0]theta_o;
CORDIC_Top cordic_inst(
    .clk     ( clk ),
    .rst     ( rst ),
    .x_i     ( x_i ),
    .y_i     ( y_i ),
    .theta_i ( theta_i ),
    .x_o     ( x_o ),
    .y_o     ( y_o ),
    .theta_o ( theta_o )
);

assign q0 = q0_delay[16];
assign q1 = q1_delay[16];
wire [1:0]q; assign q = { q1, q0 };

always @( posedge clk )
begin
    sinwave<= q==2'b00 ? y_o : 
              q==2'b01 ? x_o : 
              q==2'b10 ? (17'h1FFFF ^ y_o)+1 : (17'h1FFFF ^ x_o)+1 ;
    coswave<= q==2'b00 ? (17'h1FFFF ^ x_o)+1 : 
              q==2'b01 ? y_o : 
              q==2'b10 ? x_o : (17'h1FFFF ^ y_o)+1 ;
end

endmodule
