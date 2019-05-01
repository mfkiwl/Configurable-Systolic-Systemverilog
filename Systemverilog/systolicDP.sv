//========================================================================
// Datapath Components for Projectdesign_Systolic_V_datapath
//========================================================================

module systolicDP
#(
	parameter data_size = 8, systolic_size = 2, memory_data_size = 16
)
(
 input wire  clk,reset,
 input wire  [data_size - 1:0] memory_in_a   [0 : systolic_size - 1],
 input wire  [data_size - 1:0] memory_in_b   [0 : systolic_size - 1],
 output wire [data_size - 1:0] memory_out    [0 : systolic_size - 1],
 input wire  cal_ele_cho_array [0 : systolic_size - 1],
 input wire  mem_ele_cho,
 input wire  mem_change
);

 wire[data_size - 1:0] in_a     [0 : systolic_size][0 : systolic_size - 1];
 wire[data_size - 1:0] result   [0 : systolic_size][0 : systolic_size - 1];
 wire					 cal_ele_cho_array_block [0 : systolic_size][0 : systolic_size - 1];
 assign 			    in_a [0] = memory_in_a;
 assign  			 cal_ele_cho_array_block [0] = cal_ele_cho_array;
 assign				 memory_out = result[0];
 
genvar i;
generate
for(i = 0; i < systolic_size; i = i + 1) begin: generate_DP_col
	systolicDPcol #(
		.data_size(data_size), .systolic_size(systolic_size), .memory_data_size(memory_data_size)
	)col(
		.clk(clk),
		.reset(reset),
		.in_a( in_a [i][0 : systolic_size - 1]),
		.out_a( in_a [i + 1][0 : systolic_size - 1]),
		.memory_in_b(memory_in_b [i]),
		.result_out(result[i][0 : systolic_size - 1]),
		.result_in(result[i + 1][0 : systolic_size - 1]),
		.mem_ele_cho(mem_ele_cho),
		.mem_change(mem_change),
		.cal_ele_cho_array_in(cal_ele_cho_array_block[i]),
		.cal_ele_cho_array_out(cal_ele_cho_array_block[i+1])
	);
end
endgenerate

endmodule

