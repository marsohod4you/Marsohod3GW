//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.09
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Mon Nov 18 16:41:42 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Advanced_FIR_Filter_Top your_instance_name(
		.clk(clk_i), //input clk
		.rstn(rstn_i), //input rstn
		.fir_rfi_o(fir_rfi_o_o), //output fir_rfi_o
		.fir_valid_i(fir_valid_i_i), //input fir_valid_i
		.fir_sync_i(fir_sync_i_i), //input fir_sync_i
		.fir_data_i(fir_data_i_i), //input [15:0] fir_data_i
		.fir_valid_o(fir_valid_o_o), //output fir_valid_o
		.fir_sync_o(fir_sync_o_o), //output fir_sync_o
		.fir_data_o(fir_data_o_o) //output [30:0] fir_data_o
	);

//--------Copy end-------------------
