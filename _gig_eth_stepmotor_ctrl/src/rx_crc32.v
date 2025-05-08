
module rx_crc32(
	input wire clk,
	input wire data_valid,
	input wire [7:0] data,
    output reg [10:0]byte_count,
    output wire [12:0]memwr_addr,
    output wire [15:0]memwr_data,
    output wire memwr,
    output reg [2:0]pkt_head,
	output reg crc32_ok,
    output wire [7:0]err_cnt
);

`include "crc32.v"

//remember least 4 bytes received
reg [31:0]rx_data32;
always @(posedge clk)
    if(data_valid)
        rx_data32 <= { data, rx_data32[31:8] };

//count received bytes when packet goes
always @(posedge clk)
    if(data_valid && byte_count<11'h7fe)
        byte_count <= byte_count+1'b1;
    else
        byte_count <= 11'h0;

//write by 16bit words
assign memwr = data_valid & byte_count[0];
assign memwr_addr = { pkt_head,byte_count[10:1] };
assign memwr_data = { data, rx_data32[31:24] };

reg [31:0]crc32_;
wire [7:0]reverse_data; assign reverse_data = { data[0],data[1],data[2],data[3], data[4],data[5],data[6],data[7] };

//skip PRE and SFD 8 bytes, then calculate CRC32
always @(posedge clk)
    crc32_ <= (byte_count<8) ? 32'hFFFFFFFF : nextCRC32_D8( reverse_data, crc32_ );

//reverse bits of CRC32
integer i;
reg [31:0]crc32;
always @*
begin
    for ( i=0; i < 32; i=i+1 )
        crc32[i] = crc32_[31-i];
end

//store least 4 crc32 summs
reg [31:0]crc32_0;
reg [31:0]crc32_1;
reg [31:0]crc32_2;
reg [31:0]crc32_3;
always @(posedge clk)
    if(data_valid)
    begin
        crc32_3 <= crc32_2;
        crc32_2 <= crc32_1;
        crc32_1 <= crc32_0;
        crc32_0 <= crc32;
    end

reg rxdv_ = 1'b0;
reg [7:0]err_cnt_ = 8'd0;
assign err_cnt = err_cnt_;
always @(posedge clk)
begin
    rxdv_ <= data_valid;
    //make CRC32 signal
    crc32_ok <= (&(crc32_3^rx_data32)) & rxdv_ & (~data_valid);
    //count number of CRC32 errors
    if( rxdv_ & (~data_valid) )
        err_cnt_ <= err_cnt_ + ( (&(crc32_3^rx_data32)) ? 0 : 1 );
    //increase packet memory pointer if received packet proved is correct by CRC32
    if(crc32_ok)
        pkt_head <= pkt_head+1'b1;
end

endmodule
