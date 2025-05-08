
module pkt_reader(
	input wire clk,
	input wire [255:0]data,
	input wire [2:0]head,
	input wire [11:0]rom_byte,
	output wire [8:0]raddr,
	output reg broadcast,
	output wire [3:0]led,
	output wire [7:0]send_byte,
	output wire send,
	output reg [6:0]rom_addr,
	output reg [31:0]crc32,
    output reg [63:0]udp_payload
);

`include "crc32.v"

localparam MY_MAC = 48'hA6A5A4A3A1A0;
localparam MY_IP  = 32'h0900080A; // my fixed IP is 10.8.0.9

localparam ETH_TYPE_ARP  = 16'h0608;
localparam ETH_TYPE_IP   = 16'h0008;
localparam IP_PROTO_TCP  = 8'h06;
localparam IP_PROTO_UDP  = 8'd17;
localparam TCP_SRV_PORT  = 16'h5000; //http = 80
localparam UDP_SRV_PORT  = 16'h6969;

localparam STATE_WAIT_PKT = 0;
localparam STATE_CHK_MAC  = 1;
localparam STATE_CHK_UDP0 = 2;
localparam STATE_CHK_UDP  = 3;
localparam STATE_CHK_ARP0 = 4;
localparam STATE_CHK_ARP  = 5;
localparam STATE_CHK_ARP_IP0 = 6;
localparam STATE_CHK_ARP_IP  = 7;
localparam STATE_ARP_REPLY = 8;
localparam STATE_END_PKT_PROC = 9;
localparam STATE_END_PKT_PROC1 = 10;

//decode packet data bus lines
wire [47:0]L0_dst_mac_addr;  assign L0_dst_mac_addr = data[111:64];
wire [47:0]L0_src_mac_addr;  assign L0_src_mac_addr = data[159:112];
wire [15:0]L0_eth_type; 	 assign L0_eth_type     = data[175:160];
wire [ 7:0]L0_arp_opcode; 	 assign L0_arp_opcode   = data[239:232];
wire [ 7:0]L0_ip_proto; 	 assign L0_ip_proto     = data[255:248];
wire [31:0]L1_arp_req_ip; 	 assign L1_arp_req_ip   = data[143:112];
wire [31:0]L1_arp_rem_ip; 	 assign L1_arp_rem_ip   = data[63:32];

wire [31:0]L1_udp_src_ip; 	 assign L1_udp_src_ip   = data[47:16];
wire [31:0]L1_udp_dst_ip; 	 assign L1_udp_dst_ip   = data[79:48];
wire [15:0]L1_udp_src_port;  assign L1_udp_src_port = data[95:80];
wire [15:0]L1_udp_dst_port;  assign L1_udp_dst_port = data[111:96];
wire [15:0]L1_udp_data_len;  assign L1_udp_data_len = data[127:112];
wire [15:0]L1_udp_ch_sum;    assign L1_udp_ch_sum   = data[143:128];
wire [31:0]L1_udp_payload0;  assign L1_udp_payload0 = data[175:144];
wire [31:0]L1_udp_payload1;  assign L1_udp_payload1 = data[207:176];

reg [2:0]tail = 0;

reg [3:0]state = STATE_WAIT_PKT;
always @(posedge clk)
begin
	case(state)
	STATE_WAIT_PKT: begin
		if( tail != head )	//just wait receiver head goes forward
			state <= STATE_CHK_MAC;
		end
	STATE_CHK_MAC:  begin
		if( L0_dst_mac_addr==48'hFFFFFFFFFFFF && L0_eth_type==ETH_TYPE_ARP && L0_arp_opcode==8'h01 ) //accept broadcast only for ARP req
			state <= STATE_CHK_ARP0;
		else
		if( L0_dst_mac_addr==MY_MAC && L0_eth_type==ETH_TYPE_IP && L0_ip_proto==IP_PROTO_UDP) //accept my MAC for TCP/IP
			state <= STATE_CHK_UDP0;
		else
			state <= STATE_END_PKT_PROC; //ignore packet because of wrong MAC
		end
	STATE_CHK_UDP0: begin
		state <= STATE_CHK_UDP;
		end
	STATE_CHK_UDP:  begin 
		//if( L1_udp_dst_ip==MY_IP && L1_udp_dst_port==UDP_SRV_PORT ) //accept UDP packet if true
		//begin
        //end
		state <= STATE_END_PKT_PROC;
        end
	STATE_CHK_ARP0:  begin
			state <= STATE_CHK_ARP_IP;
		end
	STATE_CHK_ARP_IP: begin
		if( L1_arp_req_ip==MY_IP ) //accept ARP request for me only
			state <= STATE_ARP_REPLY;
		else
			state <= STATE_END_PKT_PROC;
		end
	STATE_ARP_REPLY: begin
		if( rom_byte_==12'hF02 )
			state <= STATE_END_PKT_PROC;
		end
	STATE_END_PKT_PROC1: begin
		state <= STATE_END_PKT_PROC;
		end
	STATE_END_PKT_PROC: begin
		state <= STATE_WAIT_PKT;
		end
	endcase;
end

always @(posedge clk)
	if( state==STATE_CHK_UDP && L1_udp_dst_ip==MY_IP && L1_udp_dst_port==UDP_SRV_PORT )
    begin
        udp_payload <= { L1_udp_payload1, L1_udp_payload0 };
    end

always @(posedge clk)
	if( state==STATE_END_PKT_PROC ) //assume packet processed and need to go forward
	begin
		tail <= tail+1;
	end

wire [1:0]pkt_line; 
assign pkt_line = 
	(state==STATE_WAIT_PKT)	? 0 :
	(state==STATE_CHK_MAC)	? 1 : 2;
	
assign raddr = { tail, 4'h0, pkt_line };
assign led = { broadcast, head };

always @*
	broadcast = (data[112:64]==48'hFFFFFFFFFFFF);

reg [47:0]remote_mac;
reg [31:0]remote_ip;
always @(posedge clk)
begin
	if(state==STATE_CHK_MAC)
		remote_mac <= L0_src_mac_addr;
	if(state==STATE_CHK_ARP_IP)
		remote_ip <= L1_arp_rem_ip;
end

wire sending; assign sending = state==STATE_ARP_REPLY;
always @(posedge clk)
	if(state==STATE_CHK_ARP_IP)
		rom_addr <= 0;			//addr of ARP reply packet in rom
	else
	if( sending )
		rom_addr <= rom_addr + 1;

reg [7:0]sbyte0;
reg [7:0]sbyte1;
reg [7:0]sbyte2;
reg [7:0]sbyte3;
reg [7:0]sbyte4;
reg [7:0]sbyteF;
reg [7:0]sbyte_;
reg [11:0]rom_byte_;
reg [11:0]rom_byte__;
wire [3:0]field_sel; assign field_sel = rom_byte_[11:8];
always @(posedge clk)
begin
    if(state==STATE_WAIT_PKT)
    begin
        rom_byte__ <= 12'h000;
        rom_byte_  <= 12'h000;
    end
    else
    begin
        rom_byte__ <= rom_byte_;
        rom_byte_  <= rom_byte;
    end
    sbyte0 <= rom_byte[7:0];
    sbyte1 <= remote_mac>>(rom_byte[2:0]*8);
    sbyte2 <= remote_ip >>(rom_byte[1:0]*8);
    sbyte3 <= MY_MAC>>(rom_byte[2:0]*8);
    sbyte4 <= MY_IP >>(rom_byte[1:0]*8);
    sbyteF <= crc32>>(rom_byte[1:0]*8);
    sbyte_ <=
        (field_sel==4'h0) ? sbyte0 :
        (field_sel==4'h1) ? sbyte1 :
        (field_sel==4'h2) ? sbyte2 :
        (field_sel==4'h3) ? sbyte3 :
        (field_sel==4'h4) ? sbyte4 :
        (field_sel==4'hF) ? sbyteF : 8'h00;
end

assign send_byte[7:0] = sbyte_;

reg [2:0]send_delay;
reg send0 = 1'b0;
reg send1 = 1'b0;
always @(posedge clk)
begin
	send_delay <= { send_delay[1:0], sending };
    send0 <= send_delay[2] & (rom_byte_[11:8]!=4'hE);
    send1 <= send_delay[2] & send_delay[0] & (rom_byte_[11:7]!=5'h1F) & (rom_byte_[11:8]!=4'hE);
end

assign send = send1;

//count number of bytes sent (to skip crc calc for preamble)
reg [3:0]sbyte_cnt;
always @(posedge clk)
	if(state==STATE_WAIT_PKT)
		sbyte_cnt <= 0;
	else
	if(send0 && sbyte_cnt<8)
		sbyte_cnt <= sbyte_cnt + 1;
	
reg [31:0]crc32_;
always @(posedge clk)
	if(send0 && sbyte_cnt==8 )
	begin
        if( rom_byte__[11:8]!=4'hF )
			crc32_ <= nextCRC32_D8( 
				{
				send_byte[0], send_byte[1], send_byte[2], send_byte[3], 
				send_byte[4], send_byte[5], send_byte[6], send_byte[7] }
				, crc32_ );
	end
	else
		crc32_ <= 32'hFFFFFFFF;

//reverse bits and inverse of CRC32
integer i;
always @*
begin
	for ( i=0; i < 32; i=i+1 )
		crc32[i] = crc32_[31-i]^1'b1;
end

endmodule

