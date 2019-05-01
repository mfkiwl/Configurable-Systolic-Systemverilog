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

`ifndef CL_COMMON_DEFAULTS
`define CL_COMMON_DEFAULTS

// Value to return for PCIS access to unimplemented register address
`define UNIMPLEMENTED_REG_VALUE 32'hdeaddead

// CL Register Addresses
`define HELLO_WORLD_REG_ADDR           32'h0000_0500
`define VLED_REG_ADDR                  32'h0000_0504
`define READ_ADDR_SET_REG              32'h0000_0508
`define WRITE_ADDR_SET_REG             32'h0000_050C
`define SET_A_LENGTH_REG               32'h0000_0510
`define SET_B_LENGTH_REG               32'h0000_0514
`define SET_C_LENGTH_REG               32'h0000_0518
`define SET_A_WIDTH_REG                32'h0000_051C
`define SET_B_WIDTH_REG                32'h0000_0520
`define SET_C_WIDTH_REG                32'h0000_0524
`define FUNC_START                     32'h0000_0528
`define WORK_DONE                      32'h0000_052C
`endif
