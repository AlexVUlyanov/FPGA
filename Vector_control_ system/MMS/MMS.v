module MMS (
	input      [23:0] UA,UB,UC,
	output 	  [23:0] outUA,outUB,outUC

);

reg [23:0] const_1 =  24'b000000000001_001001111001; // 1.15473
reg [23:0] const_2 =  24'b100000000000_100000000000; // -0.5


wire [23:0] mulUA, mulUB, mulUC, add_minmax, mul_minmax;
wire [23:0] mulU_A, mulU_B, mulU_C;

reg [23:0] UAB, UBC, U_AB, U_BC;
reg [23:0] MAX_U, MIN_U;



qmult qmultA (.i_multiplicand(UA), .i_multiplier(const_1), .o_result(mulUA));
qmult qmultB (.i_multiplicand(UB), .i_multiplier(const_1), .o_result(mulUB));
qmult qmultC (.i_multiplicand(UC), .i_multiplier(const_1), .o_result(mulUC));

assign mulU_A = mulUA;
assign mulU_B = mulUB;
assign mulU_C = mulUC;

always @(*)
begin
if (mulU_A >= mulU_B)
begin
	UAB = mulU_A;
end
	else
		begin
			UAB = mulU_B;
		end
if (mulU_B >= mulU_C)
begin
	UBC = mulU_B;
end 
	else 
		begin
		UBC = mulU_C;
		end
if (UAB >= UBC)
begin
	MAX_U = UAB;
end	
	else
		begin
			MAX_U = UBC;
		end
end

always @(*)
begin
if (mulU_A <= mulU_B)
begin
	U_AB = mulU_A;
end
	else
		begin
			U_AB = mulU_B;
		end
if (mulU_B <= mulU_C)
begin
	U_BC = mulU_B;
end 
	else 
		begin
		U_BC = mulU_C;
		end
if (U_AB <= U_BC)
begin
	MIN_U = U_AB;
end	
	else
		begin
			MIN_U = U_BC;
		end 
end 


qadd add_min_max (.a(MAX_U), .b(MIN_U), .c(add_minmax));

qmult qmult_min_max (.i_multiplicand(add_minmax), .i_multiplier(const_2), .o_result(mul_minmax));

qadd add_min_max_A (.a(mul_minmax), .b(mulU_A), .c(outUA));
qadd add_min_max_B (.a(mul_minmax), .b(mulU_B), .c(outUB));
qadd add_min_max_C (.a(mul_minmax), .b(mulU_C), .c(outUC));


endmodule




module qmult #(
	parameter Q = 12,
	parameter N = 24
	)
	(
	 input			[N-1:0]	i_multiplicand,
	 input			[N-1:0]	i_multiplier,
	 output			[N-1:0]	o_result
	 );
	 	
	reg [2*N-1:0]	r_result;		
	reg [N-1:0]		r_RetVal;
	
//--------------------------------------------------------------------------------
	assign o_result = r_RetVal;	
//---------------------------------------------------------------------------------
	always @(i_multiplicand, i_multiplier)	begin						
		r_result <= i_multiplicand[N-2:0] * i_multiplier[N-2:0];	 																																										
		end
	
	always @(r_result) begin													
		r_RetVal[N-1] <= i_multiplicand[N-1] ^ i_multiplier[N-1];	
		r_RetVal[N-2:0] <= r_result[N-2+Q:Q];								 
																						
		end

endmodule


module qadd #(

	parameter Q = 12,
	parameter N = 24
	)
	(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
    );

reg [N-1:0] res;

assign c = res;

always @(a,b) begin

	if(a[N-1] == b[N-1]) begin						
		res[N-2:0] = a[N-2:0] + b[N-2:0];		
		res[N-1] = a[N-1];							 
															
															  
		end												
	
	else if(a[N-1] == 0 && b[N-1] == 1) begin		
		if( a[N-2:0] > b[N-2:0] ) begin				
			res[N-2:0] = a[N-2:0] - b[N-2:0];		
			res[N-1] = 0;									
			end
		else begin											
			res[N-2:0] = b[N-2:0] - a[N-2:0];		
			if (res[N-2:0] == 0)
				res[N-1] = 0;								
			else
				res[N-1] = 1;								
			end
		end
	else begin												
		if( a[N-2:0] > b[N-2:0] ) begin					
			res[N-2:0] = a[N-2:0] - b[N-2:0];			
			if (res[N-2:0] == 0)
				res[N-1] = 0;									
			else
				res[N-1] = 1;									
			end
		else begin												
			res[N-2:0] = b[N-2:0] - a[N-2:0];			
			res[N-1] = 0;										
			end
		end
	end
endmodule
