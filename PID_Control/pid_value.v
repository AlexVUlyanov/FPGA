module pid_value (
	//system signals
	 input clk,                   // clock signal
	 input rst_n,                 // reset signal, active low
	 input [14:0] d_uk,           // pid increment
	 output reg signed [14:0] uk0 // pid output value
);

reg signed [14:0] i_d_uk;
reg signed [14:0] uk1 = 15'd0;   // the value of u(k-1) at the previous moment

always @(*)
begin
 i_d_uk = d_uk;
end
 
always @ (d_uk) begin
 uk0 = uk1 + i_d_uk;         // calculate pid output value
 uk1 = uk0;                  // Register the value of u(k-1) at the previous moment    
end
 
endmodule