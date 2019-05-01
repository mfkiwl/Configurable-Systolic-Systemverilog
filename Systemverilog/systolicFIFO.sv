//========================================================================
// Datapath Components for Projectdesign_Systolic_V_datapath
//========================================================================
module systolicFIFO
#(
	parameter data_size = 8, systolic_size = 2, memory_data_size = 16, ADDR_W = 1
)
(
			output   reg 		[data_size   	:	0]						data_out,
			input		wire		[data_size  	:	0]	    				data_in,
			input		wire														RD_EN,
			input		wire														WR_EN,
			input		wire 														reset,
			input		wire														clk
);
		
			reg					[ADDR_W			: 0]						count;
			reg 				   [data_size     : 0] 						mem_array [0 : (2**(ADDR_W + 1) - 1)];
			reg					[ADDR_W  		: 0]		  				rd_ptr, wr_ptr;
			wire																	empty,full;
			//reg																	error;

assign full = (count == (2**(ADDR_W + 1) - 1));
assign empty = (count == 0);
always @ (posedge clk)
begin
	if (reset) begin
		rd_ptr <= 0;
		wr_ptr <= 0;
		count <= 0;
	end
	else if (WR_EN == 1'b1 && (!full) && (RD_EN == 1'b0)) begin
		mem_array[wr_ptr]  <= data_in;
		wr_ptr <= wr_ptr + 1;
		count <= count + 1;
	end
	else if (WR_EN == 1'b0 && (!empty) && (RD_EN == 1'b1)) begin
		data_out  <= mem_array[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		count <= count - 1;
	end
	else if (WR_EN == 1'b1 && (empty) && (RD_EN == 1'b1)) begin
		mem_array[wr_ptr]  <= data_in;
		wr_ptr <= wr_ptr + 1;
		count <= count + 1;
	end
	else if (WR_EN == 1'b1 && (full) && (RD_EN == 1'b1)) begin
		data_out  <= mem_array[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		count <= count - 1;
	end
	else if ((WR_EN == 1'b1) && (!full) && (!empty) && (RD_EN == 1'b1)) begin
		mem_array[wr_ptr]  <= data_in;
		data_out  <= mem_array[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		wr_ptr <= wr_ptr + 1;
	end
	else if (WR_EN == 1'b0 && (empty) && (RD_EN == 1'b1)) begin
		data_out  <= 0;
	end
end
endmodule
