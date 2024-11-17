//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.09
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Sun Oct 27 21:20:40 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	CORDIC_Top your_instance_name(
		.clk(clk_i), //input clk
		.rst(rst_i), //input rst
		.x_i(x_i_i), //input [16:0] x_i
		.y_i(y_i_i), //input [16:0] y_i
		.theta_i(theta_i_i), //input [16:0] theta_i
		.x_o(x_o_o), //output [16:0] x_o
		.y_o(y_o_o), //output [16:0] y_o
		.theta_o(theta_o_o) //output [16:0] theta_o
	);

//--------Copy end-------------------
