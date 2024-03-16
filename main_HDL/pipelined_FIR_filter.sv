// Paul-John Clet
// Advanced VLSI Design Project 1 - FIR Filter Design

`timescale 1ns / 1ps

module fir_filter_design #(parameter int INP_WIDTH = 16, parameter int OUTP_WIDTH = 32, parameter int L = 3) (
				input clk,
				input  [INP_WIDTH-1:0] x,
				output [OUTP_WIDTH-1:0] y); 
	
				
	`include "parameters.sv"
	`include "filter_coefficients.sv"
	
	// create pipeline registers (use shift register)
	logic signed[OUTP_WIDTH-1:0] p_registers[0:N_TAPS-1];
	logic signed[OUTP_WIDTH-1:0] accumulator; 

	initial begin
		// initialize registers
		for (int i = 1; i < N_TAPS; i++) begin
			p_registers[i] = 16'b0;
		end
	end

	always @(posedge clk) begin
		p_registers[N_TAPS - 1] <= x * filter_coeffs[N_TAPS - 1];
		// shift every value one spot the the right then calculate the new product and sum
		for (int i = N_TAPS - 1; i > 0; i--) begin
			p_registers[i] <= p_registers[i+1] + $rtoi($itor(filter_coeffs[i]) * $itor(x)); 
		end
		accumulator <= p_registers[1] + $rtoi($itor(filter_coeffs[0])*$itor(x));
	end
	
endmodule


