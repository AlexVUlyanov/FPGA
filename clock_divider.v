module clock_divider #(parameter M = 2) 
(
	output clock_out,
	input clk_in
);

reg [M-1:0] counter = 0;


	always @(posedge clk_in)
		begin
			counter <= counter + 1;
				if (counter >= (M-1))
					begin
						counter <= 0;
					end
		end

		assign clock_out = (counter < M/2) ? 1'b0 : 1'b1; 
		
endmodule