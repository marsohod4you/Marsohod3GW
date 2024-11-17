
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

wire cordic_rst; assign cordic_rst = ~KEY0;

wire pll_out_clk;
wire pll_locked;
Gowin_rPLL rpll(
    .clkin( CLK ),
    .clkout( pll_out_clk ),
    .lock( pll_locked )
    );

wire clk50;
Gowin_CLKDIV your_instance_name(
        .clkout(clk50), //output clkout
        .hclkin(pll_out_clk), //input hclkin
        .resetn(pll_locked) //input resetn
    );

reg [3:0]rst_cnt = 0;
reg rst = 1'b1;
always @(posedge pll_out_clk or negedge pll_locked)
	if(~pll_locked)
	begin
		rst_cnt<=4'h0;
		rst<=1'b1;
	end
	else
	begin
		if(rst_cnt!=4'hF)
			rst_cnt<=rst_cnt+1;
		rst<=(rst_cnt!=4'hF);
	end

//serial interface to PC
wire [7:0]rx_byte;
wire rbyte_ready;
serial serial_inst(
	.reset(rst),
	.clk(pll_out_clk),	//100MHz
	.rx( FTB0 ),
	.sbyte(8'h00),
	.send(1'b0),
	.rx_byte(rx_byte),
	.rbyte_ready(rbyte_ready),
	.rbyte_ready_(), //longer signal
	.tx(),
	.busy(), 
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
always @(posedge pll_out_clk)
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

wire [16:0]sinw;
wire [16:0]cosw;
wire q0, q1;
nco nco_inst(
	.rst( rst ),
	.clk( clk50 ),
	.angle_incr( angle_incr ),
	.sinwave( sinw ),
	.coswave( cosw ),
    .q0( q0 ),
    .q1( q1 )
);

assign LED = cosw[16:9];

//connect NCO sinus wave to CIC filter for study
localparam CIC_NUM_BITS = 56;
wire out_valid_o;
wire [CIC_NUM_BITS-1:0]cic_out_data_o;
CIC_Fliter_Top cic_(
		.clk(clk50), //input clk
		.rstn( ~rst ), //input rstn
		.in_valid(1'b1), //input in_valid
		.in_data( sinw[16:1] ), //input [15:0] in_data
		.out_valid(out_valid_o), //output out_valid
		.out_data(cic_out_data_o) //output [CIC_NUM_BITS-1:0] out_data
	);

wire cic_out_valid; assign cic_out_valid = out_valid_o;

wire fir_rfi_o;
wire fir_valid_o_o;
wire fir_sync_o_o;
wire [30:0]fir_data_o_o;
Advanced_FIR_Filter_Top fir_(
		.clk( clk50 ), //input clk
		.rstn( ~rst ), //input rstn
		.fir_rfi_o( fir_rfi_o ), //output fir_rfi_o
		.fir_valid_i(cic_out_valid), //input fir_valid_i
		.fir_sync_i(cic_out_valid), //input fir_sync_i
		.fir_data_i(cic_out_data_o[CIC_NUM_BITS-1:CIC_NUM_BITS-16]), //input [15:0] fir_data_i
		.fir_valid_o(fir_valid_o_o), //output fir_valid_o
		.fir_sync_o(fir_sync_o_o), //output fir_sync_o
		.fir_data_o(fir_data_o_o) //output [30:0] fir_data_o
	);

//select one of possible STUDY_CIC or STUDY_CIC_PLUS_FIR
//`define STUDY_CIC 1
`define STUDY_CIC_PLUS_FIR 1
reg [31:0]cnt = 0;
reg signed [15:0]cic_ampl;
reg signed [15:0]max_cic_val_;
reg signed [15:0]min_cic_val_;
reg signed [15:0]filter_out16;
reg out_valid_o_;
always @(posedge clk50)
begin
`ifdef STUDY_CIC
    if( cic_out_valid )
        filter_out16 <= cic_out_data_o[CIC_NUM_BITS-1:CIC_NUM_BITS-16];
    out_valid_o_ <= cic_out_valid;
`else
`ifdef STUDY_CIC_PLUS_FIR
    if( fir_valid_o_o )
        filter_out16 <= fir_data_o_o[30:15];
    out_valid_o_ <= fir_valid_o_o;
`endif
`endif
    //cnt[17] is end of count
    if(out_valid_o_)
        cnt<=cnt[17] ? 0 : (cnt+1);

    if(out_valid_o_)
    begin
        if(cnt[17])
        begin
            cic_ampl <= (max_cic_val_-min_cic_val_);
            min_cic_val_ <= 16'h7fff; //+32767
            max_cic_val_ <= 16'h8001; //-32767
        end
        else
        begin
            if(max_cic_val_ < filter_out16)
                max_cic_val_ <= filter_out16;
            if(min_cic_val_ > filter_out16)
                min_cic_val_ <= filter_out16;
        end
    end
end

wire [7:0]bAfCgD_e;
wire [3:0]dig_sel;
seg4x7 seg4x7_inst(
	.clk(clk50),
	.in( cic_ampl ),
	.digit_sel(dig_sel),
	.out(bAfCgD_e)
);

assign IO[6]= bAfCgD_e[6]; //A
assign IO[7]= bAfCgD_e[7]; //B
assign IO[4]= bAfCgD_e[4]; //C
assign IO[2]= bAfCgD_e[2]; //D
assign IO[0]= bAfCgD_e[0]; //E
assign IO[5]= bAfCgD_e[5]; //F
assign IO[3]= bAfCgD_e[3]; //G
assign IO[1]= bAfCgD_e[1]; //Dot

assign IO[15]= dig_sel[0];
assign IO[13]= dig_sel[1];
assign IO[12]= dig_sel[2];
assign IO[14]= dig_sel[3];

assign IO[11: 8] = 4'b0000;
assign IO[19:16] = 4'b0000;

assign ADC_CLK = 1'b0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
