 // Amazon FPGA Hardware Development Kit
//
// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.


module test_hello_world
#(
  parameter data_size = 32, systolic_size = 4, memory_data_size = 128, ADDR_W = 2,
	baseaddr_A = 32'h0000_0000, baseaddr_B = 32'h0000_0000, baseaddr_C = 32'h0000_0040,
  matrix_size = 4
);

import tb_type_defines_pkg::*;
`include "cl_common_defines.vh" // CL Defines with register addresses

// AXI ID
parameter [5:0] AXI_ID = 6'h0;

logic [31:0] rdata;
logic [31:0] matrix_A[63: 0];
logic [31:0] matrix_B[63: 0];

   initial begin

      $dumpfile ("myfile.vcd"); 
      $dumpvars(1,cl_hello_world);

      tb.power_up();
      
      for (int i=0; i< 64; i++) begin
        matrix_A[i] = (i + 1) % 4;
        matrix_B[i] = (i + 1) % 4;        
      end


      // setup for A
        $display ("Set A matrix length : Writing 0x%x to address 0x%x", 4, `SET_A_LENGTH_REG);
        tb.poke(.addr(`SET_A_LENGTH_REG), .data(32'h0000_0004), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");        

        $display ("get A matrix size");
        tb.peek(.addr(`SET_A_LENGTH_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("get A matrix size: Getting A length 0x%x from address 0x%x", rdata, `SET_A_LENGTH_REG);
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"); 
        
        $display ("Set A matrix width : Writing 0x%x to address 0x%x", 4, `SET_A_WIDTH_REG);
        tb.poke(.addr(`SET_A_WIDTH_REG), .data(32'h0000_0004), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"); 

        $display ("get A matrix size");
        tb.peek(.addr(`SET_A_WIDTH_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("get A matrix size: Getting A width 0x%x from address 0x%x", rdata, `SET_A_WIDTH_REG);
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");     
        
        
        $display ("Set new write address : Writing 0x%x to address 0x%x", baseaddr_A, `WRITE_ADDR_SET_REG);
        tb.poke(.addr(`WRITE_ADDR_SET_REG), .data(baseaddr_A), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

        $display ("get write address");
        tb.peek(.addr(`WRITE_ADDR_SET_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("get  write address: Getting  write address 0x%x from address 0x%x", rdata, `WRITE_ADDR_SET_REG);
        
        for (int j=0; j<64; j++) begin
          $display ("Writing 0x%x to address 0x%x", matrix_A[j], `HELLO_WORLD_REG_ADDR);
          tb.poke(.addr(`HELLO_WORLD_REG_ADDR), .data(matrix_A[j]), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        end

        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

      
        $display ("Set new read address : Reading 0x%x to address 0x%x", baseaddr_A, `READ_ADDR_SET_REG);
        tb.poke(.addr(`READ_ADDR_SET_REG), .data(baseaddr_A), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

        for (int k=0; k<64; k++) begin
          tb.peek(.addr(`HELLO_WORLD_REG_ADDR), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL));         // start read & write
          $display ("Reading 0x%x from address 0x%x", rdata, `HELLO_WORLD_REG_ADDR);

          if (rdata == matrix_A[k]) // Check for byte swap in register read
                  $display ("Matrix_A Transfer PASSED");
          else
                  $display ("Matrix_A Transfer FAILED");
        end 

    //setup for B
        
        $display ("Set B matrix length : Writing 0x%x to address 0x%x", 4, `SET_B_LENGTH_REG);
        tb.poke(.addr(`SET_B_LENGTH_REG), .data(32'h0000_0004), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");        

        $display ("get B matrix size");
        tb.peek(.addr(`SET_B_LENGTH_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("get B matrix size: Getting B length 0x%x from address 0x%x", rdata, `SET_B_LENGTH_REG);
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"); 
        
        $display ("Set B matrix width : Writing 0x%x to address 0x%x", 4, `SET_B_WIDTH_REG);
        tb.poke(.addr(`SET_B_WIDTH_REG), .data(32'h0000_0004), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"); 

        $display ("get B matrix size");
        tb.peek(.addr(`SET_B_WIDTH_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("get B matrix size: Getting B width 0x%x from address 0x%x", rdata, `SET_B_WIDTH_REG);
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");     
        
        
        $display ("Set new write address : Writing 0x%x to address 0x%x", baseaddr_B, `WRITE_ADDR_SET_REG);
        tb.poke(.addr(`WRITE_ADDR_SET_REG), .data(baseaddr_B), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

        $display ("get write address");
        tb.peek(.addr(`WRITE_ADDR_SET_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("get B write address: Getting  write address 0x%x from address 0x%x", rdata, `WRITE_ADDR_SET_REG);
        
        for (int j=0; j<64; j++) begin
          $display ("Writing 0x%x to address 0x%x", matrix_B[j], `HELLO_WORLD_REG_ADDR);
          tb.poke(.addr(`HELLO_WORLD_REG_ADDR), .data(matrix_B[j]), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        end

        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

      
        $display ("Set new read address : Reading 0x%x to address 0x%x", baseaddr_B, `READ_ADDR_SET_REG);
        tb.poke(.addr(`READ_ADDR_SET_REG), .data(baseaddr_B), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

        for (int k=0; k<64; k++) begin
          tb.peek(.addr(`HELLO_WORLD_REG_ADDR), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL));         // start read & write
          $display ("Reading 0x%x from address 0x%x", rdata, `HELLO_WORLD_REG_ADDR);

          if (rdata == matrix_B[k]) // Check for byte swap in register read
                  $display ("Matrix_B Transfer PASSED");
          else
                  $display ("Matrix_B Transfer FAILED");
        end 
        
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");  
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");    
        $display ("Start Progress : set 0x%x to address 0x%x", 1, `FUNC_START);
        tb.poke(.addr(`FUNC_START), .data(1), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        
        tb.peek(.addr(`WORK_DONE), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL));         // start read & write
        $display ("Reading 0x%x from address 0x%x for the work_done", rdata, `WORK_DONE);

        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");


        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        
        tb.peek(.addr(`SET_C_WIDTH_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL));         // start read & write
        $display ("Reading 0x%x from address 0x%x for the work_done", rdata, `SET_C_WIDTH_REG);
        
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        
        tb.peek(.addr(`SET_C_LENGTH_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL));         // start read & write
        $display ("Reading 0x%x from address 0x%x for the work_done", rdata, `SET_C_LENGTH_REG);
        
        tb.peek(.addr(`WORK_DONE), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL));         // start read & write
        $display ("Reading 0x%x from address 0x%x for the work_done", rdata, `WORK_DONE);
        
      tb.kernel_reset();

      tb.power_down();
      
      $finish;
   end

endmodule // test_hello_world
