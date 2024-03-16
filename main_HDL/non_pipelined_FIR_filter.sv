// Paul-John Clet
// Advanced VLSI Design Project 1 - FIR Filter Design

module non_pipelined_FIR_filter#(parameter int INP_WIDTH = 16, parameter int OUTP_WIDTH = 16, parameter int L = 2) (
				input clk,
				input  [INP_WIDTH-1:0] x,
				output [OUTP_WIDTH-1:0] y); 
				
	`include "parameters.sv"
	`include "filter_coefficients.sv"
	
	logic signed[OUTP_WIDTH-1:0] registers[N_TAPS-2:0];
	logic signed[OUTP_WIDTH-1:0] y_temp, y_out;
	
	assign y = y_out;

	// shift the registers every clock cycle
	always @(posedge clk) begin
		delayed_input[0] <= x;
		for (int i=1; i < N_TAPS-1; i++) begin
			 registers[i] <= registers[i-1];
		end
		// won't compile unless y_out is used
		y_out <= y_temp;
	end

	// calculate the sum for the output
	always begin
		for (int i = 1; i < N_TAPS; i++) begin
			 y_temp = y_temp + filter_coeffs[i-1] * registers[i-1];
		end
	end
	
	
	
endmodule
