// Paul-John Clet
// Advanced VLSI Design Project 1 - FIR Filter Design

`timescale 1ns / 1ps

module rc_2_parallel_FIR_filter #(parameter int INP_WIDTH = 16, parameter int OUTP_WIDTH = 16) (
				input clk,
				input  signed[INP_WIDTH-1:0] x [1:0],
				output signed[OUTP_WIDTH-1:0] y[1:0]); 
				
	`include "parameters.sv"
	`include "filter_coefficients.sv"
	
	// define all signals needed
	logic signed [OUTP_WIDTH-1:0] H0_out, H0_H1_out, H1_out, H1_out_D;
	logic [INP_WIDTH-1:0] H0_H1_sum;
	
	// sum while checking making sure there is no overflow
	assign H0_H1_sum = {x[0][INP_WIDTH-1],x[0]}+{x[0][INP_WIDTH-1],x[1]}; 
	
	// create all the sub filters that will process each input and sum
	non_pipelined_FIR_filter #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(2)) H0_FIR (.clk(clk), .x(x[0]), .y(H0_out));
	
	non_pipelined_FIR_filter #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(2)) H1_FIR (.clk(clk), .x(x[1]), .y(H1_out));
	
	non_pipelined_FIR_filter #(.INP_WIDTH(INP_WIDTH), .OUTP_WIDTH(OUTP_WIDTH), .L(2)) H0_H1_FIR (.clk(clk), .x(H0_H1_sum), .y(H0_H1_out));
	
	// delayed signals
	always_ff @(posedge clk) begin // delay 1 clock cycle
		H1_out_D <= H1_out;
	end
	
	// output
	assign y[0] = H1_out_D + H0_out;
	assign y[1] = H0_H1_out - H1_out - H0_out;	
	
endmodule
