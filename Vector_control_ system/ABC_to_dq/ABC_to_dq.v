module ABC_to_dq(

input [23:0] A,
input [23:0] B,
input [23:0] C,

input  [23:0] CosQ,
input  [23:0] SinQ,

output  [23:0] d,
output  [23:0] q

);

 wire [23:0] w_min_C;
_qmult mul_min_one(.i_multiplicand(C),.i_multiplier(24'b100000000001_000000000000),.o_result(w_min_C)); // -1*C

 wire [23:0] w_add_1_out;
_qadd add_1 (.a(B), .b(w_min_C), .c(w_add_1_out)); // B-C

wire [23:0] w_mul_const_out;
_qmult mul_const(.i_multiplicand(w_add_1_out),.i_multiplier(24'b000000000000_100100111100),.o_result(w_mul_const_out)); // (B-C)*0.57735027

wire [23:0] w_mul_1_out;
_qmult mul_1(.i_multiplicand(w_mul_const_out),.i_multiplier(SinQ),.o_result(w_mul_1_out)); // ((B-C)*0.57735027) * SinQ

wire [23:0] w_mul_2_out;
_qmult mul_2(.i_multiplicand(A),.i_multiplier(CosQ),.o_result(w_mul_2_out)); // A*CosQ

wire [23:0] w_mul_3_out;
_qmult mul_3(.i_multiplicand(CosQ),.i_multiplier(w_mul_const_out),.o_result(w_mul_3_out)); // CosQ*((B-C)*0.57735027)

wire [23:0] w_mul_4_out;
_qmult mul_4(.i_multiplicand(A),.i_multiplier(SinQ),.o_result(w_mul_4_out)); // A * SinQ

wire [23:0] w_d;
_qadd add_2 (.a(w_mul_1_out), .b(w_mul_2_out), .c(w_d));

wire [23:0] w_mul_4_min_out;
_qmult mul_4_min(.i_multiplicand(w_mul_4_out),.i_multiplier(24'b100000000001_000000000000),.o_result(w_mul_4_min_out));

wire [23:0] w_q;
_qadd add_3 (.a(w_mul_3_out), .b(w_mul_4_min_out), .c(w_q));

assign d = w_d;
assign q = w_q;

endmodule

//-----MUL-------//

module _qmult #(
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

module _qadd #(

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
