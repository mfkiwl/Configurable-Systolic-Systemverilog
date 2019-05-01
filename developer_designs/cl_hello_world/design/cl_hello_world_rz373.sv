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

module cl_hello_world_rz373

(
   `include "cl_ports.vh" // Fixed port definition

);

`include "cl_common_defines.vh"      // CL Defines for all examples
`include "cl_id_defines.vh"          // Defines for ID0 and ID1 (PCI ID's)
`include "cl_hello_world_defines.vh" // CL Defines for cl_hello_world

logic rst_main_n_sync;


//--------------------------------------------0
// Start with Tie-Off of Unused Interfaces
//---------------------------------------------
// the developer should use the next set of `include
// to properly tie-off any unused interface
// The list is put in the top of the module
// to avoid cases where developer may forget to
// remove it from the end of the file

`include "unused_flr_template.inc"
`include "unused_ddr_a_b_d_template.inc"
`include "unused_ddr_c_template.inc"
`include "unused_pcim_template.inc"
`include "unused_dma_pcis_template.inc"
`include "unused_cl_sda_template.inc"
`include "unused_sh_bar1_template.inc"
`include "unused_apppf_irq_template.inc"

//-------------------------------------------------
// Wires
//-------------------------------------------------
  logic        arvalid_q;
  logic [31:0] araddr_q;
  logic [31:0] hello_world_q;
  logic [7:0]  write_addr;
  logic [7:0]  read_addr;
  logic [31:0] ram_data;
  logic [7:0]  A_length;
  logic [7:0]  A_width;

  // Ashish - begin
  // added to handle random address
  // read and write
  logic [7:0]  new_read_addr;
  logic [7:0]  new_write_addr;
  logic        set_read_addr;
  logic        set_write_addr;

  // Ashish - end
    // Ashish - begin
  // added to handle random address
  // read and write
  logic [7:0]  new_A_length;
  logic [7:0]  new_A_width;
  logic        set_A_length;
  logic        set_A_width;

  // Ashish - end

//-------------------------------------------------
// ID Values (cl_hello_world_defines.vh)
//-------------------------------------------------
  assign cl_sh_id0[31:0] = `CL_SH_ID0;
  assign cl_sh_id1[31:0] = `CL_SH_ID1;

//-------------------------------------------------
// Reset Synchronization
//-------------------------------------------------
logic pre_sync_rst_n;

always_ff @(negedge rst_main_n or posedge clk_main_a0)
   if (!rst_main_n)
   begin
      pre_sync_rst_n  <= 0;
      rst_main_n_sync <= 0;
   end
   else
   begin
      pre_sync_rst_n  <= 1;
      rst_main_n_sync <= pre_sync_rst_n;
   end

//-------------------------------------------------
// PCIe OCL AXI-L (SH to CL) Timing Flops
//-------------------------------------------------

  // Write address                                                                                                              
  logic        sh_ocl_awvalid_q;
  logic [31:0] sh_ocl_awaddr_q;
  logic        ocl_sh_awready_q;
                                                                                                                              
  // Write data                                                                                                                
  logic        sh_ocl_wvalid_q;
  logic [31:0] sh_ocl_wdata_q;
  logic [ 3:0] sh_ocl_wstrb_q;
  logic        ocl_sh_wready_q;
                                                                                                                              
  // Write response                                                                                                            
  logic        ocl_sh_bvalid_q;
  logic [ 1:0] ocl_sh_bresp_q;
  logic        sh_ocl_bready_q;
                                                                                                                              
  // Read address                                                                                                              
  logic        sh_ocl_arvalid_q;
  logic [31:0] sh_ocl_araddr_q;
  logic        ocl_sh_arready_q;
                                                                                                                              
  // Read data/response                                                                                                        
  logic        ocl_sh_rvalid_q;
  logic [31:0] ocl_sh_rdata_q;
  logic [ 1:0] ocl_sh_rresp_q;
  logic        sh_ocl_rready_q;

  axi_register_slice_light AXIL_OCL_REG_SLC (
   .aclk          (clk_main_a0),
   .aresetn       (rst_main_n_sync),
   .s_axi_awaddr  (sh_ocl_awaddr),
   .s_axi_awprot   (2'h0),
   .s_axi_awvalid (sh_ocl_awvalid),
   .s_axi_awready (ocl_sh_awready),
   .s_axi_wdata   (sh_ocl_wdata),
   .s_axi_wstrb   (sh_ocl_wstrb),
   .s_axi_wvalid  (sh_ocl_wvalid),
   .s_axi_wready  (ocl_sh_wready),
   .s_axi_bresp   (ocl_sh_bresp),
   .s_axi_bvalid  (ocl_sh_bvalid),
   .s_axi_bready  (sh_ocl_bready),
   .s_axi_araddr  (sh_ocl_araddr),
   .s_axi_arvalid (sh_ocl_arvalid),
   .s_axi_arready (ocl_sh_arready),
   .s_axi_rdata   (ocl_sh_rdata),
   .s_axi_rresp   (ocl_sh_rresp),
   .s_axi_rvalid  (ocl_sh_rvalid),
   .s_axi_rready  (sh_ocl_rready),
   .m_axi_awaddr  (sh_ocl_awaddr_q),
   .m_axi_awprot  (),
   .m_axi_awvalid (sh_ocl_awvalid_q),
   .m_axi_awready (ocl_sh_awready_q),
   .m_axi_wdata   (sh_ocl_wdata_q),
   .m_axi_wstrb   (sh_ocl_wstrb_q),
   .m_axi_wvalid  (sh_ocl_wvalid_q),
   .m_axi_wready  (ocl_sh_wready_q),
   .m_axi_bresp   (ocl_sh_bresp_q),
   .m_axi_bvalid  (ocl_sh_bvalid_q),
   .m_axi_bready  (sh_ocl_bready_q),
   .m_axi_araddr  (sh_ocl_araddr_q),
   .m_axi_arvalid (sh_ocl_arvalid_q),
   .m_axi_arready (ocl_sh_arready_q),
   .m_axi_rdata   (ocl_sh_rdata_q),
   .m_axi_rresp   (ocl_sh_rresp_q),
   .m_axi_rvalid  (ocl_sh_rvalid_q),
   .m_axi_rready  (sh_ocl_rready_q)
  );

//--------------------------------------------------------------
// PCIe OCL AXI-L Slave Accesses (accesses from PCIe AppPF BAR0)
//--------------------------------------------------------------
// Only supports single-beat accesses.

   logic        awvalid;
   logic [31:0] awaddr;
   logic        wvalid;
   logic [31:0] wdata;
   logic [3:0]  wstrb;
   logic        bready;
   logic        arvalid;
   logic [31:0] araddr;
   logic        rready;

   logic        awready;
   logic        wready;
   logic        bvalid;
   logic [1:0]  bresp;
   logic        arready;
   logic        rvalid;
   logic [31:0] rdata;
   logic [1:0]  rresp;

   // Inputs
   assign awvalid         = sh_ocl_awvalid_q;
   assign awaddr[31:0]    = sh_ocl_awaddr_q;
   assign wvalid          = sh_ocl_wvalid_q;
   assign wdata[31:0]     = sh_ocl_wdata_q;
   assign wstrb[3:0]      = sh_ocl_wstrb_q;
   assign bready          = sh_ocl_bready_q;
   assign arvalid         = sh_ocl_arvalid_q;
   assign araddr[31:0]    = sh_ocl_araddr_q;
   assign rready          = sh_ocl_rready_q;

   // Outputs
   assign ocl_sh_awready_q = awready;
   assign ocl_sh_wready_q  = wready;
   assign ocl_sh_bvalid_q  = bvalid;
   assign ocl_sh_bresp_q   = bresp[1:0];
   assign ocl_sh_arready_q = arready;
   assign ocl_sh_rvalid_q  = rvalid;
   assign ocl_sh_rdata_q   = rdata;
   assign ocl_sh_rresp_q   = rresp[1:0];

// Write Request
logic        wr_active;
logic [31:0] wr_addr;

// Ashish - begin

// need to pipeline write address and ready
logic [31:0] wr_addr_q;
logic wready_q;

// Ashish - end

always_ff @(posedge clk_main_a0)
  if (!rst_main_n_sync) begin
     wr_active <= 0;
     wr_addr   <= 0;
     wready_q  <= 0;
     wr_addr_q <= 0;
  end
  else begin
     wr_active <=  wr_active && bvalid  && bready ? 1'b0     :
                  ~wr_active && awvalid           ? 1'b1     :
                                                    wr_active;
     wr_addr <= awvalid && ~wr_active ? awaddr : wr_addr     ;
     wready_q <= wready;
     wr_addr_q <= wr_addr;
  end

assign awready = ~wr_active;
assign wready  =  wr_active && wvalid;

// Write Response
always_ff @(posedge clk_main_a0)
  if (!rst_main_n_sync) 
    bvalid <= 0;
  else
    bvalid <=  bvalid &&  bready           ? 1'b0  : 
                         ~bvalid && wready ? 1'b1  :
                                             bvalid;
assign bresp = 0;

// Read Request
always_ff @(posedge clk_main_a0)
   if (!rst_main_n_sync) begin
      arvalid_q <= 0;
      araddr_q  <= 0;
   end
   else begin
      arvalid_q <= arvalid;
      araddr_q  <= arvalid ? araddr : araddr_q;
   end

assign arready = !arvalid_q && !rvalid;

// Read Response
// Ashish - begin

// read address incremented when arvalid_q and not arvalid
// set ram_data to rdata when arvalid_q since BRAM is synchronous
always_ff @(posedge clk_main_a0)
   if (!rst_main_n_sync)
   begin
      rvalid <= 0;
      rdata  <= 0;
      rresp  <= 0;
      read_addr[7:0]     <= 8'h0000_0000;
   end
   // set random read address
   else if (set_read_addr)
   begin
     read_addr <= new_read_addr;
   end
   else if (rvalid && rready)
   begin
      rvalid <= 0;
      rdata  <= 0;
      rresp  <= 0;
      read_addr          <= read_addr;
   end
   else if (arvalid_q) 
   begin
     if(araddr_q == `HELLO_WORLD_REG_ADDR) begin
      rvalid <= 1;
      rdata  <= ram_data ;
      rresp  <= 0;
      read_addr          <= read_addr + 1;
     end
     if(araddr_q == `SET_A_WIDTH_REG) begin
      rvalid <= 1;
      rresp  <= 0;
      rdata  <= A_width;
     end
   end

// Ashish - end

// Ashish - begin

// write address incremented when wready_q and not wready
always_ff @(posedge clk_main_a0)
   if (!rst_main_n_sync) begin                    // Reset
      write_addr[7:0]     <= 8'h0000_0000;
   end
   // set random write address
   else if (set_write_addr)
   begin
     write_addr <= new_write_addr;
   end
   else if (wready_q & (wr_addr_q == `HELLO_WORLD_REG_ADDR)) begin
      write_addr          <= write_addr + 1;
   end
   else begin                                // Hold Value
      write_addr          <= write_addr;
   end

// Ashish - end


// Ashish - begin

// A_length 
always_ff @(posedge clk_main_a0)
   if (!rst_main_n_sync) begin                    // Reset
       A_length[7:0]     <= 8'h0000_0000;
   end
   // set random write address
   else if (set_A_length)
   begin
       A_length <= new_A_length;
   end
   else begin                                // Hold Value
       A_length          <= A_length;
   end

// Ashish - end

// A_width 
always_ff @(posedge clk_main_a0)
   if (!rst_main_n_sync) begin                    // Reset
       A_width[7:0]     <= 8'h0000_0000;
   end
   // set random write address
   else if (set_A_width)
   begin
       A_width <= new_A_width;
   end
   else begin                                // Hold Value
       A_width          <= A_width;
   end

// Ashish - end

//-------------------------------------------------
// Hello World Register
//-------------------------------------------------
// Ashish -begin

always_ff @(posedge clk_main_a0)
   // reset
   if (!rst_main_n_sync) begin                 
      hello_world_q[31:0] <= 32'h0000_0000;
      set_read_addr <= 1'b0;
      new_read_addr[7:0] <= 8'h00;
      set_write_addr <= 1'b0;
      new_write_addr[7:0] <= 8'h00;
      set_A_length <= 1'b0;
      new_A_length <= 8'h00;
      set_A_width <= 1'b0;
      new_A_width <= 8'h00;
   end
   // get any write data
   else if (wready & (wr_addr == `HELLO_WORLD_REG_ADDR)) begin
      hello_world_q[31:0] <= wdata[31:0];
      set_read_addr <= 1'b0;
      new_read_addr[7:0] <= 8'h00;
      set_write_addr <= 1'b0;
      new_write_addr[7:0] <= 8'h00;
      set_A_length <= 1'b0;
      new_A_length <= 8'h00;
      set_A_width <= 1'b0;
      new_A_width <= 8'h00;
   end
   // initialize read address
   else if (wready & (wr_addr == `READ_ADDR_SET_REG)) begin
      hello_world_q[31:0] <= hello_world_q[31:0];
      new_read_addr[7:0] <= wdata[7:0];
      set_read_addr <= 1'b1;
      set_write_addr <= 1'b0;
      new_write_addr[7:0] <= 8'h00;
      set_A_length <= 1'b0;
      new_A_length <= 8'h00;
      set_A_width <= 1'b0;
      new_A_width <= 8'h00;
   end
   // initialize write address
   else if (wready & (wr_addr == `WRITE_ADDR_SET_REG)) begin
      hello_world_q[31:0] <= hello_world_q[31:0];
      new_write_addr[7:0] <= wdata[7:0];
      set_write_addr <= 1'b1;
      set_read_addr <= 1'b0;
      new_read_addr[7:0] <= 8'h00;
      set_A_length <= 1'b0;
      new_A_length <= 8'h00;
      set_A_width <= 1'b0;
      new_A_width <= 8'h00;
   end
   else if (wready & (wr_addr == `SET_A_LENGTH_REG)) begin
      hello_world_q[31:0] <= hello_world_q[31:0];
      set_read_addr <= 1'b0;
      new_read_addr[7:0] <= 8'h00;
      set_write_addr <= 1'b0;
      new_write_addr[7:0] <= 8'h00;
      set_A_length <= 1'b1;
      new_A_length <= wdata[7:0];
      set_A_width <= 1'b0;
      new_A_width <= 8'h00;
   end
   else if (wready & (wr_addr == `SET_A_WIDTH_REG)) begin
      hello_world_q[31:0] <= hello_world_q[31:0];
      set_read_addr <= 1'b0;
      new_read_addr[7:0] <= 8'h00;
      set_write_addr <= 1'b0;
      new_write_addr[7:0] <= 8'h00;
      set_A_width <= 1'b1;
      new_A_width <= wdata[7:0];
      set_A_length <= 1'b0;
      new_A_length <= 8'h00;
   end
   // hold write data
   else begin                              
      hello_world_q[31:0] <= hello_world_q[31:0];
      set_read_addr <= 1'b0;
      new_read_addr[7:0] <= 8'h00;
      set_write_addr <= 1'b0;
      new_write_addr[7:0] <= 8'h00;
      set_A_length <= 1'b0;
      new_A_length <= 8'h00;
      set_A_width <= 1'b0;
      new_A_width <= 8'h00;
   end

// Ashish -end



//-------------------------------------------------
// BRAM instantiation
//-------------------------------------------------

// Ashish - begin

cl_bram_wrapper BRAM_0(

        .clk(clk_main_a0),
        .write_en_a(wready_q),
        .en_a(wready_q),
        .addr_a(write_addr),
        .write_data_a(hello_world_q), 
        .read_data_a(),

        .write_en_b(1'b0),
        .en_b(arvalid),
        .addr_b(read_addr),
        .write_data_b(32'b0),
        .read_data_b(ram_data)

);

// Ashish - end

//-------------------------------------------
// Tie-Off Global Signals
//-------------------------------------------
`ifndef CL_VERSION
   `define CL_VERSION 32'hee_ee_ee_00
`endif  


  assign cl_sh_status0[31:0] =  32'h0000_0FF0;
  assign cl_sh_status1[31:0] = `CL_VERSION;

endmodule





