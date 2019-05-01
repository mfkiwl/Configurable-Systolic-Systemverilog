//========================================================================
// Components for Projectdesign_Systolicmemory
//========================================================================
// A systolicmemory which can hold small_size input and large_size 
module cl_bram_wrapper_a #(
	parameter data_size = 8, systolic_size = 8, memory_data_size = 64, ADDR_W = 3
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
   
   input logic [31 : 0] memory_address_A,
   input logic [31 : 0] memory_address_OUT,   
   output logic [memory_data_size - 1 : 0] memory_in_a, 
   input logic [memory_data_size - 1 : 0] memory_out, 
   input logic out_in,
   input logic in_out,
   input logic work,
   input logic A_cho
);

  logic [ADDR_W - 1 : 0] A_w_count,A_r_count;
  logic en_a_f;
  logic en_b_f;
  logic [memory_data_size - 1 : 0] write_data_a_f;
  logic [memory_data_size - 1 : 0] read_data_b_f;

  logic write_en_a_f;
  logic [31:0] addr_a_f;
  logic [31:0] addr_b_f;
  logic [31:0] addr_a_A;
  
  logic [data_size - 1  : 0] 	queue_w_A [0 : systolic_size - 1];
  logic [data_size - 1  : 0] 	queue_r_A [0 : systolic_size - 1];
  logic [memory_data_size - 1 : 0] read_data_b_reg;
  logic [memory_data_size - 1 : 0] write_data_a_A;     
  
   
  always_ff @(posedge clk) begin
	 if(reset)
		A_w_count <= 0;
    else if( A_cho && en_a)
      A_w_count <= A_w_count + 1;
    end
	 
  always_ff @(posedge clk) begin
    if( A_cho && en_a)
      queue_w_A[A_w_count] <= write_data_a;
    end 
  
  always_ff @(posedge clk) begin
    if( A_cho && en_b)
      read_data_b_reg <= read_data_b_f;
    end 
    
  always_ff @(posedge clk) begin
    if(reset)
		A_r_count <= 0;
    else if( A_cho && en_b)
      A_r_count <= A_r_count + 1;
    end
    
  // for the memory output b
  assign en_b_f = (work == 1) ? out_in : en_b;
  assign addr_b_f = (work == 1) ? memory_address_A : (addr_b >> ADDR_W);
  assign memory_in_a = (work == 1 && out_in == 1) ? read_data_b_f : 'bz; 
  assign read_data_b = (A_r_count == 1) ? read_data_b_f[data_size - 1 : 0] :((A_r_count == 0) ? queue_r_A[{(ADDR_W){1'b1}}]: queue_r_A[A_r_count - 1]);
  
  // for the memory input a
  assign write_data_a_f = (work == 1) ? memory_out : write_data_a_A;
  assign write_en_a_f = (work == 1) ? in_out : write_en_a;
  assign addr_a_A = (addr_a >> (ADDR_W));
  assign addr_a_f = (work == 1) ? memory_address_OUT : addr_a_A;
  assign en_a_A = ( A_w_count == {(ADDR_W){1'b1}} )? en_a : 0 ;
  assign en_a_f = (work == 1) ? in_out : en_a_A;
  
  
  genvar i;
  generate
  for(i = 0; i < systolic_size; i = i + 1) begin: generate_signal
    assign queue_r_A[i] = read_data_b_reg[ data_size * i + data_size - 1: data_size * i ];    
  end
  endgenerate
    
  genvar j;
  generate
  for(j = 0; j < systolic_size - 1; j = j + 1) begin: generate_input
    assign write_data_a_A[data_size * j + data_size - 1 : data_size * j] = queue_w_A[j]; 
  end
  endgenerate
  
  assign write_data_a_A[memory_data_size - 1 : data_size * (systolic_size -1 )] = write_data_a;
  
systolicmemory_dual #(.DATA_WIDTH(memory_data_size), .ADDR_WIDTH(32), .DEPTH(128) ) dual_port_A(
   .clk(clk),

   .wea(write_en_a_f),
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


