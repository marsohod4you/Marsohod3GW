//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.09
//Part Number: GW1NR-UV9QN88PC6/I5
//Device: GW1NR-9
//Created Time: Sat May 27 18:19:50 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_rPLL200 your_instance_name(
        .clkout(clkout_o), //output clkout
        .lock(lock_o), //output lock
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
