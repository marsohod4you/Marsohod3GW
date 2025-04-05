
module top(
	input  CLK, KEY0, KEY1,
	input  [7:0] ADC_D,
	input  [7:0] FTD,
	input  [7:0] FTC,
	input  FTB0,
	output FTB1,
	output ADC_CLK,
	output [7:0] LED,
	inout [19:0] IO,
	output       TMDS_CLK_N,
	output       TMDS_CLK_P,
	output [2:0] TMDS_D_N,
	output [2:0] TMDS_D_P
);

localparam PLL_FREQ = 80000000;
localparam FREQ = (PLL_FREQ/256);
localparam LEVEL_HI = 8'hA0;
localparam LEVEL_LO = 8'h60;
localparam DIFF = 10;

localparam STATE_FORWARD  = 5'b00001;
localparam STATE_BACKWARD = 5'b00010;
localparam STATE_LEFT     = 5'b00100;
localparam STATE_RIGHT    = 5'b01000;
localparam STATE_STOP     = 5'b10000;

wire pll_out_clk;
wire pll_locked;
Gowin_rPLL rpll(
    .clkin( CLK ),
    .clkout( pll_out_clk ), // pll_out_clk = PLL_FREQ
    .lock( pll_locked )
    );

reg [23:0]cnt=0;
always @(posedge pll_out_clk)
    cnt=cnt+1;

wire adc_clk; assign adc_clk = cnt[1]; // PLL_FREQ / 4  = 20MHz
wire clk;     assign clk = cnt[7];     // PLL_FREQ / 256 = 312500 Hz

//pass clk to external ADC chip (note ADC may not work on too lower frequencies)
assign ADC_CLK = adc_clk;

//capture ADC data
reg [7:0]adc_cap = 0;
always @( posedge adc_clk )
    adc_cap <= ADC_D;

//capture ADC data
reg [7:0]adc_data0 = 8'h00;
reg [7:0]adc_data1 = 8'h00;
reg [7:0]adc_data2 = 8'h00;
reg [7:0]adc_data3 = 8'h00;
reg [7:0]overage   = 8'h00;
reg trigger = 1'b0;
reg [1:0]trigger_sr = 2'b00;
wire aedge; assign aedge = (trigger_sr==2'b01);

//measure period counter
reg [15:0]measure_cnt = 0;
//detected freqs
reg [1:0]f1000 = 2'b00;
reg [1:0]f1200 = 2'b00;
reg [1:0]f1400 = 2'b00;
reg [1:0]f1600 = 2'b00;
reg [1:0]f1800 = 2'b00;

always @(posedge clk)
begin
    adc_data3 <= adc_data2;
    adc_data2 <= adc_data1;
    adc_data1 <= adc_data0;
    adc_data0 <= adc_cap;

    overage <= (adc_data3+adc_data2+adc_data1+adc_data0) / 4;
    if(overage>LEVEL_HI) trigger <= 1'b1;
    else 
    if(overage<LEVEL_LO) trigger <= 1'b0;

    trigger_sr <= { trigger_sr[0], trigger };

    if( aedge )
        measure_cnt <= 0; //restart counting from wave top
    else
    if(measure_cnt<1023)  //do not count more then limit
        measure_cnt <= measure_cnt+1;
   
	if(measure_cnt==1023)
    begin
        //no sound waves
		f1000 <= { f1000[0] , 1'b0 };
    	f1200 <= { f1200[0] , 1'b0 };
    	f1400 <= { f1400[0] , 1'b0 };
    	f1600 <= { f1600[0] , 1'b0 };
    	f1800 <= { f1800[0] , 1'b0 };
    end
    else
    if( aedge )
    begin
		f1000 <= { f1000[0] , (measure_cnt>(FREQ/1000-DIFF)) & (measure_cnt<(FREQ/1000+DIFF)) };
		f1200 <= { f1200[0] , (measure_cnt>(FREQ/1200-DIFF)) & (measure_cnt<(FREQ/1200+DIFF)) };
		f1400 <= { f1400[0] , (measure_cnt>(FREQ/1400-DIFF)) & (measure_cnt<(FREQ/1400+DIFF)) };
		f1600 <= { f1600[0] , (measure_cnt>(FREQ/1600-DIFF)) & (measure_cnt<(FREQ/1600+DIFF)) };
		f1800 <= { f1800[0] , (measure_cnt>(FREQ/1800-DIFF)) & (measure_cnt<(FREQ/1800+DIFF)) };
    end
end

reg [7:0]state = 8'h00;
always @(posedge clk)
begin
	if(f1000==2'b01)
		state[4:0] <= STATE_FORWARD;
	else
	if(f1200==2'b01)
		state[4:0] <= STATE_BACKWARD;
	else
	if(f1400==2'b01)
		state[4:0] <= STATE_LEFT;
	else
	if(f1600==2'b01)
		state[4:0] <= STATE_RIGHT;
	else
	if(f1800==2'b01)
		state[4:0] <= STATE_STOP;
	state[7:5] <= 3'b000;
end

assign LED = state;

reg motor0_ena=1'b0;
reg motor0_dir=1'b0;
reg motor1_ena=1'b0;
reg motor1_dir=1'b0;
always @(posedge clk)
	case (state[4:0])
		STATE_FORWARD:
			begin
            //forward
            motor0_ena <= 1'b1;
            motor0_dir <= 1'b1;
            motor1_ena <= 1'b1;
            motor1_dir <= 1'b1;
			end
		STATE_BACKWARD:
			begin
            //backward
            motor0_ena <= 1'b1;
            motor0_dir <= 1'b0;
            motor1_ena <= 1'b1;
            motor1_dir <= 1'b0;
			end
		STATE_LEFT:
			begin
            //left
            motor0_ena <= 1'b1;
            motor0_dir <= 1'b0;
            motor1_ena <= 1'b1;
            motor1_dir <= 1'b1;
			end
		STATE_RIGHT:
			begin
            //right
            motor0_ena <= 1'b1;
            motor0_dir <= 1'b1;
            motor1_ena <= 1'b1;
            motor1_dir <= 1'b0;
			end
		default:
			begin
            //stop
            motor0_ena <= 1'b0;
            motor0_dir <= 1'b0;
            motor1_ena <= 1'b0;
            motor1_dir <= 1'b0;
			end
    endcase

motor motor_inst0(
	.clk(pll_out_clk),
	.enable( motor0_ena | (~KEY0) ),
	.dir( motor0_dir ),
	.cnt8( cnt[19:17] ),
	.f0( IO[ 8] ),
	.f1( IO[10] ),
	.f2( IO[12] ),
	.f3( IO[14] )
);

motor motor_inst1(
	.clk(pll_out_clk),
	.enable( motor1_ena | (~KEY1) ),
	.dir( motor1_dir ),
	.cnt8( cnt[19:17] ),
	.f0( IO[ 9] ),
	.f1( IO[11] ),
	.f2( IO[13] ),
	.f3( IO[15] )
);

//Serial_RX -> Serial_TX
assign FTB1 = FTB0;

//unused IOs to zero
assign IO[ 7: 0] = 0;
assign IO[19:16] = 0;

assign TMDS_CLK_N = 1'b0;
assign TMDS_CLK_P = 1'b0;
assign TMDS_D_N   = 4'd0;
assign TMDS_D_P   = 4'd0;

endmodule
