// Paul-John Clet
// Advanced VLSI Design Project 1 - FIR Filter Design

`timescale 1ns / 1ps

module rc_3_parallel_pipelined_FIR_filter #(parameter int INP_WIDTH = 16, parameter int OUTP_WIDTH = 16, parameter int L = 3) (
				input clk,
				input  signed[INP_WIDTH-1:0] x [2:0],
				output signed[OUTP_WIDTH-1:0] y[2:0]); 
				
	`include "parameters.sv"
	`include "filter_coefficients.sv"
	
	// define all signals used
	logic signed [OUTP_WIDTH-1:0] H0_out, H0_H1_out, H1_out, H2_out, H2_out_D, H1_H2_out, H0_H1_H2_out, H1_H2_minus_H1_out, H1_H2_minus_H1_out_D, H0_minus_H2_out_D;
	logic [INP_WIDTH-1:0] H0_H1_sum, H1_H2_sum, H0_H1_H2_sum;
	
	// calculate sums, checking for overflow
	assign H0_H1_sum = {x[0][INP_WIDTH-1],x[0]}+{x[1][INP_WIDTH-1],x[1]}; 
	assign H1_H2_sum = {x[1][INP_WIDTH-1],x[1]}+{x[2][INP_WIDTH-1],x[2]}; 
	assign H0_H1_H2_sum = {H0_H1_sum[INP_WIDTH-1],H0_H1_sum}+{x[2][INP_WIDTH-1],x[2]};  
	
	// create all the sub filters that will process each input and sum
	fir_filter_design #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(L)) H0_FIR (.clk(clk), .x(x[0]), .y(H0_out));
	
	fir_filter_design #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(L)) H1_FIR (.clk(clk), .x(x[1]), .y(H1_out));
	
	fir_filter_design #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(L)) H2_FIR (.clk(clk), .x(x[2]), .y(H2_out));
	
	fir_filter_design #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(L)) H0_H1_FIR (.clk(clk), .x(H0_H1_sum), .y(H0_H1_out));
	
	fir_filter_design #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(L)) H1_H2_FIR (.clk(clk), .x(H1_H2_sum), .y(H1_H2_out));
	
	fir_filter_design #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(L)) H0_H1_H2_FIR (.clk(clk), .x(H0_H1_H2_sum), .y(H0_H1_H2_out));
	
	// delayed signals
	always_ff @(posedge clk) begin 
		H2_out_D <= H2_out;
		H1_H2_minus_H1_out_D <= H1_H2_minus_H1_out;
	end
	
	// intermediate signals
	assign H1_H2_minus_H1_out = H0_H1_H2_out - H1_out;
	assign H0_minus_H2_out_D = H0_out - H2_out_D;
	
	// assign outputs
	assign y[0] = H0_minus_H2_out_D + H1_H2_minus_H1_out_D;
	assign y[1] = H0_H1_out - H1_out - H0_minus_H2_out_D;	
	assign y[2] = H0_H1_H2_sum - (H0_H1_out - H1_out) - (H1_H2_minus_H1_out);
	
endmodule
