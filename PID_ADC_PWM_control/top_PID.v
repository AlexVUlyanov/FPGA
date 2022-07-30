module  top_PID (
//system signals
input clk,                                        // clock signal
input rst_n,                                      // reset signal, active low
input [9:0] target,                               // target value
input [9:0] y,                                    // actual output value
input [3:0] kp,                                   // proportional coefficient
input [3:0] ki,                                   // integral coefficient
input [3:0] kd,                                   // differential coefficient
output wire signed [14:0] uk0                     // pid output value
);
 
 reg signed [9:0] i_target;
 reg signed [9:0] i_y;
 reg [3:0] i_kp;
 reg [3:0] i_ki;
 reg [3:0] i_kd;
 
 always @(*)
 begin
 i_target = target;
 i_y = y;
 i_kp = kp;
 i_ki = ki;
 i_kd = kd;
 end
 
wire	signed [9:0] ek0;                            // e(k)
wire	signed [9:0] ek1;                            // e(k-1)
wire	signed [9:0] ek2;                            // e(k-2)

error_calc error(.clk(clk),
				 .rst_n(rst_n),
				 .target(i_target),
				 .y(i_y),
				 .ek0(ek0),
				 .ek1(ek1),
				 .ek2(ek2)
	            );
 
 
 wire signed [14:0] d_uk;                          // pid increment
 
incre_value incre_value_demo(.ek0(ek0),
							 .ek1(ek1),
							 .ek2(ek2),
							 .kp(i_kp),
							 .ki(i_ki),
							 .kd(i_kd),
							 .d_uk(d_uk)
				             );
 
pid_value pid_value_demo(.clk(clk),
						 .rst_n(rst_n),
						 .d_uk(d_uk),
						 .uk0(uk0)
				        );
 
endmodule