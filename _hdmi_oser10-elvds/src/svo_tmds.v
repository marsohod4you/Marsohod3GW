/*
 *  SVO - Simple Video Out FPGA Core
 *
 *  Copyright (C) 2014  Clifford Wolf <clifford@clifford.at>
 *  
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1ns / 1ps
//`include "svo_defines.vh"

module svo_tmds(
	input clk, resetn, de,
	input [7:0] din,	// video data (red, green or blue)
	input [1:0] ctrl,	// control data
	output reg [9:0] dout = 0
);

wire [7:0]VD; assign VD = din;
wire [1:0]CD; assign CD = ctrl;
wire VDE; assign VDE = de;

wire [3:0] Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
wire XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && VD[0]==1'b0);
wire [8:0] q_m = {~XNOR, q_m[6:0] ^ VD[7:1] ^ {7{XNOR}}, VD[0]};

reg [3:0] balance_acc = 0;
wire [3:0] balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
wire balance_sign_eq = (balance[3] == balance_acc[3]);
wire invert_q_m = (balance==0 || balance_acc==0) ? ~q_m[8] : balance_sign_eq;
wire [3:0] balance_acc_inc = balance - ({q_m[8] ^ ~balance_sign_eq} & ~(balance==0 || balance_acc==0));
wire [3:0] balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc+balance_acc_inc;
wire [9:0] TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};
wire [9:0] TMDS_code = CD[1] ? (CD[0] ? 10'b1010101011 : 10'b0101010100) : (CD[0] ? 10'b0010101011 : 10'b1101010100);

always @(posedge clk) dout <= VDE ? TMDS_data : TMDS_code;
always @(posedge clk) balance_acc <= VDE ? balance_acc_new : 4'h0;

endmodule

module svo_tmds_org (
	input clk, resetn, de,
	input [1:0] ctrl,
	input [7:0] din,
	output reg [9:0] dout
);
	// Variable and function names below match the spec names for
	// better readability when comparing to spec encoder flow diagram.
	wire [7:0] D = din;

	function [3:0] N1;
		// Count the number of '1' bits.
		input [7:0] bits;
		integer i;
		begin
			N1 = 0;
			for (i = 0; i < 8; i = i+1)
				N1 = N1 + bits[i];
		end
	endfunction

	function [3:0] N0;
		// Count the number of '0' bits.
		input [7:0] bits;
		integer i;
		begin
			N0 = 0;
			for (i = 0; i < 8; i = i+1)
				N0 = N0 + !bits[i];
		end
	endfunction

	reg [9:0] dout_buf2, q_out, q_out_next;
	reg [3:0] N0_q_m, N1_q_m;
	reg signed [7:0] cnt, cnt_next, cnt_tmp;
	reg [8:0] q_m;

	always @(posedge clk) begin
		if (!resetn) begin
			cnt   <= 0; // Data stream disparity count used for DC balance
			q_out <= 0;
		end else if (!de) begin
			cnt   <= 0; // Reset disaprity when not actively displaying
			case (ctrl) // See spec section "Control Period Coding"
				2'b00: q_out <= 10'b1101010100;
				2'b01: q_out <= 10'b0010101011;
				2'b10: q_out <= 10'b0101010100;
				2'b11: q_out <= 10'b1010101011;
			endcase
		end else begin
			// See spec flow diagram in section "Video Data Coding"
			if ((N1(D) > 4) | ((N1(D) == 4) & (D[0] == 0))) begin
				q_m[0] =           D[0];
				q_m[1] = q_m[0] ^~ D[1];
				q_m[2] = q_m[1] ^~ D[2];
				q_m[3] = q_m[2] ^~ D[3];
				q_m[4] = q_m[3] ^~ D[4];
				q_m[5] = q_m[4] ^~ D[5];
				q_m[6] = q_m[5] ^~ D[6];
				q_m[7] = q_m[6] ^~ D[7];
				q_m[8] = 1'b0;
			end
			else begin
				q_m[0] =          D[0];
				q_m[1] = q_m[0] ^ D[1];
				q_m[2] = q_m[1] ^ D[2];
				q_m[3] = q_m[2] ^ D[3];
				q_m[4] = q_m[3] ^ D[4];
				q_m[5] = q_m[4] ^ D[5];
				q_m[6] = q_m[5] ^ D[6];
				q_m[7] = q_m[6] ^ D[7];
				q_m[8] = 1'b1;
			end

			N0_q_m = N0(q_m[7:0]);
			N1_q_m = N1(q_m[7:0]);

			if ((cnt == 0) | (N1_q_m == N0_q_m)) begin
				q_out_next[9]    = ~q_m[8];
				q_out_next[8]    =  q_m[8];
				q_out_next[7:0]  = (q_m[8] ? q_m[7:0] : ~q_m[7:0]);
				if (q_m[8] == 0) begin
					cnt_next = cnt + (N0_q_m - N1_q_m);
				end else begin
					cnt_next = cnt + (N1_q_m - N0_q_m);
				end
			end else if (((cnt > 0) & (N1_q_m > N0_q_m)) | (((cnt < 0) & (N0_q_m > N1_q_m)))) begin
				q_out_next[9]    =  1'b1;
				q_out_next[8]    =  q_m[8];
				q_out_next[7:0]  = ~q_m[7:0];
				cnt_tmp          = cnt + (N0_q_m - N1_q_m);
				if (q_m[8]) begin
					cnt_next = cnt_tmp + 2'h2;
				end else begin
					cnt_next = cnt_tmp;
				end
			end else begin
				q_out_next[9]    =  1'b0;
				q_out_next[8]    =  q_m[8];
				q_out_next[7:0]  =  q_m[7:0];
				cnt_tmp          = cnt + (N1_q_m - N0_q_m);
				if (q_m[8]) begin
					cnt_next = cnt_tmp;
				end else begin
					cnt_next = cnt_tmp - 2'h2;
				end
			end
			cnt   <= cnt_next;
			q_out <= q_out_next;
		end

		// add two additional ff stages, give synthesis retime some slack to work with
		dout_buf2 <= q_out;
		dout <= dout_buf2;
	end
endmodule
