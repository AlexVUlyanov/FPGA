module RotorModel(
input					clk,
input 	[23:0]	Iq,
input 	[23:0]	Qr,
input 	[23:0]	Id,

output	[23:0]	SinQ,
output	[23:0]	CosQ

);

// FlowCalc flow_ (.reset(1'b1), .Id(Id), .F(SinQ));


endmodule


module FlowCalc(
input				 reset,
input 	[23:0] Id,
output 	[23:0] F
);

wire [23:0] w_mule1_out;
qmult_RM mule1 (.i_multiplicand(Id), .i_multiplier(24'b000000000000_001001000001), .o_result(w_mule1_out));

wire [23:0] w_sub1;
wire [23:0] w_mul_integral;

qadd_RM sub1 (.a(w_mule1_out), .b(w_mul_integral), .c(w_sub1));

Integrator integrator1 (.clk(clk), .reset(1'b1), .in_integrator(w_sub1), .out_integrator(F));

qmult_RM mule2 (.i_multiplicand(F), .i_multiplier(24'b100000000001_101000110110), .o_result(w_mul_integral)); // F*(-1.6384181)

endmodule


module Integrator (
input 			 clk,
input		       reset,
input 	[23:0] in_integrator,
output 	[23:0] out_integrator
);


reg [23:0] r_out_integrator;
wire [23:0] w_out_integrator;

qadd_RM integral (.a(in_integrator), .b(r_out_integrator), .c(w_out_integrator));

always @(posedge clk)
	begin
		if (!reset)
			begin
				r_out_integrator <= 0;
			end
				else
					begin
						r_out_integrator <= w_out_integrator;
					end
	end
	
assign out_integrator = r_out_integrator;

endmodule


//-----MUL-------//

module qmult_RM #(
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

module qadd_RM #(

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