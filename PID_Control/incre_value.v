module  incre_value(
	input [9:0] ek0,                                             // e(k)
	input [9:0] ek1,                                             // e(k-1)
	input [9:0] ek2,                                             // e(k-2)
	input [3:0] kp,                                              // proportional coefficient
	input [3:0] ki,                                              // integral coefficient
	input [3:0] kd,                                              // differential coefficient
	output wire signed [14:0] d_uk                               // pid increment
);
 
 reg signed [9:0] i_ek0;
 reg signed [9:0] i_ek1;
 reg signed [9:0] i_ek2;
 
 reg [3:0] i_kp;
 reg [3:0] i_ki;
 reg [3:0] i_kd;
 
 always @(*)
 begin
 
 i_ek0 =  ek0;
 i_ek1 =  ek1;
 i_ek2 =  ek2;
 
 i_kp =  kp;
 i_ki =  ki;
 i_kd =  kd;
 
 end
 
 
 assign d_uk = i_kp*(i_ek0 -i_ek1) + i_ki*i_ek0 + i_kd*((i_ek0-i_ek1)-(i_ek1-i_ek2));   // calculate pid increment
 
endmodule