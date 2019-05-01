//========================================================================
// Datapath Components for Projectdesign_Systolic_V_datapath
//========================================================================
module systolicDPcol
#(
	parameter data_size = 8, systolic_size = 2, memory_data_size = 16
)
(
 input wire  clk,reset,
 input wire  [data_size - 1:0] in_a   		[0 : systolic_size - 1],
 output wire [data_size - 1:0] out_a  		[0 : systolic_size - 1],
 input wire  [data_size - 1:0] memory_in_b,
 output wire [data_size - 1:0] result_out  [0 : systolic_size - 1],
 input wire  [data_size - 1:0] result_in   [0 : systolic_size - 1],
 input wire  					mem_ele_cho,
 input wire  					mem_change,
 input wire 					cal_ele_cho_array_in [0 : systolic_size - 1],
 output wire 					cal_ele_cho_array_out [0 : systolic_size - 1]
);
wire	 [data_size - 1:0] in_b        [0 : systolic_size];
assign in_b[0] = memory_in_b;
	genvar i;
	generate
	for(i = 0; i < systolic_size; i = i + 1) begin: generate_pe
		processelement #(
			.data_size(data_size)
		)pe(
			.clk(clk), 
			.reset(reset), 
			.cal_ele_cho_in(cal_ele_cho_array_in[i]), 
			.cal_ele_cho_out(cal_ele_cho_array_out[i]), 
			.mem_ele_cho(mem_ele_cho), 
			.mem_change(mem_change),
			.MEM_in(result_in[i]), 
			.MEM_out(result_out[i]), 
			.MUL_A_in(in_a[i]),  
			.MUL_B_in(in_b[i]),  
			.MUL_A_out(out_a[i]), 
			.MUL_B_out(in_b[i + 1]), 
			.MUL_C_out()
		);
	end
	endgenerate
	
endmodule

