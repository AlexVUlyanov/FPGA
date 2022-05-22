module Clock50Hz
(
	input clk,
	output outclok_dev
);

reg [31:0]count = 0;

always @(posedge clk)
begin
	count <= count + 1'b1;
	if (count >= (1000000-1))
	begin
		count <= 0;
	end
end

assign outclok_dev = (count < 500000) ? 1'b0:1'b1;

endmodule
