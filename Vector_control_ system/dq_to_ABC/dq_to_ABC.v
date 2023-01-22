module dq_to_ABC (

input [23:0] CosQ,
input [23:0] SinQ,
input [23:0] d,
input [23:0] q,

output [23:0] A,
output [23:0] B,
output [23:0] C

);

endmodule



//-----MUL-------//

module qmult_ #(
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

//-----ADD-----//

module qadd_ #(

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