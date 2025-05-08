//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.09 Education
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Thu May 08 08:30:13 2025

module Gowin_pROM (dout, clk, oce, ce, reset, ad);

output [11:0] dout;
input clk;
input oce;
input ce;
input reset;
input [6:0] ad;

wire [19:0] prom_inst_0_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO({prom_inst_0_dout_w[19:0],dout[11:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,gw_gnd,gw_gnd,ad[6:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b1;
defparam prom_inst_0.BIT_WIDTH = 16;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'h0301030001050104010301020101010000D50055005500550055005500550055;
defparam prom_inst_0.INIT_RAM_01 = 256'h0301030000020000000400060000000800010000000600080305030403030302;
defparam prom_inst_0.INIT_RAM_02 = 256'h0201020001050104010301020101010004030402040104000305030403030302;
defparam prom_inst_0.INIT_RAM_03 = 256'h0000000000000000000000000000000000000000000000000000000002030202;
defparam prom_inst_0.INIT_RAM_04 = 256'h0000000000000000000000000F030F020F010F000F800F800000000000000000;

endmodule //Gowin_pROM
