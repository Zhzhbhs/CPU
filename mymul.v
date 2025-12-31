
`include "lib/defines.vh"

module mymul(
	input wire rst,							
	input wire clk,						
	input wire signed_mul_i,				
	input wire[31:0] a_o,				
	input wire[31:0] b_o,				
	input wire start_i,						
	output reg[63:0] result_o,				
	output reg ready_o						
);
reg [31:0] temp_opa,temp_opb;
reg [63:0] pv;
reg [63:0] ap;
reg [5:0] i;
reg [1:0] state;

always @ (posedge clk) begin
		if (rst) begin
			state <= `MulFree;
			result_o <= {`ZeroWord,`ZeroWord};
			ready_o <= `MulResultNotReady;
		end else begin
			case(state)			
				`MulFree: begin			//乘法器空闲
                    if (start_i== `MulStart) begin
                        state <= `MulOn;
                        i <= 6'b00_0000;
					    if(signed_mul_i == 1'b1 && a_o[31] == 1'b1) begin			
							temp_opa = ~a_o + 1;
						end else begin
							temp_opa = a_o;
						end
						if(signed_mul_i == 1'b1 && b_o[31] == 1'b1 ) begin			
								temp_opb = ~b_o + 1;
						end else begin
							temp_opb = b_o;
						end
                        ap <= {32'b0,temp_opa};
						ready_o <= `MulResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
                        pv <= 64'b0;
                    end
				end				
				
				`MulOn: begin				
                        if(i != 6'b100000) begin
                            if(temp_opb[0]==1'b1) begin
								pv <= pv + ap;
								ap <= {ap[62:0],1'b0};
								temp_opb <= {1'b0,temp_opb[31:1]};
							end
							else begin 
                                ap <= {ap[62:0],1'b0};
								temp_opb <= {1'b0,temp_opb[31:1]};
							end 	
                            i <= i + 1;
                        end
						else begin
							if ((signed_mul_i == 1'b1) && ((a_o[31] ^ b_o[31]) == 1'b1))begin
							    pv <= ~pv + 1;
							end
							state <= `MulEnd;
							i <= 6'b00_0000;
						end
					   
				end
				
				`MulEnd: begin			
					result_o <= pv;
					ready_o <= `MulResultReady;
					if (start_i == `MulStop) begin
						state <= `MulFree;
						ready_o <= `MulResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
					end
				end
				
			endcase
		end
	end

endmodule

