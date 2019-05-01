module test_peek_poke();

`define WR_INSTR_INDEX 64'h1c
`define WR_ADDR_LOW    64'h20
`define WR_ADDR_HIGH   64'h24
`define WR_DATA        64'h28
`define WR_SIZE        64'h2c

`define RD_INSTR_INDEX 64'h3c
`define RD_ADDR_LOW    64'h40
`define RD_ADDR_HIGH   64'h44
`define RD_DATA        64'h48
`define RD_SIZE        64'h4c

`define CNTL_REG       64'h08

`define WR_START_BIT   32'h00000001
`define RD_START_BIT   32'h00000002

   logic [63:0] pcim_address = 64'h0000_0000_1234_0000;

   initial begin
      
      $dumpfile("test.vcd");
      $dumpvars;

      tb.sh.power_up();

      tb.poke_ocl(`WR_INSTR_INDEX, 0);                   // write index
      tb.poke_ocl(`WR_ADDR_LOW, pcim_address[31:0]);     // write address low
      tb.poke_ocl(`WR_ADDR_HIGH, pcim_address[63:32]);   // write address high
      tb.poke_ocl(`WR_DATA, 32'h0000_0000);              // write data
      tb.poke_ocl(`WR_SIZE, 32'h0000_0002);              // write 32b

      tb.poke_ocl(`RD_INSTR_INDEX, 0);                   // read index
      tb.poke_ocl(`RD_ADDR_LOW, pcim_address[31:0]);     // read address low
      tb.poke_ocl(`RD_ADDR_HIGH, pcim_address[63:32]);   // read address high
      tb.poke_ocl(`RD_DATA, 32'h0000_0000);              // read data
      tb.poke_ocl(`RD_SIZE, 32'h0000_0002);              // read 32b

      tb.poke_ocl(`CNTL_REG, 32'h0003);                  // start read & write

      #500ns;   // give the hardware time to run


      tb.power_down();

      $finish;
   end

endmodule // test_peek_poke