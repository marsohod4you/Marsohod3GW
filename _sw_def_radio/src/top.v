
module top(
	input  CLK, KEY0, KEY1,
	input  [7:0] ADC_D,
	input  [7:0] FTD,
	input  [7:0] FTC,
	input  FTB0,
	output FTB1,
	output ADC_CLK,
	output [7:0] LED,
	output [19:0] IO,
	output       TMDS_CLK_N,
	output       TMDS_CLK_P,
	output [2:0] TMDS_D_N,
	output [2:0] TMDS_D_P
);

//--------------------------------------------
//Clocks, make 100MHz rPLL clock from input 100MHz
wire mclk;
wire mclkp;
wire clk100; assign clk100 = CLK;
wire pll_locked;
Gowin_rPLL rpll(
    .clkin( CLK ),
    .clkout( mclk ),
    .clkoutp(mclkp),
    .lock( pll_locked )
    );

//---------------------------------------------
//capture input button
reg key0;
reg key1;
wire beeper_freq_sel = 1'b0;
wire beeper_tone_sel = key1;
always @(posedge mclk)
begin
    key0 <= KEY0;
    key1 <= KEY1;
end

//---------------------------------------------
//reset
reg [1:0]rst_cnt = 0;
reg rst = 1'b1;
always @(posedge mclk or negedge pll_locked)
	if(~pll_locked)
	begin
		rst_cnt<=2'h0;
		rst<=1'b1;
	end
	else
	begin
		if(rst_cnt!=2'h3)
			rst_cnt<=rst_cnt+1;
		rst<=(rst_cnt!=2'h3);
	end

wire cordic_rst; assign cordic_rst = rst;

//-------------------------------------------
//serial interface to PC
wire [7:0]rx_byte;
wire rbyte_ready;
reg  [7:0]tx_byte=8'h00;
reg  serial_send=1'b0;
wire serial_busy;
serial serial_inst(
	.reset(rst),
	.clk(clk100),	//100MHz
	.rx( FTB0 ),
	.sbyte(tx_byte),
	.send(serial_send),
	.rx_byte(rx_byte),
	.rbyte_ready(rbyte_ready),
	.rbyte_ready_(), //longer signal
	.tx( FTB1 ),
	.busy(serial_busy), 
	.rb()
	);

//receive 5 sequental bytes as packet 
reg [7:0]rxb0;
reg [7:0]rxb1;
reg [7:0]rxb2;
reg [7:0]rxb3;
reg [7:0]rxb4;
reg rbyte_ready_prev = 1'b0;
wire angle_incr_set; assign angle_incr_set = rbyte_ready_prev & rxb0[7];
reg [31:0]angle_incr;
always @(posedge clk100)
begin
	rbyte_ready_prev <= rbyte_ready;
	if(rbyte_ready)
	begin
		rxb0 <= rxb1;
		rxb1 <= rxb2;
		rxb2 <= rxb3;
		rxb3 <= rxb4;
		rxb4 <= rx_byte;
	end
	if(angle_incr_set)
		angle_incr <= { 
			{rxb0[3],rxb4[6:0]},{rxb0[2],rxb3[6:0]},{rxb0[1],rxb2[6:0]},{rxb0[0],rxb1[6:0]} };
end

//------------------------------------------------
//Numerically Controlled Oscilator, NCO
wire [16:0]sinw;
wire [16:0]cosw;
wire q0, q1;
nco nco_inst(
	.rst( rst ),
	.clk( mclk ),
	.angle_incr( angle_incr ),
    .sinwave( sinw ),
	.coswave( cosw ),
    .q0( q0 ),
    .q1( q1 )
);

//-----------------------------------------------
//simulated radio signal with AM
`define USE_BEEPER 1
reg  [7:0]beep_am;
`ifdef USE_BEEPER
wire [7:0]beep_am_w;
beeper beeper_inst(
	.clk(mclk),	//example 50MHz
    .rst(rst),
	.beep_freq( beeper_freq_sel ),	//one of 2 
	.beep_tone( beeper_tone_sel ),	//one of 2 
	.beep(beep_am_w)	//modulated beep 50MHz/32=1562500Hz Carrier
);

always @*
    beep_am = beep_am_w;
`else
always @*
    beep_am = ADC_D;
`endif

//-----------------------------------------------
//capture ADC data or use simulated AM signal from beeper if key0 is pressed
assign ADC_CLK = mclkp;
reg [7:0]adc_data;
always @(posedge mclk)
    adc_data <= key0 ? ADC_D : beep_am;

//-----------------------------------------------
//multiply SIN/COS wave from NCO with data from ADC
reg signed [7:0]data8;
reg signed [7:0]fsin8;
reg signed [7:0]fcos8;
reg signed [15:0]sin_x_adc;
reg signed [15:0]cos_x_adc;

always @(posedge mclk)
begin
    sin_x_adc <= $signed(adc_data-8'h80)*$signed(sinw[16:9]);
    cos_x_adc <= $signed(adc_data-8'h80)*$signed(cosw[16:9]);
end

//---------------------------------------------
//CIC filters, decimate N times
localparam CIC_OUT_NBITS = 56;
wire valid_o_s;
wire [CIC_OUT_NBITS-1:0]data_o_s;
CIC_Fliter_Top sin_adc_cic(
		.clk(mclk),            //input clk
		.rstn( ~rst ),          //input rstn
		.in_valid( 1'b1 ),      //input in_valid
		.in_data(sin_x_adc),    //input [15:0] in_data
		.out_valid(valid_o_s),  //output out_valid
		.out_data(data_o_s)     //output [CIC_OUT_NBITS-1:0] out_data
	);

wire valid_o_c;
wire [CIC_OUT_NBITS-1:0]data_o_c;
CIC_Fliter_Top cos_adc_cic(
		.clk(mclk),            //input clk
		.rstn( ~rst ),          //input rstn
		.in_valid( 1'b1 ),      //input in_valid
		.in_data(cos_x_adc),    //input [15:0] in_data
		.out_valid(valid_o_c),  //output out_valid
		.out_data(data_o_c)     //output [CIC_OUT_NBITS-1:0] out_data
	);

wire fir_ready;
reg  [7:0]cnt=0;
reg  [31:0]cic_data_sin32;
reg  [31:0]cic_data_cos32;
wire [15:0]cic_data_sin; assign cic_data_sin = cic_data_sin32[31:16];
wire [15:0]cic_data_cos; assign cic_data_cos = cic_data_cos32[31:16];
reg  [1:0]cic_delay = 4'b0000;
always @(posedge mclk)
begin
    if(valid_o_s)
        cic_data_sin32 <= data_o_s[CIC_OUT_NBITS-1:CIC_OUT_NBITS-32];
    if(valid_o_c)
        cic_data_cos32 <= data_o_c[CIC_OUT_NBITS-1:CIC_OUT_NBITS-32];
    if(fir_ready)
        cic_delay <= { cic_delay[0],valid_o_s};
end

//-----------------------------------------------
//FIR filters
wire fir_valid_o;
wire fir_sync_o;
reg  [31:0]fir_data_o0;
reg  [31:0]fir_data_o1;

`define USE_FIR 1
`ifdef USE_FIR
wire fir_sync_i;  assign fir_sync_i  = cic_delay[0];
wire fir_valid_i; assign fir_valid_i = cic_delay[0] | cic_delay[1];
wire [15:0]fir_data_i; assign fir_data_i = fir_sync_i ? cic_data_sin : cic_data_cos;
wire [30:0]fir_data_o;
Advanced_FIR_Filter_Top fir_inst(
		.clk(mclk),                //input clk
		.rstn(~rst),                //input rstn
		.fir_rfi_o(fir_ready),      //output fir_rfi_o
		.fir_valid_i(fir_valid_i),  //input fir_valid_i
		.fir_sync_i(fir_sync_i),    //input fir_sync_i
		.fir_data_i(fir_data_i),    //input [15:0] fir_data_i
		.fir_valid_o(fir_valid_o),  //output fir_valid_o
		.fir_sync_o(fir_sync_o),    //output fir_sync_o
		.fir_data_o(fir_data_o)     //output [30:0] fir_data_o
	);

always @(posedge mclk)
begin
    if( (fir_sync_o==1'b1) && fir_valid_o )
        fir_data_o0 <= {fir_data_o,1'b0};
    if( (fir_sync_o==1'b0) && fir_valid_o )
        fir_data_o1 <= {fir_data_o,1'b0};
end

`else
//take signal directly from CIC
always @*
begin
    fir_data_o0 = cic_data_sin32;
    fir_data_o1 = cic_data_cos32;
end
assign fir_sync_o = 1'b0;
assign fir_valid_o= valid_o_s;
`endif

//-----------------------------------------------
//send packets to host
reg [2:0]start_sr = 3'b000;
wire start_pkt; assign start_pkt = (start_sr[2:1]==2'b10);
reg [2:0]busy_sr = 3'b000;
wire busy_end; assign busy_end = (busy_sr[2:1]==2'b10);
always @(posedge clk100)
begin
    start_sr <= { start_sr[1:0], ( (fir_sync_o==1'b0) && fir_valid_o ) };
    busy_sr  <= { busy_sr[1:0], serial_busy };
end

reg [3:0]state = 4'b0000;
always @*
    case(state)
    0: tx_byte = { 4'b1000, fir_data_o0[31], fir_data_o0[23],fir_data_o0[15],fir_data_o0[7] };
    1: tx_byte = { 1'b0, fir_data_o0[6:  0] };
    2: tx_byte = { 1'b0, fir_data_o0[14: 8] };
    3: tx_byte = { 1'b0, fir_data_o0[22:16] };
    4: tx_byte = { 1'b0, fir_data_o0[30:24] };

    5: tx_byte = { 4'b0100, fir_data_o1[31], fir_data_o1[23],fir_data_o1[15],fir_data_o1[7] };
    6: tx_byte = { 1'b0, fir_data_o1[6:  0] };
    7: tx_byte = { 1'b0, fir_data_o1[14: 8] };
    8: tx_byte = { 1'b0, fir_data_o1[22:16] };
    9: tx_byte = { 1'b0, fir_data_o1[30:24] };
    default:
        tx_byte = 8'h00;
    endcase

always @(posedge clk100)
begin
    if(start_pkt)
        state<=0;
    else
    if(busy_end && state<9)
        state<=state+1;
    serial_send <= start_pkt | (busy_end && state<9);
    if(serial_send)
        cnt<=cnt+1;
end

//-----------------------------------------------
//assign LED =  { ~key0, 3'b000, 2'b00,beeper_freq_sel,beeper_tone_sel };
//assign LED = key0 ? cic_data_sin : cic_data_cos;
//assign LED = { 6'h00, fir_sync_i, fir_valid_i };
assign LED = 8'h00;

assign IO = 0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
