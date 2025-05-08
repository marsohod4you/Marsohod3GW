//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.09 Education
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Sun May 04 09:20:17 2025

module Gowin_DPB (douta, doutb, clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb, ada, dina, adb, dinb);

output [15:0] douta;
output [255:0] doutb;
input clka;
input ocea;
input cea;
input reseta;
input wrea;
input clkb;
input oceb;
input ceb;
input resetb;
input wreb;
input [12:0] ada;
input [15:0] dina;
input [8:0] adb;
input [255:0] dinb;

wire [14:0] dpb_inst_0_douta_w;
wire [14:0] dpb_inst_1_douta_w;
wire [14:0] dpb_inst_2_douta_w;
wire [14:0] dpb_inst_3_douta_w;
wire [14:0] dpb_inst_4_douta_w;
wire [14:0] dpb_inst_5_douta_w;
wire [14:0] dpb_inst_6_douta_w;
wire [14:0] dpb_inst_7_douta_w;
wire [14:0] dpb_inst_8_douta_w;
wire [14:0] dpb_inst_9_douta_w;
wire [14:0] dpb_inst_10_douta_w;
wire [14:0] dpb_inst_11_douta_w;
wire [14:0] dpb_inst_12_douta_w;
wire [14:0] dpb_inst_13_douta_w;
wire [14:0] dpb_inst_14_douta_w;
wire [14:0] dpb_inst_15_douta_w;
wire gw_vcc;
wire gw_gnd;

assign gw_vcc = 1'b1;
assign gw_gnd = 1'b0;

DPB dpb_inst_0 (
    .DOA({dpb_inst_0_douta_w[14:0],douta[0]}),
    .DOB({doutb[240],doutb[224],doutb[208],doutb[192],doutb[176],doutb[160],doutb[144],doutb[128],doutb[112],doutb[96],doutb[80],doutb[64],doutb[48],doutb[32],doutb[16],doutb[0]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[0]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[240],dinb[224],dinb[208],dinb[192],dinb[176],dinb[160],dinb[144],dinb[128],dinb[112],dinb[96],dinb[80],dinb[64],dinb[48],dinb[32],dinb[16],dinb[0]})
);

defparam dpb_inst_0.READ_MODE0 = 1'b0;
defparam dpb_inst_0.READ_MODE1 = 1'b1;
defparam dpb_inst_0.WRITE_MODE0 = 2'b00;
defparam dpb_inst_0.WRITE_MODE1 = 2'b00;
defparam dpb_inst_0.BIT_WIDTH_0 = 1;
defparam dpb_inst_0.BIT_WIDTH_1 = 16;
defparam dpb_inst_0.BLK_SEL_0 = 3'b000;
defparam dpb_inst_0.BLK_SEL_1 = 3'b000;
defparam dpb_inst_0.RESET_MODE = "SYNC";

DPB dpb_inst_1 (
    .DOA({dpb_inst_1_douta_w[14:0],douta[1]}),
    .DOB({doutb[241],doutb[225],doutb[209],doutb[193],doutb[177],doutb[161],doutb[145],doutb[129],doutb[113],doutb[97],doutb[81],doutb[65],doutb[49],doutb[33],doutb[17],doutb[1]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[1]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[241],dinb[225],dinb[209],dinb[193],dinb[177],dinb[161],dinb[145],dinb[129],dinb[113],dinb[97],dinb[81],dinb[65],dinb[49],dinb[33],dinb[17],dinb[1]})
);

defparam dpb_inst_1.READ_MODE0 = 1'b0;
defparam dpb_inst_1.READ_MODE1 = 1'b1;
defparam dpb_inst_1.WRITE_MODE0 = 2'b00;
defparam dpb_inst_1.WRITE_MODE1 = 2'b00;
defparam dpb_inst_1.BIT_WIDTH_0 = 1;
defparam dpb_inst_1.BIT_WIDTH_1 = 16;
defparam dpb_inst_1.BLK_SEL_0 = 3'b000;
defparam dpb_inst_1.BLK_SEL_1 = 3'b000;
defparam dpb_inst_1.RESET_MODE = "SYNC";

DPB dpb_inst_2 (
    .DOA({dpb_inst_2_douta_w[14:0],douta[2]}),
    .DOB({doutb[242],doutb[226],doutb[210],doutb[194],doutb[178],doutb[162],doutb[146],doutb[130],doutb[114],doutb[98],doutb[82],doutb[66],doutb[50],doutb[34],doutb[18],doutb[2]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[2]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[242],dinb[226],dinb[210],dinb[194],dinb[178],dinb[162],dinb[146],dinb[130],dinb[114],dinb[98],dinb[82],dinb[66],dinb[50],dinb[34],dinb[18],dinb[2]})
);

defparam dpb_inst_2.READ_MODE0 = 1'b0;
defparam dpb_inst_2.READ_MODE1 = 1'b1;
defparam dpb_inst_2.WRITE_MODE0 = 2'b00;
defparam dpb_inst_2.WRITE_MODE1 = 2'b00;
defparam dpb_inst_2.BIT_WIDTH_0 = 1;
defparam dpb_inst_2.BIT_WIDTH_1 = 16;
defparam dpb_inst_2.BLK_SEL_0 = 3'b000;
defparam dpb_inst_2.BLK_SEL_1 = 3'b000;
defparam dpb_inst_2.RESET_MODE = "SYNC";

DPB dpb_inst_3 (
    .DOA({dpb_inst_3_douta_w[14:0],douta[3]}),
    .DOB({doutb[243],doutb[227],doutb[211],doutb[195],doutb[179],doutb[163],doutb[147],doutb[131],doutb[115],doutb[99],doutb[83],doutb[67],doutb[51],doutb[35],doutb[19],doutb[3]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[3]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[243],dinb[227],dinb[211],dinb[195],dinb[179],dinb[163],dinb[147],dinb[131],dinb[115],dinb[99],dinb[83],dinb[67],dinb[51],dinb[35],dinb[19],dinb[3]})
);

defparam dpb_inst_3.READ_MODE0 = 1'b0;
defparam dpb_inst_3.READ_MODE1 = 1'b1;
defparam dpb_inst_3.WRITE_MODE0 = 2'b00;
defparam dpb_inst_3.WRITE_MODE1 = 2'b00;
defparam dpb_inst_3.BIT_WIDTH_0 = 1;
defparam dpb_inst_3.BIT_WIDTH_1 = 16;
defparam dpb_inst_3.BLK_SEL_0 = 3'b000;
defparam dpb_inst_3.BLK_SEL_1 = 3'b000;
defparam dpb_inst_3.RESET_MODE = "SYNC";

DPB dpb_inst_4 (
    .DOA({dpb_inst_4_douta_w[14:0],douta[4]}),
    .DOB({doutb[244],doutb[228],doutb[212],doutb[196],doutb[180],doutb[164],doutb[148],doutb[132],doutb[116],doutb[100],doutb[84],doutb[68],doutb[52],doutb[36],doutb[20],doutb[4]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[4]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[244],dinb[228],dinb[212],dinb[196],dinb[180],dinb[164],dinb[148],dinb[132],dinb[116],dinb[100],dinb[84],dinb[68],dinb[52],dinb[36],dinb[20],dinb[4]})
);

defparam dpb_inst_4.READ_MODE0 = 1'b0;
defparam dpb_inst_4.READ_MODE1 = 1'b1;
defparam dpb_inst_4.WRITE_MODE0 = 2'b00;
defparam dpb_inst_4.WRITE_MODE1 = 2'b00;
defparam dpb_inst_4.BIT_WIDTH_0 = 1;
defparam dpb_inst_4.BIT_WIDTH_1 = 16;
defparam dpb_inst_4.BLK_SEL_0 = 3'b000;
defparam dpb_inst_4.BLK_SEL_1 = 3'b000;
defparam dpb_inst_4.RESET_MODE = "SYNC";

DPB dpb_inst_5 (
    .DOA({dpb_inst_5_douta_w[14:0],douta[5]}),
    .DOB({doutb[245],doutb[229],doutb[213],doutb[197],doutb[181],doutb[165],doutb[149],doutb[133],doutb[117],doutb[101],doutb[85],doutb[69],doutb[53],doutb[37],doutb[21],doutb[5]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[5]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[245],dinb[229],dinb[213],dinb[197],dinb[181],dinb[165],dinb[149],dinb[133],dinb[117],dinb[101],dinb[85],dinb[69],dinb[53],dinb[37],dinb[21],dinb[5]})
);

defparam dpb_inst_5.READ_MODE0 = 1'b0;
defparam dpb_inst_5.READ_MODE1 = 1'b1;
defparam dpb_inst_5.WRITE_MODE0 = 2'b00;
defparam dpb_inst_5.WRITE_MODE1 = 2'b00;
defparam dpb_inst_5.BIT_WIDTH_0 = 1;
defparam dpb_inst_5.BIT_WIDTH_1 = 16;
defparam dpb_inst_5.BLK_SEL_0 = 3'b000;
defparam dpb_inst_5.BLK_SEL_1 = 3'b000;
defparam dpb_inst_5.RESET_MODE = "SYNC";

DPB dpb_inst_6 (
    .DOA({dpb_inst_6_douta_w[14:0],douta[6]}),
    .DOB({doutb[246],doutb[230],doutb[214],doutb[198],doutb[182],doutb[166],doutb[150],doutb[134],doutb[118],doutb[102],doutb[86],doutb[70],doutb[54],doutb[38],doutb[22],doutb[6]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[6]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[246],dinb[230],dinb[214],dinb[198],dinb[182],dinb[166],dinb[150],dinb[134],dinb[118],dinb[102],dinb[86],dinb[70],dinb[54],dinb[38],dinb[22],dinb[6]})
);

defparam dpb_inst_6.READ_MODE0 = 1'b0;
defparam dpb_inst_6.READ_MODE1 = 1'b1;
defparam dpb_inst_6.WRITE_MODE0 = 2'b00;
defparam dpb_inst_6.WRITE_MODE1 = 2'b00;
defparam dpb_inst_6.BIT_WIDTH_0 = 1;
defparam dpb_inst_6.BIT_WIDTH_1 = 16;
defparam dpb_inst_6.BLK_SEL_0 = 3'b000;
defparam dpb_inst_6.BLK_SEL_1 = 3'b000;
defparam dpb_inst_6.RESET_MODE = "SYNC";

DPB dpb_inst_7 (
    .DOA({dpb_inst_7_douta_w[14:0],douta[7]}),
    .DOB({doutb[247],doutb[231],doutb[215],doutb[199],doutb[183],doutb[167],doutb[151],doutb[135],doutb[119],doutb[103],doutb[87],doutb[71],doutb[55],doutb[39],doutb[23],doutb[7]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[7]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[247],dinb[231],dinb[215],dinb[199],dinb[183],dinb[167],dinb[151],dinb[135],dinb[119],dinb[103],dinb[87],dinb[71],dinb[55],dinb[39],dinb[23],dinb[7]})
);

defparam dpb_inst_7.READ_MODE0 = 1'b0;
defparam dpb_inst_7.READ_MODE1 = 1'b1;
defparam dpb_inst_7.WRITE_MODE0 = 2'b00;
defparam dpb_inst_7.WRITE_MODE1 = 2'b00;
defparam dpb_inst_7.BIT_WIDTH_0 = 1;
defparam dpb_inst_7.BIT_WIDTH_1 = 16;
defparam dpb_inst_7.BLK_SEL_0 = 3'b000;
defparam dpb_inst_7.BLK_SEL_1 = 3'b000;
defparam dpb_inst_7.RESET_MODE = "SYNC";

DPB dpb_inst_8 (
    .DOA({dpb_inst_8_douta_w[14:0],douta[8]}),
    .DOB({doutb[248],doutb[232],doutb[216],doutb[200],doutb[184],doutb[168],doutb[152],doutb[136],doutb[120],doutb[104],doutb[88],doutb[72],doutb[56],doutb[40],doutb[24],doutb[8]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[8]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[248],dinb[232],dinb[216],dinb[200],dinb[184],dinb[168],dinb[152],dinb[136],dinb[120],dinb[104],dinb[88],dinb[72],dinb[56],dinb[40],dinb[24],dinb[8]})
);

defparam dpb_inst_8.READ_MODE0 = 1'b0;
defparam dpb_inst_8.READ_MODE1 = 1'b1;
defparam dpb_inst_8.WRITE_MODE0 = 2'b00;
defparam dpb_inst_8.WRITE_MODE1 = 2'b00;
defparam dpb_inst_8.BIT_WIDTH_0 = 1;
defparam dpb_inst_8.BIT_WIDTH_1 = 16;
defparam dpb_inst_8.BLK_SEL_0 = 3'b000;
defparam dpb_inst_8.BLK_SEL_1 = 3'b000;
defparam dpb_inst_8.RESET_MODE = "SYNC";

DPB dpb_inst_9 (
    .DOA({dpb_inst_9_douta_w[14:0],douta[9]}),
    .DOB({doutb[249],doutb[233],doutb[217],doutb[201],doutb[185],doutb[169],doutb[153],doutb[137],doutb[121],doutb[105],doutb[89],doutb[73],doutb[57],doutb[41],doutb[25],doutb[9]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[9]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[249],dinb[233],dinb[217],dinb[201],dinb[185],dinb[169],dinb[153],dinb[137],dinb[121],dinb[105],dinb[89],dinb[73],dinb[57],dinb[41],dinb[25],dinb[9]})
);

defparam dpb_inst_9.READ_MODE0 = 1'b0;
defparam dpb_inst_9.READ_MODE1 = 1'b1;
defparam dpb_inst_9.WRITE_MODE0 = 2'b00;
defparam dpb_inst_9.WRITE_MODE1 = 2'b00;
defparam dpb_inst_9.BIT_WIDTH_0 = 1;
defparam dpb_inst_9.BIT_WIDTH_1 = 16;
defparam dpb_inst_9.BLK_SEL_0 = 3'b000;
defparam dpb_inst_9.BLK_SEL_1 = 3'b000;
defparam dpb_inst_9.RESET_MODE = "SYNC";

DPB dpb_inst_10 (
    .DOA({dpb_inst_10_douta_w[14:0],douta[10]}),
    .DOB({doutb[250],doutb[234],doutb[218],doutb[202],doutb[186],doutb[170],doutb[154],doutb[138],doutb[122],doutb[106],doutb[90],doutb[74],doutb[58],doutb[42],doutb[26],doutb[10]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[10]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[250],dinb[234],dinb[218],dinb[202],dinb[186],dinb[170],dinb[154],dinb[138],dinb[122],dinb[106],dinb[90],dinb[74],dinb[58],dinb[42],dinb[26],dinb[10]})
);

defparam dpb_inst_10.READ_MODE0 = 1'b0;
defparam dpb_inst_10.READ_MODE1 = 1'b1;
defparam dpb_inst_10.WRITE_MODE0 = 2'b00;
defparam dpb_inst_10.WRITE_MODE1 = 2'b00;
defparam dpb_inst_10.BIT_WIDTH_0 = 1;
defparam dpb_inst_10.BIT_WIDTH_1 = 16;
defparam dpb_inst_10.BLK_SEL_0 = 3'b000;
defparam dpb_inst_10.BLK_SEL_1 = 3'b000;
defparam dpb_inst_10.RESET_MODE = "SYNC";

DPB dpb_inst_11 (
    .DOA({dpb_inst_11_douta_w[14:0],douta[11]}),
    .DOB({doutb[251],doutb[235],doutb[219],doutb[203],doutb[187],doutb[171],doutb[155],doutb[139],doutb[123],doutb[107],doutb[91],doutb[75],doutb[59],doutb[43],doutb[27],doutb[11]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[11]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[251],dinb[235],dinb[219],dinb[203],dinb[187],dinb[171],dinb[155],dinb[139],dinb[123],dinb[107],dinb[91],dinb[75],dinb[59],dinb[43],dinb[27],dinb[11]})
);

defparam dpb_inst_11.READ_MODE0 = 1'b0;
defparam dpb_inst_11.READ_MODE1 = 1'b1;
defparam dpb_inst_11.WRITE_MODE0 = 2'b00;
defparam dpb_inst_11.WRITE_MODE1 = 2'b00;
defparam dpb_inst_11.BIT_WIDTH_0 = 1;
defparam dpb_inst_11.BIT_WIDTH_1 = 16;
defparam dpb_inst_11.BLK_SEL_0 = 3'b000;
defparam dpb_inst_11.BLK_SEL_1 = 3'b000;
defparam dpb_inst_11.RESET_MODE = "SYNC";

DPB dpb_inst_12 (
    .DOA({dpb_inst_12_douta_w[14:0],douta[12]}),
    .DOB({doutb[252],doutb[236],doutb[220],doutb[204],doutb[188],doutb[172],doutb[156],doutb[140],doutb[124],doutb[108],doutb[92],doutb[76],doutb[60],doutb[44],doutb[28],doutb[12]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[12]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[252],dinb[236],dinb[220],dinb[204],dinb[188],dinb[172],dinb[156],dinb[140],dinb[124],dinb[108],dinb[92],dinb[76],dinb[60],dinb[44],dinb[28],dinb[12]})
);

defparam dpb_inst_12.READ_MODE0 = 1'b0;
defparam dpb_inst_12.READ_MODE1 = 1'b1;
defparam dpb_inst_12.WRITE_MODE0 = 2'b00;
defparam dpb_inst_12.WRITE_MODE1 = 2'b00;
defparam dpb_inst_12.BIT_WIDTH_0 = 1;
defparam dpb_inst_12.BIT_WIDTH_1 = 16;
defparam dpb_inst_12.BLK_SEL_0 = 3'b000;
defparam dpb_inst_12.BLK_SEL_1 = 3'b000;
defparam dpb_inst_12.RESET_MODE = "SYNC";

DPB dpb_inst_13 (
    .DOA({dpb_inst_13_douta_w[14:0],douta[13]}),
    .DOB({doutb[253],doutb[237],doutb[221],doutb[205],doutb[189],doutb[173],doutb[157],doutb[141],doutb[125],doutb[109],doutb[93],doutb[77],doutb[61],doutb[45],doutb[29],doutb[13]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[13]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[253],dinb[237],dinb[221],dinb[205],dinb[189],dinb[173],dinb[157],dinb[141],dinb[125],dinb[109],dinb[93],dinb[77],dinb[61],dinb[45],dinb[29],dinb[13]})
);

defparam dpb_inst_13.READ_MODE0 = 1'b0;
defparam dpb_inst_13.READ_MODE1 = 1'b1;
defparam dpb_inst_13.WRITE_MODE0 = 2'b00;
defparam dpb_inst_13.WRITE_MODE1 = 2'b00;
defparam dpb_inst_13.BIT_WIDTH_0 = 1;
defparam dpb_inst_13.BIT_WIDTH_1 = 16;
defparam dpb_inst_13.BLK_SEL_0 = 3'b000;
defparam dpb_inst_13.BLK_SEL_1 = 3'b000;
defparam dpb_inst_13.RESET_MODE = "SYNC";

DPB dpb_inst_14 (
    .DOA({dpb_inst_14_douta_w[14:0],douta[14]}),
    .DOB({doutb[254],doutb[238],doutb[222],doutb[206],doutb[190],doutb[174],doutb[158],doutb[142],doutb[126],doutb[110],doutb[94],doutb[78],doutb[62],doutb[46],doutb[30],doutb[14]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[14]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[254],dinb[238],dinb[222],dinb[206],dinb[190],dinb[174],dinb[158],dinb[142],dinb[126],dinb[110],dinb[94],dinb[78],dinb[62],dinb[46],dinb[30],dinb[14]})
);

defparam dpb_inst_14.READ_MODE0 = 1'b0;
defparam dpb_inst_14.READ_MODE1 = 1'b1;
defparam dpb_inst_14.WRITE_MODE0 = 2'b00;
defparam dpb_inst_14.WRITE_MODE1 = 2'b00;
defparam dpb_inst_14.BIT_WIDTH_0 = 1;
defparam dpb_inst_14.BIT_WIDTH_1 = 16;
defparam dpb_inst_14.BLK_SEL_0 = 3'b000;
defparam dpb_inst_14.BLK_SEL_1 = 3'b000;
defparam dpb_inst_14.RESET_MODE = "SYNC";

DPB dpb_inst_15 (
    .DOA({dpb_inst_15_douta_w[14:0],douta[15]}),
    .DOB({doutb[255],doutb[239],doutb[223],doutb[207],doutb[191],doutb[175],doutb[159],doutb[143],doutb[127],doutb[111],doutb[95],doutb[79],doutb[63],doutb[47],doutb[31],doutb[15]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,ada[12:0]}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[15]}),
    .ADB({gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB({dinb[255],dinb[239],dinb[223],dinb[207],dinb[191],dinb[175],dinb[159],dinb[143],dinb[127],dinb[111],dinb[95],dinb[79],dinb[63],dinb[47],dinb[31],dinb[15]})
);

defparam dpb_inst_15.READ_MODE0 = 1'b0;
defparam dpb_inst_15.READ_MODE1 = 1'b1;
defparam dpb_inst_15.WRITE_MODE0 = 2'b00;
defparam dpb_inst_15.WRITE_MODE1 = 2'b00;
defparam dpb_inst_15.BIT_WIDTH_0 = 1;
defparam dpb_inst_15.BIT_WIDTH_1 = 16;
defparam dpb_inst_15.BLK_SEL_0 = 3'b000;
defparam dpb_inst_15.BLK_SEL_1 = 3'b000;
defparam dpb_inst_15.RESET_MODE = "SYNC";

endmodule //Gowin_DPB
