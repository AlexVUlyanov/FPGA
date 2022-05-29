module ROMRead #(parameter NumberPoint = 100)
(
	output reg [(NumberPoint-1):0] q,
	input clk 
);

reg [NumberPoint-1:0]count=0;

always @(posedge clk)
begin
		if (count >= (NumberPoint-1))
		begin
		count <= 0;
		end
			else 
			begin
			count <= count + 1; 
			end
q <= count;
end
	
endmodule
