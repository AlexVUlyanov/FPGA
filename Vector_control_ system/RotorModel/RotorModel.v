module RotorModel(
input					clk,
input 	[23:0]	Iq,
input 	[23:0]	Qr,
input 	[23:0]	Id,

output	[23:0]	SinQ,
output	[23:0]	CosQ

);



endmodule


module FieldCalc (

input clk,
input [23:0] Iq,
input [23:0] F,
input [23:0] Qr,

output [23:0] SinQ,
output [23:0] CosQ

);
wire [23:0] w_muleIq_out;
qmult_RM muleIq (.i_multiplicand(Iq), .i_multiplier(24'b000000000000_001001000001), .o_result(w_muleIq_out));
wire [23:0] w_addF_out;
qadd_RM addF (.a(F), .b(24'b000000000000_000000000001), .c(w_addF_out));
wire [23:0] w_div_out;
qdiv_RM div (.i_dividend(w_muleIq_out), .i_divisor(w_addF_out), .i_start(1'b1), .i_clk(clk), .o_quotient_out(w_div_out));
wire [23:0] w_integr_out;
Integrator integr (.clk(clk), .reset(1'b1), .in_integrator(w_div_out), .out_integrator(w_integr_out));
wire [23:0] w_muletQr_out;
qmult_RM muleQr (.i_multiplicand(Qr), .i_multiplier(24'b00000000001_000000000001), .o_result(w_muletQr_out));
wire [23:0] w_add_out;
qadd_RM add (.a(w_integr_out), .b(w_muletQr_out), .c(w_add_out));
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
qmult_RM mule2 (.i_multiplicand(F), .i_multiplier(24'b100000000001_101000110110), .o_result(w_mul_integral)); 
endmodule

//-------k/P----------//

module Integrator (
input 			 clk,
input		       reset,
input 	[23:0] in_integrator,
output 	[23:0] out_integrator
);

localparam k = 24'b000000000100_110001110110;
wire 	[23:0] w_D_out;
wire	[23:0] w_out_integrator;
wire [23:0] w_mult_k_out;
qmult_RM qmult_k(.i_multiplicand(in_integrator), .i_multiplier(k), .o_result(w_mult_k_out));
wire [23:0] w_add;
qadd_RM integral (.a(w_mult_k_out), .b(w_D_out), .c(w_add));
RisingEdge_DFlipFlop_SyncReset (.D(w_add), .clk(clk), .sync_reset(1'b0), .Q(w_D_out));
assign out_integrator = w_add;
endmodule
//-----D---------//
module RisingEdge_DFlipFlop_SyncReset(D,clk,sync_reset,Q);
input 		[23:0]	D;
input 					clk;
input 					sync_reset;
output reg	[23:0] 	Q;
always @(posedge clk) 
begin
 if(sync_reset==1'b1)
  Q <= 24'b000000000000_000000000000; 
 else 
  Q <= D; 
end 
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
//-------DIV-------//
module qdiv_RM #(
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