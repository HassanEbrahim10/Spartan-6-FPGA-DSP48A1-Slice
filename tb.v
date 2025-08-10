module DSP48A1_tb ( );


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


reg [17:0] A , B , D ;
reg [17:0] BCIN ;
reg [47:0] C ;
reg CARRYIN , clk ;
reg [47:0] PCIN ;  // Cascade input for Port P
reg [7:0] OPMODE ;

reg CEA ; // Clock enable for the A port registers: (A0REG & A1REG)
reg CEB ; // Clock enable for the B port registers: (B0REG & B1REG)
reg CEC ; // Clock enable for the C port registers (CREG)
reg CECARRYIN ; // Clock enable for the carry-in register (CYI) and the carry-out register (CYO)
reg CED ; // Clock enable for the D port register (DREG)
reg CEM ; // Clock enable for the multiplier register (MREG)
reg CEOPMODE ; // Clock enable for the opmode register (OPMODEREG)
reg CEP ; // Clock enable for the P output port registers (PREG = 1)

reg RSTA ; // Reset for the A registers: (A0REG & A1REG)
reg RSTB ; // Reset for the B registers: (B0REG & B1REG)
reg RSTC ; // Reset for the C registers (CREG)
reg RSTCARRYIN ; // Reset for the carry-in register (CYI) and the carry-out register (CYO)
reg RSTD ; // Reset for the D register (DREG)
reg RSTM ; // Reset for the multiplier register (MREG)
reg RSTOPMODE ; // Reset for the opmode register (OPMODEREG)
reg RSTP ; // Reset for the P output registers (PREG = 1)

wire [35:0] M_tb ;
wire [17:0] BCOUT_tb ; //Cascade output for Port B
wire [47:0] P_tb ;
wire [47:0] PCOUT_tb ; // Cascade output for Port P
wire CARRYOUT_tb , CARRYOUTF_tb ;

// module DSP48A1 (A , B , D , BCIN , C , CARRYIN , clk , PCIN , OPMODE , CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP , RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP , M , BCOUT , P , PCOUT , CARRYOUT , CARRYOUTF );

DSP48A1 testbench (A , B , D , BCIN , C , CARRYIN , clk , PCIN , OPMODE , CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP , RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP , M_tb , BCOUT_tb , P_tb , PCOUT_tb , CARRYOUT_tb , CARRYOUTF_tb );

initial begin 
	clk = 0;
	forever 
	#1 clk = ~clk;
end


initial begin
// 2.1. Verify Reset Operation 
	RSTA = 1 ;
	RSTB = 1 ;
	RSTC = 1 ;
	RSTCARRYIN = 1 ;
	RSTD = 1 ;
	RSTM = 1 ;
	RSTOPMODE = 1 ;
	RSTP = 1 ;

	repeat (15)begin
		A = $random ;
		B = $random ;
		D = $random ;
		BCIN = $random ;
		C = $random ;
		CARRYIN = $random ;
		PCIN = $random ;
		OPMODE = $random ;

		@(negedge clk )
		if(M_tb !== 0 || BCOUT_tb !== 0 || P_tb !== 0 || PCOUT_tb !== 0 || CARRYOUT_tb !== 0 || CARRYOUTF_tb !== 0 ) begin
			$display ("Error - Output is incorrect");
			$stop;
		end
	end

	RSTA = 0 ;
	RSTB = 0 ;
	RSTC = 0 ;
	RSTCARRYIN = 0 ;
	RSTD = 0 ;
	RSTM = 0 ;
	RSTOPMODE = 0 ;
	RSTP = 0 ;

	CEA = 1 ;
	CEB = 1 ;
	CEC = 1 ;
	CECARRYIN = 1 ;
	CED = 1 ;
	CEM = 1 ;
	CEOPMODE = 1 ;
	CEP = 1 ;

// 2.2. Verify DSP Path 1
	OPMODE = 8'b1101_1101 ;
	A = 20 ;
	B = 10 ;
	C = 350 ; 
	D = 25 ;
	BCIN = $random ;
	CARRYIN = $random ;
	PCIN = $random ;

	@(negedge clk)
	@(negedge clk)
	@(negedge clk)
	@(negedge clk)
	if(BCOUT_tb !== 'hf || M_tb !== 'h12c || P_tb !== PCOUT_tb || PCOUT_tb !== 'h32 || CARRYOUT_tb !== 0  || CARRYOUTF_tb !== 0)begin
		$display ("Error - Output is incorrect");
		$stop;
	end

// 2.3. Verify DSP Path 2
	OPMODE = 8'b00010000 ;
	BCIN = $random ;
	CARRYIN = $random ;
	PCIN = $random ;

	@(negedge clk)
	@(negedge clk)
	@(negedge clk)
	if(BCOUT_tb !== 'h23 || M_tb !== 'h2bc || P_tb !== PCOUT_tb || PCOUT_tb !== 0 || CARRYOUT_tb !== 0  || CARRYOUTF_tb !== 0)begin
		$display ("Error - Output is incorrect");
		$stop;
	end

// 2.4. Verify DSP Path 3
	OPMODE = 8'b00001010 ;
	BCIN = $random ;
	CARRYIN = $random ;
	PCIN = $random ;

	@(negedge clk)
	@(negedge clk)
	@(negedge clk)
	if(BCOUT_tb !== 'ha || M_tb !== 'hc8 || P_tb !== PCOUT_tb  || CARRYOUT_tb !== CARRYOUTF_tb)begin
		$display ("Error - Output is incorrect");
		$stop;
	end

// 2.5. Verify DSP Path 4
	OPMODE = 8'b10100111 ;
	A = 5 ;
	B = 6 ;
	PCIN = 3000 ;
	BCIN = $random ;
	CARRYIN = $random ;

	@(negedge clk)
	@(negedge clk)
	@(negedge clk)
	if(BCOUT_tb !== 'h6 || M_tb !== 'h1e || P_tb !== PCOUT_tb || PCOUT_tb !== 'hfe6fffec0bb1  || CARRYOUT_tb !== CARRYOUTF_tb 	|| CARRYOUTF_tb !== 0)begin
		$display ("Error - Output is incorrect");
		$display ("BCOUT_tb = %0h , M_tb = %0h , P_tb = %0h , PCOUT_tb = %0h , CARRYOUT_tb = %0h , CARRYOUTF_tb = %0h" , BCOUT_tb , M_tb , P_tb , PCOUT_tb , CARRYOUT_tb , CARRYOUTF_tb );

		$stop;
	end



$stop;
end
endmodule