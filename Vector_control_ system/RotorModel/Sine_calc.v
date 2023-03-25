module Sine_calc(
input 	[23:0]	angle,
output	[23:0]	SinQ
);

wire	[23:0] y;
wire	[23:0] y2;
wire	[23:0] y3;
wire	[23:0] y5;
wire	[23:0] y7;

qmult_SN Y (.i_multiplicand(angle), .i_multiplier(24'b000000000000_101000101111), .o_result(y));
qmult_SN Y2 (.i_multiplicand(y), .i_multiplier(y), .o_result(y2));
qmult_SN Y3 (.i_multiplicand(y), .i_multiplier(y2), .o_result(y3));
qmult_SN Y5 (.i_multiplicand(y3), .i_multiplier(y2), .o_result(y5));
qmult_SN Y7 (.i_multiplicand(y5), .i_multiplier(y2), .o_result(y7));

wire	[23:0] sum1;
wire	[23:0] sum2;
wire	[23:0] sum3;
wire	[23:0] sum4;

qmult_SN SUM1 (.i_multiplicand(y), .i_multiplier(24'b000000000001_100100100001), .o_result(sum1));
qmult_SN SUM2 (.i_multiplicand(y3), .i_multiplier(24'b100000000000_101001010101), .o_result(sum2));
qmult_SN SUM3 (.i_multiplicand(y5), .i_multiplier(24'b000000000000_000101000110), .o_result(sum3));
qmult_SN SUM4 (.i_multiplicand(y7), .i_multiplier(24'b100000000000_000000010011), .o_result(sum4));

wire	[23:0] sum12;
qadd_SN SUM12 (.a(sum1), .b(sum2), .c(sum12));
wire	[23:0] sum123;
qadd_SN SUM123 (.a(sum12), .b(sum3), .c(sum123));
wire	[23:0] sum1234;
qadd_SN SUM1234 (.a(sum123), .b(sum4), .c(sum1234));

assign SinQ = sum1234;

endmodule

//-----MUL-------//
module qmult_SN #(
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

module qadd_SN #(
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
//-------DIV-------//
module qdiv_SN #(
	parameter Q = 12,
	parameter N = 24
	)
	(
	input 	[N-1:0] i_dividend,
	input 	[N-1:0] i_divisor,
	input 	i_start,
	input 	i_clk,
	output 	[N-1:0] o_quotient_out,
	output 	o_complete,
	output	o_overflow
	);
 
	reg [2*N+Q-3:0]	reg_working_quotient;	
	reg [N-1:0] 		reg_quotient;				
	reg [N-2+Q:0] 		reg_working_dividend;	
	reg [2*N+Q-3:0]	reg_working_divisor;		
	reg [N-1:0] 		reg_count; 		 											 											 																			 
	reg					reg_done;			
	reg					reg_sign;			
	reg					reg_overflow;		
 
	initial reg_done = 1'b1;				
	initial reg_overflow = 1'b0;			
	initial reg_sign = 1'b0;				
	initial reg_working_quotient = 0;	
	initial reg_quotient = 0;				
	initial reg_working_dividend = 0;	
	initial reg_working_divisor = 0;		
 	initial reg_count = 0; 		
	assign o_quotient_out[N-2:0] = reg_quotient[N-2:0];	
	assign o_quotient_out[N-1] = reg_sign;						
	assign o_complete = reg_done;
	assign o_overflow = reg_overflow;
	always @( posedge i_clk ) begin
		if( reg_done && i_start ) begin										
			reg_done <= 1'b0;															
			reg_count <= N+Q-1;											
			reg_working_quotient <= 0;									
			reg_working_dividend <= 0;									 
			reg_working_divisor <= 0;									 
			reg_overflow <= 1'b0;										
			reg_working_dividend[N+Q-2:Q] <= i_dividend[N-2:0];				
			reg_working_divisor[2*N+Q-3:N+Q-1] <= i_divisor[N-2:0];		
			reg_sign <= i_dividend[N-1] ^ i_divisor[N-1];		
			end 
		else if(!reg_done) begin
			reg_working_divisor <= reg_working_divisor >> 1;	
			reg_count <= reg_count - 1;								
			if(reg_working_dividend >= reg_working_divisor) begin
				reg_working_quotient[reg_count] <= 1'b1;										
				reg_working_dividend <= reg_working_dividend - reg_working_divisor;	
				end
			if(reg_count == 0) begin
				reg_done <= 1'b1;										
				reg_quotient <= reg_working_quotient;			
				if (reg_working_quotient[2*N+Q-3:N]>0)
					reg_overflow <= 1'b1;
					end
			else
				reg_count <= reg_count - 1;	
			end
		end
endmodule