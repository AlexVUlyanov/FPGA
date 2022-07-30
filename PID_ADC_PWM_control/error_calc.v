module error_calc (
//system signals
	 input clk,                                       // clock signal
	 input rst_n,                                     // reset signal, active low
	 input [9:0] target,                   // target value
	 input [9:0] y,                        // actual output value
	output wire signed [9:0] ek0,                // e(k)
	output  [9:0] ek1,              // e(k-1)
	output  [9:0] ek2               // e(k-2)
);

reg signed [9:0] i_target;
reg signed [9:0] i_y;
reg signed [9:0] o_ek1;
reg signed [9:0] o_ek2;

always @ (*) 
begin
i_target = target;
i_y = y;
o_ek1 = ek1;
o_ek2 = o_ek2;
end

assign ek0 = i_target - i_y;                             // calculate e(k)

always @ (posedge clk or negedge rst_n) begin
	 if(!rst_n) begin                                 // Initialize the error value
		o_ek1 <= 10'd0;
		o_ek2 <= 10'd0;
	 end 	
	 else begin
		 o_ek1 <= ek0;                                   // Delay one clock cycle to get e(k-1)
	 end	   
end
 
always @ (posedge clk ) begin
	 o_ek2 <= o_ek1;                                     // Delay one more clock cycle to get e(k-2)  
end

endmodule