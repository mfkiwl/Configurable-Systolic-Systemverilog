//========================================================================
// Datapath Components for Projectdesign_Systolic_V_datapath
//========================================================================

 
module processelement #(
parameter data_size = 8
)
(
  input  wire clk,
  input  wire reset,
  input  wire cal_ele_cho_in,
  input  wire mem_ele_cho,
  input  wire mem_change,
  input  wire [data_size - 1:0] MUL_A_in,
  input  wire [data_size - 1:0] MUL_B_in,
  output reg  [data_size - 1:0] MUL_A_out,
  output reg  [data_size - 1:0] MUL_B_out,  
  output reg  [data_size - 1:0] MEM_out,
  output reg  [data_size - 1:0] MUL_C_out,
  output reg cal_ele_cho_out,
  input  wire [data_size - 1:0] MEM_in
);

  wire [data_size - 1:0] RESULT;
  wire [data_size - 1:0] NEXT_RESULT;
  wire [data_size - 1:0] Meminput;
  
  assign RESULT 		= MUL_A_in * MUL_B_in;
  assign NEXT_RESULT = cal_ele_cho_in ? RESULT : RESULT + MUL_C_out;
  assign Meminput 	= mem_ele_cho ? MEM_in : NEXT_RESULT;
  
  always @( posedge clk ) begin
    if ( reset ) begin
      MUL_C_out <= 'b0;
		MEM_out <= 'b0;
		MUL_A_out <= 'b0;
		MUL_B_out <= 'b0;
		cal_ele_cho_out <= 0;
	 end
    else begin
      MUL_C_out <= NEXT_RESULT;
		MUL_A_out <= MUL_A_in;
		MUL_B_out <= MUL_B_in;
		cal_ele_cho_out <= cal_ele_cho_in;
		if (mem_change) begin
			MEM_out = Meminput;
		end
	 end
   end

endmodule





