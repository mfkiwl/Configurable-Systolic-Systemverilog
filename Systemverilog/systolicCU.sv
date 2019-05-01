//========================================================================
// Datapath Components for Projectdesign_Systolic_V_datapath
//========================================================================
//`define data_size 8
//`define axis_num 3


module systolicCU
#(
	parameter data_size = 8, systolic_size = 4, memory_data_size = 32, ADDR_W = 2, 
	baseaddr_A = 32'h00000000, baseaddr_B = 32'h40000000, baseaddr_C = 32'h80000000
)
(
 input  wire  clk,
 input  wire  reset,
 input  wire  [31:0] matrix_size,
 input  wire  go,
 output reg  done,
 output reg  mem_ele_cho,
 output reg  mem_change,
 output reg  [31:0] memory_address_A,
 output reg  [31:0] memory_address_B,
 output reg  [31:0] memory_address_OUT,
 output reg  in_out,
 output reg  out_in,
 output reg  [systolic_size - 1 :0] FIFO_rd,
 output reg  [systolic_size - 1 :0] FIFO_wr,
 output reg  [systolic_size - 1 :0] clear_cal_ele_cho
);
	reg [28 : 0] A_round;      // matrix_A_size/systolic_size
	reg [28 : 0] B_round;	   // matrix_A_size/systolic_size
	reg [28 : 0] in_round;		// 2*systolic_size - 1
	reg [28 : 0] A_count;
	reg [28 : 0] B_count;
	reg [28 : 0] in_count;
	reg [28 : 0] flush_count;	// systolic_size
	reg [28 : 0] load_count;	// matrix_size

reg [systolic_size - 1 : 0] FIFO_rd_O;
reg [4:0] state_reg,state_next;
localparam IDLE  = 0;
localparam WAIT  = 1;
localparam LOAD  = 2;
localparam CALC  = 3;
localparam CHANGE= 4;
localparam FLUSH = 5;
localparam UPDATE= 6;
localparam DONE  = 7;

always @(posedge clk) begin
    if (reset) begin
        state_reg <= IDLE;
    end
    else begin
        state_reg <= state_next;
    end
end 

always @(*) begin 
    case (state_reg)
	   IDLE: begin
			if(go)
				state_next <= WAIT;
			else
				state_next <= IDLE;
		end
		WAIT:
			state_next <= LOAD;
		LOAD:
			state_next <= CALC;
		CALC:
			if(in_count == in_round - 1 + matrix_size)
				state_next <= CHANGE;
			else
				state_next <= CALC;
		CHANGE:
			state_next <= FLUSH;
		FLUSH:
			if(flush_count == systolic_size - 1)
				state_next <= UPDATE;
			else
				state_next <= FLUSH;
		UPDATE:
			if((A_count == A_round - 1)&& (B_count == B_round - 1))
				state_next <= DONE;
			else
				state_next <= WAIT;
		DONE:
			begin
			end
		default:
			state_next <= IDLE;
    endcase
end 


always @(posedge clk) begin
    case (state_reg)  
        IDLE: begin
				load_count <= 0;
				FIFO_rd_O  <= 0;
				memory_address_A <= baseaddr_A;
				memory_address_B <= baseaddr_B;
				memory_address_OUT <= baseaddr_C;
				A_round  <= matrix_size >> ADDR_W;
				B_round  <= matrix_size >> ADDR_W;
				in_round <= 2 * systolic_size - 1;
				A_count <= 0;
				B_count <= 0;
				in_count <= 0;
				flush_count <= 0;
				load_count <= 0;
				mem_ele_cho <= 0;
				mem_change <= 0;
				FIFO_wr <= 'b0;
				done <= 0;
				clear_cal_ele_cho <= 0;
				in_out <= 0;
				out_in <= 0;
				FIFO_rd <= 0;
        end
		  WAIT: begin
				memory_address_A <= baseaddr_A + A_count;
				memory_address_B <= baseaddr_B + B_count;
				out_in <= 1;
				in_count <= 0;
				mem_ele_cho <= 0;
				mem_change <= 0;
				flush_count <= 0;
				clear_cal_ele_cho <= 0;
				in_out <= 0;
				FIFO_rd <= FIFO_rd_O;
		  end
		  LOAD: begin
		      FIFO_wr <= ~0;
				load_count <= load_count + 1;				
				memory_address_OUT <= memory_address_A + baseaddr_C - baseaddr_A + B_count * matrix_size;
				memory_address_A <= memory_address_A + (matrix_size >> (ADDR_W));
				memory_address_B <= memory_address_B + (matrix_size >> (ADDR_W));
		  end
		  CALC: begin
		  		FIFO_rd <= (FIFO_rd << 1) + 1;
				in_count <= in_count + 1;
				if(in_count == 1)
					clear_cal_ele_cho <= 1;
				else
					clear_cal_ele_cho <= clear_cal_ele_cho << 1;
				if(load_count < matrix_size  ) begin   // seems like matrix_size -1 is correct?
					load_count <= load_count + 1;
					FIFO_wr <= ~0;
					memory_address_A <= memory_address_A + (matrix_size >> (ADDR_W));
					memory_address_B <= memory_address_B + (matrix_size >> (ADDR_W));
				end
				else if (load_count == matrix_size  ) begin
					FIFO_wr <= 0;
					out_in <= 0;
				end
		  end
		  CHANGE:begin
				mem_ele_cho <= 0;
				mem_change <= 1;
				load_count <= 0;
				in_out <= 1;
			end
		  FLUSH: begin
				mem_ele_cho <= 1;
				mem_change <= 1;
				if( flush_count == 0)
					memory_address_OUT <= memory_address_OUT;
				else
					memory_address_OUT <= memory_address_OUT + (matrix_size >> (ADDR_W));
				flush_count <= flush_count + 1;
		  end
		  UPDATE:begin
				if(A_count < A_round - 1) begin
					A_count <= A_count + 1;
				end
				else if(A_count == A_round - 1) begin
					A_count <= 0;
					B_count <= B_count + 1;
				end				
				in_out = 0;
		  end
		  DONE:begin
		      done <= 1;
				load_count <= 0;
				FIFO_rd_O  <= 0;
				A_count <= 0;
				B_count <= 0;
				in_count <= 0;
				flush_count <= 0;
				load_count <= 0;
				mem_ele_cho <= 0;
				mem_change <= 0;
				FIFO_wr <= 'b0;
				clear_cal_ele_cho <= 0;
				in_out = 0;
		  end
		  default: begin
		  end
    endcase
end
endmodule


