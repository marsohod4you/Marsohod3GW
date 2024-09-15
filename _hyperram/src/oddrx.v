
module ODDR(
	input wire CLK,
	input wire D0,
	input wire D1,
	input wire TX,
	output wire Q0,
	output wire Q1
);
parameter TXCLK_POL = 1'b0;

reg r0_0, r0_1, r0_2;
reg r1_0, r1_1, r1_2;
reg r2_0, r2_1, r2_2, r2_3;

always @(posedge CLK)
begin
	r1_2 <= r1_1;
	r1_1 <= r1_0;
	r1_0 <= D1;
end

always @(posedge CLK)
begin
	r0_1 <= r0_0;
	r0_0 <= D0;
end

always @(negedge CLK)
begin
	r0_2 <= r0_1;
end

assign Q0 = CLK ? r0_2 : r1_2;

always @(posedge CLK)
	r2_3 <= r2_2;
	
always @(negedge CLK)
	r2_2 <= r2_1;

always @(posedge CLK)
	r2_1 <= r2_0;

always @(posedge CLK)
	r2_0 <= TX;
	
assign Q1 = TXCLK_POL ? r2_2 : r2_3;

endmodule
