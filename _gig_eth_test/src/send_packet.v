
module send_packet(
	input  wire clk, 
	input  wire send,padding,
	input  wire [15:0]data,
	output reg tx_en,
	output reg [7:0] tx_data,
	output reg [10:0] byte_count,
	output reg crc_en,
	output reg [31:0] Crc,
	output reg [9:0] ram_adr
);
wire 	 [15:0]  tx_data_length = 1032+padding*256;
wire	 [15:0]  tx_total_length =  tx_data_length+16'd20;

reg tx;
always @(posedge clk) crc_en <= (byte_count==11'h7ff)? 1'b1: (byte_count==(tx_total_length+13)) ? 0 : crc_en ;
always @(posedge clk) tx <= send ? 1'b1: (byte_count==(tx_total_length+17)) ? 0 : tx ;
always @(posedge clk) byte_count <= tx ?  byte_count+1'b1 :11'h7f8;
always @(posedge clk) ram_adr <= byte_count[10:1]-10'h13;
always @(posedge clk) tx_en <= tx;
/////////////////////////////////////////////////////////////////////////////////////////////////////////

wire [7:0] checksum = padding ? 8'h29 : 8'h2a;
reg [7:0] q;
always @(posedge clk)
    case(byte_count[5:0]+6'd10)	
    // Pilot and start_bit (8 bytes)
        6'h00: q <= 8'h55;
        6'h01: q <= 8'h55;	
        6'h02: q <= 8'h55;
        6'h03: q <= 8'h55;
        6'h04: q <= 8'h55;
        6'h05: q <= 8'h55;
        6'h06: q <= 8'h55;
        6'h07: q <= 8'hd5;
    // Ethernet header	
        6'h08: q <= 8'hff;// Ethernet Destination Address (if ff:ff:ff:ff:ff:ff - broadcast)
        6'h09: q <= 8'hff;
        6'h0a: q <= 8'hff;
        6'h0b: q <= 8'hff;
        6'h0c: q <= 8'hff;
        6'h0d: q <= 8'hff;
        6'h0e: q <= 8'h00;// Ethernet Source Address
        6'h0f: q <= 8'h0a;
        6'h10: q <= 8'h35;			
        6'h11: q <= 8'h01;
        6'h12: q <= 8'hfe;	
        6'h13: q <= 8'hc0;
        6'h14: q <= 8'h08;// Type (if 08:00 - IP)
        6'h15: q <= 8'h00;
    // IP header	
        6'h16: q <= 8'h45;
        6'h17: q <= 8'h00;
        6'h18: q <= tx_total_length[15:8];			//8'h04;
        6'h19: q <= tx_total_length[7:0];			//8'h1c;
        6'h1a: q <= 8'h00; 
        6'h1b: q <= 8'h00;	
        6'h1c: q <= 8'h00;
        6'h1d: q <= 8'h00;
        6'h1e: q <= 8'h80;
        6'h1f: q <= 8'h11;	
        6'h20: q <= checksum; 
        6'h21: q <= 8'h9b; 
        6'h22: q <= 8'h0a;	
        6'h23: q <= 8'h08;
        6'h24: q <= 8'h02;
        6'h25: q <= 8'h2F;
        6'h26: q <= 8'hff;
        6'h27: q <= 8'hff;
        6'h28: q <= 8'hff;
        6'h29: q <= 8'hff;
    // UDP header
        6'h2a: q <= 8'h01;
        6'h2b: q <= 8'h03;
        6'h2c: q <= 8'h01;
        6'h2d: q <= 8'h03;
        6'h2e: q <= tx_data_length[15:8];				//8'h04;
        6'h2f: q <= tx_data_length[7:0];				//8'h08;
        6'h30: q <= 8'h00;//Checksum   (if 00:00 not check)
        6'h31: q <= 8'h00;//
    // UDP data	 
        6'h32: q <= 8'h00;	
        6'h33: q <= 8'h00;
        6'h34: q <= 8'h00;
        6'h35: q <= 8'h00;
        6'h36: q <= 8'h00;
        6'h37: q <= 8'h00;
        6'h38: q <= 8'h00;
        6'h39: q <= 8'h00;
        6'h3a: q <= 8'h00;
        6'h3b: q <= 8'h00;
        6'h3c: q <= 8'h00;
        6'h3d: q <= 8'h00;
        6'h3e: q <= 8'h00;
        6'h3f: q <= 8'h00;
	endcase

/////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [7:0] Data_in;
wire [7:0] d = ~byte_count[0]? data[15:8]:data[7:0];
always @(posedge clk) Data_in <= ((byte_count < 11'h29)|(byte_count > (tx_total_length+13)))? q : d;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [31:0] CrcNext;
wire [7:0] Data;
assign Data={Data_in[0],Data_in[1],Data_in[2],Data_in[3],Data_in[4],Data_in[5],Data_in[6],Data_in[7]};

assign CrcNext[0] = Crc[24] ^ Crc[30] ^ Data[0] ^ Data[6];
assign CrcNext[1] = Crc[24] ^ Crc[25] ^ Crc[30] ^ Crc[31] ^ Data[0] ^ Data[1] ^ Data[6] ^ Data[7];
assign CrcNext[2] = Crc[24] ^ Crc[25] ^ Crc[26] ^ Crc[30] ^ Crc[31] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[6] ^ Data[7];
assign CrcNext[3] = Crc[25] ^ Crc[26] ^ Crc[27] ^ Crc[31] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[7];
assign CrcNext[4] = Crc[24] ^ Crc[26] ^ Crc[27] ^ Crc[28] ^ Crc[30] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[4] ^ Data[6];
assign CrcNext[5] = Crc[24] ^ Crc[25] ^ Crc[27] ^ Crc[28] ^ Crc[29] ^ Crc[30] ^ Crc[31] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4] ^ Data[5] ^ Data[6] ^ Data[7];
assign CrcNext[6] = Crc[25] ^ Crc[26] ^ Crc[28] ^ Crc[29] ^ Crc[30] ^ Crc[31] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[6] ^ Data[7];
assign CrcNext[7] = Crc[24] ^ Crc[26] ^ Crc[27] ^ Crc[29] ^ Crc[31] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[7];
assign CrcNext[8] = Crc[0] ^ Crc[24] ^ Crc[25] ^ Crc[27] ^ Crc[28] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4];
assign CrcNext[9] = Crc[1] ^ Crc[25] ^ Crc[26] ^ Crc[28] ^ Crc[29] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5];
assign CrcNext[10] = Crc[2] ^ Crc[24] ^ Crc[26] ^ Crc[27] ^ Crc[29] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[5];
assign CrcNext[11] = Crc[3] ^ Crc[24] ^ Crc[25] ^ Crc[27] ^ Crc[28] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4];
assign CrcNext[12] = Crc[4] ^ Crc[24] ^ Crc[25] ^ Crc[26] ^ Crc[28] ^ Crc[29] ^ Crc[30] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[6];
assign CrcNext[13] = Crc[5] ^ Crc[25] ^ Crc[26] ^ Crc[27] ^ Crc[29] ^ Crc[30] ^ Crc[31] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[6] ^ Data[7];
assign CrcNext[14] = Crc[6] ^ Crc[26] ^ Crc[27] ^ Crc[28] ^ Crc[30] ^ Crc[31] ^ Data[2] ^ Data[3] ^ Data[4] ^ Data[6] ^ Data[7];
assign CrcNext[15] =  Crc[7] ^ Crc[27] ^ Crc[28] ^ Crc[29] ^ Crc[31] ^ Data[3] ^ Data[4] ^ Data[5] ^ Data[7];
assign CrcNext[16] = Crc[8] ^ Crc[24] ^ Crc[28] ^ Crc[29] ^ Data[0] ^ Data[4] ^ Data[5];
assign CrcNext[17] = Crc[9] ^ Crc[25] ^ Crc[29] ^ Crc[30] ^ Data[1] ^ Data[5] ^ Data[6];
assign CrcNext[18] = Crc[10] ^ Crc[26] ^ Crc[30] ^ Crc[31] ^ Data[2] ^ Data[6] ^ Data[7];
assign CrcNext[19] = Crc[11] ^ Crc[27] ^ Crc[31] ^ Data[3] ^ Data[7];
assign CrcNext[20] = Crc[12] ^ Crc[28] ^ Data[4];
assign CrcNext[21] = Crc[13] ^ Crc[29] ^ Data[5];
assign CrcNext[22] = Crc[14] ^ Crc[24] ^ Data[0];
assign CrcNext[23] = Crc[15] ^ Crc[24] ^ Crc[25] ^ Crc[30] ^ Data[0] ^ Data[1] ^ Data[6];
assign CrcNext[24] = Crc[16] ^ Crc[25] ^ Crc[26] ^ Crc[31] ^ Data[1] ^ Data[2] ^ Data[7];
assign CrcNext[25] = Crc[17] ^ Crc[26] ^ Crc[27] ^ Data[2] ^ Data[3];
assign CrcNext[26] = Crc[18] ^ Crc[24] ^ Crc[27] ^ Crc[28] ^ Crc[30] ^ Data[0] ^ Data[3] ^ Data[4] ^ Data[6];
assign CrcNext[27] = Crc[19] ^ Crc[25] ^ Crc[28] ^ Crc[29] ^ Crc[31] ^ Data[1] ^ Data[4] ^ Data[5] ^ Data[7];
assign CrcNext[28] = Crc[20] ^ Crc[26] ^ Crc[29] ^ Crc[30] ^ Data[2] ^ Data[5] ^ Data[6];
assign CrcNext[29] = Crc[21] ^ Crc[27] ^ Crc[30] ^ Crc[31] ^ Data[3] ^ Data[6] ^ Data[7];
assign CrcNext[30] = Crc[22] ^ Crc[28] ^ Crc[31] ^ Data[4] ^ Data[7];
assign CrcNext[31] = Crc[23] ^ Crc[29] ^ Data[5];
always @ (posedge clk) Crc <= crc_en ? CrcNext : {Crc[23:0],8'hFF};

always @(posedge clk) tx_data <= ((byte_count < (tx_total_length+18))&(byte_count > (tx_total_length+13)))?
 {~Crc[24], ~Crc[25], ~Crc[26], ~Crc[27], ~Crc[28], ~Crc[29], ~Crc[30], ~Crc[31]} : Data_in;

endmodule
