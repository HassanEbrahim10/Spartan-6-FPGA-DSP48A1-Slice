module DSP48A1 (A , B , D , BCIN , C , CARRYIN , clk , PCIN , OPMODE , CEA , CEB , CEC , CECARRYIN , CED 
	, CEM , CEOPMODE , CEP , RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP , M , BCOUT , P , PCOUT , CARRYOUT , CARRYOUTF );


parameter A0REG = 0 ; // If equal (0) --> No register, else --> Registered 
parameter A1REG = 1 ; // If equal (0) --> No register, else --> Registered 
parameter B0REG = 0 ; // If equal (0) --> No register, else --> Registered 
parameter B1REG = 1 ; // If equal (0) --> No register, else --> Registered 
parameter CREG = 1  ; // If equal (0) --> No register, else --> Registered 
parameter DREG = 1 ; // If equal (0) --> No register, else --> Registered 
parameter MREG = 1 ; // If equal (0) --> No register, else --> Registered 
parameter PREG = 1  ; // If equal (0) --> No register, else --> Registered 
parameter CARRYINREG = 1 ; // If equal (0) --> No register, else --> Registered 
parameter CARRYOUTREG = 1 ; // If equal (0) --> No register, else --> Registered 
parameter OPMODEREG = 1 ; // If equal (0) --> No register, else --> Registered 
parameter CARRYINSEL = "OPMODE5"; // Select between (CARRYIN or OPMODE5)
parameter B_INPUT = "DIRECT" ; // Select between (DIRECT or CASCADE)
parameter RSTTYPE = "SYNC" ; // Select between (SYNC or A SYNC)


input [17:0] A , B , D ;
input [17:0] BCIN ;
input [47:0] C ;
input CARRYIN , clk ;
input [47:0] PCIN ;  // Cascade input for Port P
input [7:0] OPMODE ;

input CEA ; // Clock enable for the A port registers: (A0REG & A1REG)
input CEB ; // Clock enable for the B port registers: (B0REG & B1REG)
input CEC ; // Clock enable for the C port registers (CREG)
input CECARRYIN ; // Clock enable for the carry-in register (CYI) and the carry-out register (CYO)
input CED ; // Clock enable for the D port register (DREG)
input CEM ; // Clock enable for the multiplier register (MREG)
input CEOPMODE ; // Clock enable for the opmode register (OPMODEREG)
input CEP ; // Clock enable for the P output port registers (PREG = 1)

input RSTA ; // Reset for the A registers: (A0REG & A1REG)
input RSTB ; // Reset for the B registers: (B0REG & B1REG)
input RSTC ; // Reset for the C registers (CREG)
input RSTCARRYIN ; // Reset for the carry-in register (CYI) and the carry-out register (CYO)
input RSTD ; // Reset for the D register (DREG)
input RSTM ; // Reset for the multiplier register (MREG)
input RSTOPMODE ; // Reset for the opmode register (OPMODEREG)
input RSTP ; // Reset for the P output registers (PREG = 1)

output [35:0] M ;
output [17:0] BCOUT ; //Cascade output for Port B
output [47:0] P ;
output [47:0] PCOUT ; // Cascade output for Port P
output CARRYOUT , CARRYOUTF ;

wire [7:0] OPMODE_reg ;
// module mux (A , clk , rst , CEA , out , SEL );
mux #(8 , RSTTYPE) OPMODE_part (OPMODE , clk , RSTOPMODE , CEOPMODE ,  OPMODE_reg , OPMODEREG );



wire [17:0] A0_reg ;
wire [17:0] D_reg ;
wire [47:0] C_reg ;
reg [17:0] B0_before_reg ;
wire [17:0] B0_reg ;

// module mux (A , clk , rst , CEA , out , SEL );
mux #(18 , RSTTYPE) A_part_1 (A , clk , RSTA , CEA ,  A0_reg , A0REG );
mux #(18 , RSTTYPE) D_part (D , clk , RSTD , CED ,  D_reg , DREG );
mux #(48 , RSTTYPE) C_part (C , clk , RSTC , CEC ,  C_reg , CREG );
mux #(18 , RSTTYPE) B_part_1 (B0_before_reg , clk , RSTB , CEB ,  B0_reg , B0REG );

always @(B , BCIN) begin
	if (B_INPUT == "DIRECT") begin
		B0_before_reg = B ;
	end
	else if (B_INPUT == "CASCADE") begin
		B0_before_reg = BCIN ;
	end
	else begin
		B0_before_reg = 0 ;
	end
end

wire [17:0] Pre_out ;
// module ADD_SUBTRACT (D , B , operation , out , cout , cin);
assign Pre_out = (OPMODE_reg[6] == 1)? (D_reg-B0_reg) : (D_reg+B0_reg) ;

wire [17:0] B1_before_reg ;
assign B1_before_reg = (OPMODE_reg[4] == 0 )? B : Pre_out ; 

wire [17:0] A1_reg ;
wire [17:0] B1_reg ;
// module mux (A , clk , rst , CEA , out , SEL );
mux #(.WIDTH(18) , .RSTTYPE(RSTTYPE)) A_part_2 (.A(A0_reg) , .clk(clk) , .rst(RSTA) , .CEA(CEA) , .out(A1_reg) , .SEL(A1REG) );
mux #(18 , RSTTYPE) B_part_2 (B1_before_reg , clk , RSTB , CEB ,  B1_reg , B1REG );

assign BCOUT = B1_reg ;

wire [35:0] M_before ;
wire [35:0] M_reg ;

// module multiply (A , B , out);
multiply #(.WIDTH_1(18) , .WIDTH_2(18)) multiplier (B1_reg , A1_reg , M_before);
mux #(36 , RSTTYPE) M_part (M_before , clk , RSTM , CEM ,  M_reg , MREG );

assign M = M_reg ;
assign PCOUT = P ;

wire [47 : 0] in0_of_X = {D[11:0] , A[17:0] , B[17:0]};

wire [47 : 0] mux_X_out ;
wire [47 : 0] mux_Z_out ;

assign mux_X_out = (OPMODE_reg[1:0] == 1)? M_reg : (OPMODE_reg[1:0] == 2)? P : (OPMODE_reg[1:0] == 3)? in0_of_X : 0 ;
assign mux_Z_out = (OPMODE_reg[3:2] == 1)? PCIN : (OPMODE_reg[3:2] == 2)? P : (OPMODE_reg[3:2] == 3)? C_reg : 0 ;

wire CYI , CIN ;

assign CYI = (CARRYINSEL == "OPMODE5")? OPMODE_reg[5] :(CARRYINSEL == "CARRYIN")? CARRYIN : 0  ;

// module mux (A , clk , rst , CEA , out , SEL );
mux #(1 , RSTTYPE) CYI_part (CYI , clk , RSTCARRYIN , CECARRYIN ,  CIN , CARRYINREG);


wire [47:0] Post_out ;
wire Post_cout ;

// module ADD_SUBTRACT (D , B , operation , out , cout , cin);
ADD_SUBTRACT #(.SEL("Post") , .WIDTH_1(48) , .WIDTH_2(48)) Post_Adder_or_Sutracter ( mux_Z_out , mux_X_out , OPMODE_reg[7] , Post_out , Post_cout , CIN);


// module mux (A , clk , rst , CEA , out , SEL );
mux #(1 , RSTTYPE) CYO_part (Post_cout , clk , RSTCARRYIN , CECARRYIN ,  CARRYOUT , CARRYOUTREG);
mux #(48 , RSTTYPE) P_part (Post_out , clk , RSTP , CEP ,  P , PREG); 

assign CARRYOUTF = CARRYOUT ;

endmodule