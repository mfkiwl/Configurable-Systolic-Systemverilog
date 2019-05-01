//========================================================================
// Components for Projectdesign_Systolicmemory
//========================================================================
// A systolicmemory which can hold small_size input and large_size 

module cl_bram_wrapper_b #(
	parameter data_size = 32, systolic_size = 2, memory_data_size = 64, ADDR_W = 3
)(
   input clk,
   input reset,
   input write_en_a,
   input en_a,
   input[31:0] addr_a,
   input[31:0] write_data_a,
   output[31:0] read_data_a,

   input write_en_b,
   input en_b,
   input[31:0] addr_b,
   input[31:0] write_data_b,
   output[31:0] read_data_b,
   
   input logic [31 : 0] memory_address_B,
   output logic [memory_data_size - 1 : 0] memory_in_b, 
   input logic out_in,
   input logic in_out,
   input logic work,
   input logic B_cho
);
  logic [ADDR_W - 1 : 0] B_w_count,B_r_count;
  logic en_a_f;
  logic	[data_size - 1  : 0] 	queue_w_B [0 : systolic_size - 1];
  logic [data_size - 1  : 0] 	queue_r_B [0 : systolic_size - 1];
  logic [memory_data_size - 1 : 0] read_data_b_reg;
  logic [memory_data_size - 1 : 0] write_data_a_f; 
  logic en_b_f;
  logic [memory_data_size - 1 : 0] read_data_b_f; 
  logic [31:0] addr_b_f;
  logic [31:0] addr_a_f;

   
  always_ff @(posedge clk) begin
    if (reset)
      B_w_count <= 0;
    else if( B_cho && en_a)
      B_w_count <= B_w_count + 1;
    end
  always_ff @(posedge clk) begin
    if( B_cho && en_a)
      queue_w_B[B_w_count] <= write_data_a;
    end 
  
  always_ff @(posedge clk) begin
    if( B_cho && en_b)
      read_data_b_reg <= read_data_b_f;
    end 

  always_ff @(posedge clk) begin
    if (reset)
      B_r_count <= 0;
    else if( B_cho && en_b)
      B_r_count <= B_r_count + 1;
    end
    
  // for the memory output b
  assign en_b_f = (work == 1) ? out_in : en_b; 
  assign addr_b_f = (work == 1) ? memory_address_B : (addr_b >> (ADDR_W));
  assign read_data_b = (B_r_count == 1) ? read_data_b_f[data_size - 1 : 0] : ((B_r_count == 0)? queue_r_B[{(ADDR_W){1'b1}} ]:queue_r_B[B_r_count - 1]);
  assign memory_in_b = (work == 1 && out_in == 1) ? read_data_b_f : 'bz; 
  
  // for the memory input a
  assign en_a_f = ( B_w_count ==  {(ADDR_W){1'b1}} ) ? en_a : 0;
  assign addr_a_f = (addr_a >> (ADDR_W));
  
  
  genvar i;
  generate
  for(i = 0; i < systolic_size; i = i + 1) begin: generate_output
    assign queue_r_B[i] = read_data_b_reg[ data_size * i + data_size - 1: data_size * i ];    
  end
  endgenerate
  
  genvar j;
  generate
  for(j = 0; j < systolic_size - 1;j = j + 1) begin: generate_input
	 assign write_data_a_f[data_size * j + data_size - 1 : data_size * j] = queue_w_B[j];
  end
  endgenerate
  assign write_data_a_f[memory_data_size - 1 : data_size * (systolic_size - 1)] = write_data_a;
  
bram_2rw #(.WIDTH(memory_data_size), .ADDR_WIDTH(32), .DEPTH(128) ) AXIL_RAM (
   .clk(clk),

   .wea(write_en_a),
   .ena(en_a_f),
   .addra(addr_a_f),
   .da(write_data_a_f),
   .qa(), 

   .web(write_en_b),
   .enb(en_b_f),
   .addrb(addr_b_f),
   .db(write_data_b),
   .qb(read_data_b_f)
   );

endmodule

