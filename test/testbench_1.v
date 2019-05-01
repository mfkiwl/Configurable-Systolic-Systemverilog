`timescale 1ns / 1ps
module tb
#(
	parameter data_size = 8, systolic_size = 2, memory_data_size = 16, ADDR_W = 1, 
	baseaddr_A = 64'h00000000, baseaddr_B = 64'h00000000, baseaddr_C = 64'h00000000
);
 // output
 wire  [31:0] ram_data;
 wire  done;
 // input
 reg clk;
 reg reset;
 reg [31:0] matrix_size;
 reg go;
 reg work;
 reg wready_q;
 reg [31:0] write_addr;
 reg [31:0] hello_world_q;
 reg arvalid;
 reg [31:0] read_addr;
 reg A_cho;
 reg B_cho;
 //reg [31:0] i;

 // Instantiate the Unit Under Test (UUT)
  alltop #(
       .data_size(32),
       .systolic_size(4),
       .memory_data_size(128),
       .ADDR_W(2),
       .baseaddr_A(32'h0000_0000),
       .baseaddr_B(32'h0000_0000), 
       .baseaddr_C(32'h0000_0040)
     ) test (
  .clk(clk),
  .reset(reset),
  .matrix_size(matrix_size),
  .go(go),
  .work(work),
  .wready_q(wready_q),
  .write_addr(write_addr),
  .hello_world_q(hello_world_q),
  .arvalid(arvalid),
  .read_addr(read_addr),
  .A_cho(A_cho),
  .B_cho(B_cho),
  .finish(done),
  .ram_data(ram_data)
 );

  integer i;
  initial begin
	  $display ($time, " << Starting the Simulation >> ");
	  reset = 0;
	  matrix_size = 8;
    work = 0;
    wready_q = 0;
    write_addr = 0;
    hello_world_q = 0;
    arvalid = 0;
    read_addr = 0;
    A_cho = 0;
    B_cho = 0;
	  go = 0;
	  repeat(2)  @(posedge clk);
  	reset = 1;
  	repeat(20) @(posedge clk);
  	reset = 0;
    repeat(20) @(posedge clk);
    //ATTENTION! A is inverse
    // the matrix of A is
    //  1 1 1 1 1 1 1 1
    //  2 2 2 2 2 2 2 2
    //  3 3 3 3 3 3 3 3
    //  0 0 0 0 0 0 0 0 
    //  1 1 1 1 1 1 1 1
    //  2 2 2 2 2 2 2 2
    //  3 3 3 3 3 3 3 3
    //  0 0 0 0 0 0 0 0 

    for (i = 0; i < 64; i = i+1) begin
        @(posedge clk);
        A_cho = 1;
        wready_q = 1;
        write_addr = i;
        hello_world_q = (i + 1) % 4;
      end
    @(posedge clk);
    wready_q = 0;
    write_addr = 0;
    hello_world_q = 0;

    repeat(20) @(posedge clk);
    for (i = 0; i < 64; i = i+1) begin
        @(posedge clk);
        arvalid = 1;
        read_addr = i;
      end  
    @(posedge clk);
    arvalid = 0;
    read_addr = 0;   


    // the matrix of B is
    //  1 2 3 0 1 2 3 0
    //  1 2 3 0 1 2 3 0
    //  1 2 3 0 1 2 3 0
    //  1 2 3 0 1 2 3 0 
    //  1 2 3 0 1 2 3 0
    //  1 2 3 0 1 2 3 0
    //  1 2 3 0 1 2 3 0
    //  1 2 3 0 1 2 3 0 
    repeat(20) @(posedge clk);
    A_cho = 0;
    @(posedge clk);
	  for (i = 0; i < 64; i = i+1) begin
        @(posedge clk);
        B_cho = 1;
        wready_q = 1;
        write_addr = i;
        hello_world_q = (i + 1) % 4;
      end
    @(posedge clk);
    wready_q = 0;
    write_addr = 0;
    hello_world_q = 0;

    repeat(20) @(posedge clk);
    for (i = 0; i < 64; i = i+1) begin
        @(posedge clk);
        arvalid = 1;
        read_addr = i;
      end  
    @(posedge clk);
    arvalid = 0;
    read_addr = 0; 
    repeat(20) @(posedge clk);
    go = 1;
    work = 1;
    @(posedge clk);
    go = 0;
    repeat(2000) @(posedge clk);
    $stop;
    // so the result of matrix A * matrix B is 
    //  8  16 24 0 8  16 24 0
    //  16 32 48 0 16 32 48 0
    //  24 48 72 0 24 48 72 0
    //  0  0  0  0 0  0  0  0
    //  8  16 24 0 8  16 24 0
    //  16 32 48 0 16 32 48 0
    //  24 48 72 0 24 48 72 0
    //  0  0  0  0 0  0  0  0
  end

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end


/*always begin
  // Wait 100 ns for global reset to finish
  #100 reset = 0;
  #5 reset = 1;
  #10 reset = 0;
  #10 go = 1;

  for (i = 0; i <= 4 * matrix_size * matrix_size; i = i+1) 
  begin
    begin
        #10 memory_in_a = (i % 5 << data_size) + i % 5;  memory_in_b = (i % 5 << data_size) + i % 5;
    end
  end
  $stop;
end*/

endmodule

