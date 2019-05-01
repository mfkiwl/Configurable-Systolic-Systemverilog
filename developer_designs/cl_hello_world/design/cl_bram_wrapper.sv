module cl_bram_wrapper #(
	parameter data_size = 8, systolic_size = 8, memory_data_size = 64, ADDR_W = 3
)(
   input clk,

   input write_en_a,
   input en_a,
   input[31:0] addr_a,
   input[31:0] write_data_a,
   output[31:0] read_data_a,

   input write_en_b,
   input en_b,
   input[31:0] addr_b,
   input[31:0] write_data_b,
   output[31:0] read_data_b
);

    
bram_2rw #(.WIDTH(32), .ADDR_WIDTH(32), .DEPTH(256) ) AXIL_RAM (
   .clk(clk),

   .wea(write_en_a),
   .ena(en_a),
   .addra(addr_a),
   .da(write_data_a),
   .qa(), 

   .web(write_en_b),
   .enb(en_b),
   .addrb(addr_b),
   .db(write_data_b),
   .qb(read_data_b)
   );

endmodule

