module ADD_SUBTRACT (D , B , operation , out , cout , cin);
parameter SEL = "Pre" ;
parameter WIDTH_1 = 18 ;
parameter WIDTH_2 = 18 ;
input [WIDTH_1 - 1 : 0] D ;
input [WIDTH_2 - 1 : 0] B ;
input cin , operation ;
output reg cout ;
output reg [WIDTH_1- 1 : 0] out ;

always @(*) begin 
	if(SEL == "Pre") begin
		if(operation)begin
			out = D - B ;
		end
		else begin
			out = D + B ;
		end
	end 
	else if (SEL == "Post") begin
		if(operation)begin
			out = D - (B + cin) ;
			cout = 0 ;
		end
		else begin
			{cout , out} = D + B + cin ;
		end
	end 
end


endmodule 