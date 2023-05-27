`include "resolution.v"

///////////////////////////////////////////////////////////////
//module which generates video sync impulses
///////////////////////////////////////////////////////////////

module hvsync (
	input wire reset,
	input wire pixel_clock,

	output reg hsync,
	output reg vsync,
	output reg active,

	output reg [11:0]pixel_count,
	output reg [11:0]line_count,
	output reg dbg
	);

`ifdef Res640x480
// video signal parameters 640 x 480 at 60 Hz (non-interlaced) 
//Pixel Clock 25,175Mhz
parameter horz_front_porch = 16;
parameter horz_sync = 96;
parameter horz_back_porch = 48;
parameter horz_addr_time = 640;

parameter vert_front_porch = 10;
parameter vert_sync = 2;
parameter vert_back_porch = 33;
parameter vert_addr_time = 480;
`endif

`ifdef Res800x600
// video signal parameters 800 x 600 at 60 Hz (non-interlaced) 
//Pixel Clock 40,0Mhz
parameter horz_front_porch = 40;
parameter horz_sync = 128;
parameter horz_back_porch = 88;
parameter horz_addr_time = 800;

parameter vert_front_porch = 1;
parameter vert_sync = 4;
parameter vert_back_porch = 23;
parameter vert_addr_time = 600;
`endif

reg hsync_imp = 1'b0;
always @(posedge pixel_clock or posedge reset)
	if(reset)
	begin
		hsync <= 1'b0;
		hsync_imp <= 1'b0;
		pixel_count <= 0;
	end
	else
	begin
		hsync <= (pixel_count >= (horz_addr_time+horz_front_porch-1)) && (pixel_count < (horz_addr_time+horz_front_porch+horz_sync-1));
		hsync_imp <= (pixel_count == (horz_addr_time+horz_front_porch-1));
		if(pixel_count < (horz_addr_time+horz_front_porch+horz_sync+horz_back_porch-1) )
			pixel_count <= pixel_count + 1'b1;
		else
			pixel_count <= 0;
	end

always @(posedge pixel_clock or posedge reset)
	if(reset)
	begin
		vsync <= 1'b0;
		line_count <= vert_addr_time; //0;
	end
	else
	if(hsync_imp)
	begin
		vsync <= (line_count >= (vert_addr_time+vert_front_porch-1)) &&  (line_count < (vert_addr_time+vert_front_porch+vert_sync-1) );
		
		if(line_count < (vert_addr_time+vert_front_porch+vert_sync+vert_back_porch -1) )
			line_count <= line_count + 1'b1;
		else
			line_count <= 0;
	end

always @*
	active = (pixel_count<horz_addr_time) && (line_count<vert_addr_time);

always @(posedge hsync)
	dbg <= (line_count>500);
	
endmodule

