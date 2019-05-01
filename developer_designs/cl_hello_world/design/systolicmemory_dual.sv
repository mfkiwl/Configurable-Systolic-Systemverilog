
// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module systolicmemory_dual
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6 , parameter DEPTH = 256)
(
	input [(DATA_WIDTH-1):0] da, db,
	input [(ADDR_WIDTH-1):0] addra, addrb,
	input wea, web, clk,
	input ena, enb,
	output reg [(DATA_WIDTH-1):0] qa, qb
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram [DEPTH - 1:0];

	// Port A 
	always @ (posedge clk)
	begin
		if (ena) begin
			if (wea) 
			begin
				ram[addra] <= da;
				qa <= da;
			end
			else 
			begin
				qa <= ram[addra];
			end 
		end
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (enb) begin
			if (web) 
			begin
				ram[addrb] <= db;
				qb <= db;
			end
			else 
			begin
				qb <= ram[addrb];
			end 
		end
	end

endmodule

