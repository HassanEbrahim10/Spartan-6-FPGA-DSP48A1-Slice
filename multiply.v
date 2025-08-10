module multiply (A , B , out);
parameter WIDTH_1 = 18 ;
parameter WIDTH_2 = 18 ;
input [WIDTH_1 - 1 : 0] A ;
input [WIDTH_2 - 1 : 0] B ;
output [WIDTH_1 + WIDTH_2 - 1 : 0] out ;

assign out = A * B ;

endmodule 