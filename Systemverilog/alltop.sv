//========================================================================
// Top Components for Projectdesign_Systolic_V_datapath
//========================================================================
//`define data_size 8
//`define systloic_size 2
//`define memory_data_size 16
//`define baseaddr_A 0x00000000
//`define baseaddr_B 0x05000000
//`define baseaddr_C 0x10000000

module alltop
#(
	parameter data_size = 32, systolic_size = 2, memory_data_size = 64, ADDR_W = 1, 
	baseaddr_A = 32'h00000000, baseaddr_B = 32'h40000000, baseaddr_C = 32'h80000000
)
(
  input  logic  clk,
  input  logic  reset,
  input  logic  [31:0] matrix_size,
  input  logic  go,
  output logic  finish,
  input  logic  work,
  input  logic  wready_q,
  input  logic  [31:0] write_addr,
  input  logic  [31:0] hello_world_q,
  input  logic  arvalid,
  input  logic  [31:0] read_addr,
  input  logic  A_cho,
  input  logic  B_cho,
  output logic  [31:0] ram_data
);        

  logic [31 : 0] memory_address_A;
  logic [31 : 0] memory_address_B;
  logic [31 : 0] memory_address_OUT;
  logic [memory_data_size - 1 : 0] memory_in_a;  
  logic [memory_data_size - 1 : 0] memory_in_b; 
  logic [memory_data_size - 1 : 0] memory_out;
  logic in_out,out_in;
  logic  [31:0] ram_data_a, ram_data_b;
  assign ram_data = B_cho ? ram_data_b : ram_data_a; 
 
 systolictop #(
       .data_size(data_size),
       .systolic_size(systolic_size),
       .memory_data_size(memory_data_size),
       .ADDR_W(ADDR_W),
       .baseaddr_A(baseaddr_A),
       .baseaddr_B(baseaddr_B), 
       .baseaddr_C(baseaddr_C)
     )
     topmod(
    .clk(clk), 
    .reset(reset), 
    .memory_in_a(memory_in_a), 
    .memory_in_b(memory_in_b),
    .memory_out(memory_out),
    .memory_address_OUT(memory_address_OUT),
    .memory_address_A(memory_address_A), 
    .memory_address_B(memory_address_B), 
    .in_out(in_out),
    .out_in(out_in),
    .matrix_size(matrix_size),
    .go(go),
    .done(finish)
 );


//-------------------------------------------------
// BRAM_a instantiation
//-------------------------------------------------

cl_bram_wrapper_a #(
       .data_size(data_size),
       .systolic_size(systolic_size),
       .memory_data_size(memory_data_size),
       .ADDR_W(ADDR_W)
     ) BRAM_a(
        .clk(clk),
		  .reset(reset),
		  
        .write_en_a(wready_q),
        .en_a(wready_q),
        .addr_a(write_addr),
        .write_data_a(hello_world_q), 
        .read_data_a(),

        .write_en_b(1'b0),
        .en_b(arvalid),
        .addr_b(read_addr),
        .write_data_b(32'b0),
        .read_data_b(ram_data_a),
         
        .memory_in_a(memory_in_a), 
        .memory_out(memory_out),
        .memory_address_OUT(memory_address_OUT),
        .memory_address_A(memory_address_A), 
        .in_out(in_out),
        .work(work),
        .A_cho(A_cho),
        .out_in(out_in)
);

cl_bram_wrapper_b #(
       .data_size(data_size),
       .systolic_size(systolic_size),
       .memory_data_size(memory_data_size),
       .ADDR_W(ADDR_W)
     ) BRAM_b(
        .clk(clk),
        .reset(reset),
        .write_en_a(wready_q),
        .en_a(wready_q),
        .addr_a(write_addr),
        .write_data_a(hello_world_q), 
        .read_data_a(),

        .write_en_b(1'b0),
        .en_b(arvalid),
        .addr_b(read_addr),
        .write_data_b(32'b0),
        .read_data_b(ram_data_b),
        
        .memory_in_b(memory_in_b),
        .memory_address_B(memory_address_B), 
        .in_out(in_out),
        .work(work),
        .B_cho(B_cho),
        .out_in(out_in)
);

endmodule





 





