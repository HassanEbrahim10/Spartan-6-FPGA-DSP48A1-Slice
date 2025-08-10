module mux (A , clk , rst , CEA , out , SEL );
parameter WIDTH = 18 ;
parameter RSTTYPE = "SYNC" ;
input SEL ;
input [WIDTH - 1 : 0] A ;
input clk , rst , CEA ;
output [WIDTH - 1 : 0] out ;

reg [WIDTH - 1 : 0] A_reg ;

generate
	if (RSTTYPE == "ASYNC") begin
		always @(posedge clk or posedge rst) begin
			if (rst) begin
				A_reg <= 0 ;
			end
			else if (CEA) begin
				A_reg <= A ;
			end
		end	
			
		assign out = (SEL == 0 )? A : A_reg ;
		
	end
	else if (RSTTYPE == "SYNC") begin
		always @(posedge clk ) begin
			if (rst) begin
				A_reg <= 0 ;
			end
			else if (CEA) begin
				A_reg <= A ;
			end
		end	
			
		assign out = (SEL == 0 )? A : A_reg ;
		
	end
endgenerate
endmodule
