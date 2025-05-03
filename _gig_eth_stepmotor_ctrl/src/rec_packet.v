
module rec_packet(
	input wire clk,
	input wire data_valid,
	input wire [7:0] data,
	output reg my_packet,
    output reg my_data,
	output reg [10:0] byte_count,
	output reg [127:0] rx_data,
    output wire [5:0]err_cnt
);

always @(posedge clk)
    byte_count <= data_valid ?  byte_count+1'b1 : 11'h7f8;

reg [31:0]receiver_reg32;
always @(posedge clk)
    if(data_valid)
        receiver_reg32 <= { data, receiver_reg32[31:8] };

`include "crc32.v"
reg [31:0]crc32_;
wire [7:0]reverse_data; assign reverse_data = { data[0],data[1],data[2],data[3], data[4],data[5],data[6],data[7] };
//skip PRE and SFD 8 bytes
always @(posedge clk)
    crc32_ <= (byte_count>=11'h7f8) ? 32'hFFFFFFFF : nextCRC32_D8( reverse_data, crc32_ );

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

reg crc32_ok = 1'b0;
reg rxdv_ = 1'b0;
reg [5:0]err_cnt_ = 6'd0;
assign err_cnt = err_cnt_;
always @(posedge clk)
begin
    rxdv_ <= data_valid;
    crc32_ok = (&(crc32_3^receiver_reg32)) & rxdv_ & (~data_valid);
    if( rxdv_ & (~data_valid) )
        err_cnt_ <= err_cnt_ + ( (&(crc32_3^receiver_reg32)) ? 0 : 1 );
end

always @(posedge clk)
    rx_data <= my_data ? {data, rx_data[127:8]} : rx_data ;

always @(posedge clk)
    case (byte_count)
    // Broadcast ?
    11'h00: my_packet <= data == 8'hff;
    11'h01: my_packet <= data == 8'hff ? my_packet : 0;
    11'h02: my_packet <= data == 8'hff ? my_packet : 0;
    11'h03: my_packet <= data == 8'hff ? my_packet : 0;
    11'h04: my_packet <= data == 8'hff ? my_packet : 0;
    11'h05: my_packet <= data == 8'hff ? my_packet : 0;
    // Type IP ?
    11'h0c: my_packet <= data == 8'h08 ? my_packet : 0;
    11'h0d: my_packet <= data == 8'h00 ? my_packet : 0;
    // UDP ?
    11'h17: my_packet <= data == 8'h11 ? my_packet : 0;
    // DST IP Broadcast ?
    11'h1e: my_packet <= data == 8'hff ? my_packet : 0;
    11'h1f: my_packet <= data == 8'hff ? my_packet : 0;
    11'h20: my_packet <= data == 8'hff ? my_packet : 0;
    11'h21: my_packet <= data == 8'hff ? my_packet : 0;
    //Socket 6969 ?
    11'h24: my_packet <= data == 8'h69 ? my_packet : 0;
    11'h25: my_packet <= data == 8'h69 ? my_packet : 0;

    // Data begin
    11'h29: my_data <= my_packet ;
    11'h39: {my_packet,my_data} <= 2'b0;  
    endcase

endmodule
