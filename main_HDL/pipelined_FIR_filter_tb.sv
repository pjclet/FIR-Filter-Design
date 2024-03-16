// Paul-John Clet
// Advanced VLSI Design Project 1 - FIR Filter Design

`timescale 1ns / 1ps

module testbench();
	`include "parameters.sv"
		
	// define local parameters
	localparam int INP_WIDTH = 16;
	localparam int OUTP_WIDTH = 40;
	localparam int NUM_FREQ_TESTS = 16; // number of tests to perform, each is 1/current test number (e.g. test 2 = 2/16 = 1/8 = 0.125 clock freq)
	localparam int pi = 3.141592654;
	localparam real scale_factor = 1 / real'(2**28); // 2**14
	
	// define local signals
	logic clk;
	logic signed[INP_WIDTH-1:0] x;
	logic signed[OUTP_WIDTH-1:0] y, max_y;
	real current_clock_period;
	real mag_dB, rad, s;
	
	// add the device under test
	fir_filter_design #(INP_WIDTH, OUTP_WIDTH) dut(.clk(clk), .x(x), .y(y));
	
	// main test
	initial begin
		$display("Pipelined FIR Filter Results");
		current_clock_period = 1000; // tried experimenting with modifying the speed
		#1;
		clk = 1'b0; x = 16'b0; rad = 0; s = 0;
		
		// start the frequency tests
		for (int i = 1; i < NUM_FREQ_TESTS; i++) begin
			
			// calculate the test number
			rad = real'((real'(i) * real'(2*pi)) / real'(NUM_FREQ_TESTS));
			s = $sin(rad);
			x = 16'($rtoi(s * real'(2**16)));
			
			// wait for all taps to finish
			repeat (2*N_TAPS) @(posedge clk);
			
			// check the maximum y, which is the magnitude
			max_y = y;
			for (int j = 0; j < 2*current_clock_period; j++) begin
				 @(posedge clk);
				 if (y > max_y) max_y = y;
			end

			// check the magnitude again for negative numbers
			if (max_y <= 0) begin
				mag_dB = 0;
			end else begin
				mag_dB = real'(20) * $log10($itor(max_y) * SCALE_FACTOR);
			end
			
			// display maximum output magnitude in dB for each frequency test
			$display("Clock fraction: %f | Maximum y (dB): %f", real'(real'(i)/ real'(NUM_FREQ_TESTS)), mag_dB);
			#(current_clock_period);
		end
		
		// exit simulation
		$display("[EXIT] Simulation finished.");
		#100; $stop;
	end
	
	always begin
		#(current_clock_period / 2);
		clk = ~clk;
	end

endmodule
