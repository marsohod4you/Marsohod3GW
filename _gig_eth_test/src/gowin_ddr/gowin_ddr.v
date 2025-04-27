//
//Written by GowinSynthesis
//Product Version "GowinSynthesis V1.9.8.05"
//Tue Apr 15 09:06:30 2025

//Source file index table:
//file0 "\C:/gowin/Gowin_V1.9.8.05/IDE/ipcore/DDR/data/ddr.v"
`timescale 100 ps/100 ps
module Gowin_DDR (
  din,
  clk,
  q
)
;
input [4:0] din;
input clk;
output [9:0] q;
wire VCC;
wire GND;
  IDDR \iddr_gen[0].iddr_inst  (
    .Q0(q[0]),
    .Q1(q[5]),
    .D(din[0]),
    .CLK(clk) 
);
  IDDR \iddr_gen[1].iddr_inst  (
    .Q0(q[1]),
    .Q1(q[6]),
    .D(din[1]),
    .CLK(clk) 
);
  IDDR \iddr_gen[2].iddr_inst  (
    .Q0(q[2]),
    .Q1(q[7]),
    .D(din[2]),
    .CLK(clk) 
);
  IDDR \iddr_gen[3].iddr_inst  (
    .Q0(q[3]),
    .Q1(q[8]),
    .D(din[3]),
    .CLK(clk) 
);
  IDDR \iddr_gen[4].iddr_inst  (
    .Q0(q[4]),
    .Q1(q[9]),
    .D(din[4]),
    .CLK(clk) 
);
  VCC VCC_cZ (
    .V(VCC)
);
  GND GND_cZ (
    .G(GND)
);
  GSR GSR (
    .GSRI(VCC) 
);
endmodule /* Gowin_DDR */
