
module IDDR(
	input wire CLK,
	input wire D,
	output reg Q0,
	output reg Q1
);

reg r0;
reg r1;

always @(posedge CLK)
	r0 <= D;

always @(negedge CLK)
	r1 <= D;

always @(posedge CLK)
begin
	Q0 <= r0;
	Q1 <= r1;
end

endmodule
