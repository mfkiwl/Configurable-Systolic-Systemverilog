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


module test_hello_world_rz373();

import tb_type_defines_pkg::*;
`include "cl_common_defines.vh" // CL Defines with register addresses

// AXI ID
parameter [5:0] AXI_ID = 6'h0;

logic [31:0] rdata;
logic [31:0] rand_32[10];

   initial begin

      tb.power_up();
      
      for (int i=0; i<10; i++) begin
        rand_32[i] = $random;
      end

        $display ("Set A matrix size : Writing 0x%x to address 0x%x", 8, `SET_A_LENGTH_REG);
        tb.poke(.addr(`SET_A_LENGTH_REG), .data(32'h0000_0008), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");        

        $display ("Set A matrix size : Writing 0x%x to address 0x%x", 1, `SET_A_WIDTH_REG);
        tb.poke(.addr(`SET_A_WIDTH_REG), .data(32'h0000_0001), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"); 
                
        $display ("Set new write address : Writing 0x%x to address 0x%x", 127, `WRITE_ADDR_SET_REG);
        tb.poke(.addr(`WRITE_ADDR_SET_REG), .data(32'h0000_007F), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

      for (int j=0; j<10; j++) begin
        $display ("Writing 0x%x to address 0x%x", rand_32[j], `HELLO_WORLD_REG_ADDR);
        tb.poke(.addr(`HELLO_WORLD_REG_ADDR), .data(rand_32[j]), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
      end

        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");


        $display ("get A matrix size");
        tb.peek(.addr(`SET_A_WIDTH_REG), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // set length
        $display ("get A matrix size: Getting A width 0x%x from address 0x%x", rdata, `SET_A_WIDTH_REG);
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"); 

        $display ("Set new read address : Writing 0x%x to address 0x%x", 132, `READ_ADDR_SET_REG);
        tb.poke(.addr(`READ_ADDR_SET_REG), .data(32'h0000_0084), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL)); // write register
        $display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

      for (int k=5; k<10; k++) begin
        tb.peek(.addr(`HELLO_WORLD_REG_ADDR), .data(rdata), .id(AXI_ID), .size(DataSize::UINT16), .intf(AxiPort::PORT_OCL));         // start read & write
        $display ("Reading 0x%x from address 0x%x", rdata, `HELLO_WORLD_REG_ADDR);

        if (rdata == rand_32[k]) // Check for byte swap in register read
                $display ("Test PASSED");
        else
                $display ("Test FAILED");
      end      

      tb.kernel_reset();

      tb.power_down();
      
      $finish;
   end

endmodule // test_hello_world_rz373
