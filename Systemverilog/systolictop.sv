//========================================================================
// Top Components for Projectdesign_Systolic_V_datapath
//========================================================================
//`define data_size 8
//`define systloic_size 2
//`define memory_data_size 16
//`define baseaddr_A 0x00000000
//`define baseaddr_B 0x05000000
//`define baseaddr_C 0x10000000

module systolictop
#(
	parameter data_size = 8, systolic_size = 8, memory_data_size = 64, ADDR_W = 3, 
	baseaddr_A = 32'h00000000, baseaddr_B = 32'h40000000, baseaddr_C = 32'h80000000
)
(
 input  wire  clk,reset,
 input  wire  [memory_data_size - 1:0] memory_in_a,
 input  wire  [memory_data_size - 1:0] memory_in_b,
 output wire  [memory_data_size - 1:0] memory_out,
 output wire  [31:0] memory_address_A,
 output wire  [31:0] memory_address_B,
 output wire  in_out,
 output wire  [31:0] memory_address_OUT,
 output wire  out_in,
 input  wire  [31:0] matrix_size,
 input  wire  go,
 output wire  done 
);

 wire					    			mem_ele_cho;
 wire					    			mem_change;
 wire [ data_size - 1:0 ] 		memory_input_a [0 : systolic_size - 1];
 wire [ data_size - 1:0 ] 		memory_input_b [0 : systolic_size - 1];
 reg [ data_size - 1:0 ]		FIFO_input_a   [0 : systolic_size - 1];
 reg [ data_size - 1:0 ] 		FIFO_input_b   [0 : systolic_size - 1];
 reg [ data_size - 1:0 ]		memory_output  [0 : systolic_size - 1];
 wire [ systolic_size - 1:0] 	FIFO_rd;
 wire [ systolic_size - 1:0] 	FIFO_wr;
 reg [ data_size - 1:0]    	clear_cal_ele_cho;
 wire 								cal_ele_cho_array [0 : systolic_size - 1];
 genvar i;
 generate
 for(i = 0; i < systolic_size; i = i + 1) begin: generate_seperate_wire
	assign memory_input_a[i] = memory_in_a[ data_size * i + data_size - 1: data_size * i ];
	assign memory_input_b[i] = memory_in_b[ data_size * i + data_size - 1: data_size * i ];
	assign memory_out[ data_size * i + data_size - 1 : data_size * i ] = memory_output [i];
	assign cal_ele_cho_array[i] = clear_cal_ele_cho[i];
 end
 endgenerate

 systolicDP #(
		.data_size(data_size),
		.systolic_size(systolic_size),
		.memory_data_size(memory_data_size)
	)DP(
		.clk(clk),
		.reset(reset),
		.memory_in_a(FIFO_input_a),
		.memory_in_b(FIFO_input_b),
		.memory_out(memory_output),
		.mem_ele_cho(mem_ele_cho),
		.mem_change(mem_change),
		.cal_ele_cho_array(cal_ele_cho_array)
	);
	
 genvar j;
 generate
 for(j = 0; j < systolic_size; j = j + 1) begin: generate_FIFO_a
 systolicFIFO #(
 		.data_size(data_size),
		.systolic_size(systolic_size),
		.memory_data_size(memory_data_size),
		.ADDR_W(ADDR_W)
	) FIFO_a(
		.data_out(FIFO_input_a[j]),
		.data_in (memory_input_a[j]),
		.RD_EN	(FIFO_rd[j]),
		.WR_EN	(FIFO_wr[j]),
		.clk(clk),
		.reset(reset)
	);
 end
endgenerate

 genvar k;
 generate
 for(k = 0; k < systolic_size; k = k + 1) begin: generate_FIFO_b
 systolicFIFO #(
 		.data_size(data_size),
		.systolic_size(systolic_size),
		.memory_data_size(memory_data_size),
		.ADDR_W(ADDR_W)
	) FIFO_b(
		.data_out(FIFO_input_b[k]),
		.data_in (memory_input_b[k]),
		.RD_EN	(FIFO_rd[k]),
		.WR_EN	(FIFO_wr[k]),
		.clk(clk),
		.reset(reset)
	);
 end
endgenerate

 systolicCU #(
		.data_size(data_size),
		.systolic_size(systolic_size),
		.memory_data_size(memory_data_size),
		.ADDR_W(ADDR_W),
		.baseaddr_A(baseaddr_A), 
		.baseaddr_B(baseaddr_B),  
		.baseaddr_C(baseaddr_C)
	) CTRL(
		.clk(clk), 
		.reset(reset),
		.go(go),
		.done(done),
		.mem_ele_cho(mem_ele_cho),
		.mem_change(mem_change),
		.memory_address_A(memory_address_A),
		.memory_address_B(memory_address_B),
		.memory_address_OUT(memory_address_OUT),
		.matrix_size(matrix_size),
		.in_out(in_out),
		.FIFO_rd(FIFO_rd),
		.FIFO_wr(FIFO_wr),
		.clear_cal_ele_cho(clear_cal_ele_cho),
		.out_in(out_in)
	);
endmodule





 





