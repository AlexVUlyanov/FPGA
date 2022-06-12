module FreqControll
(
	input clk,
	input [7:0]comp, // Freq 1-50 Hz (49 = 50Hz, 0 = 1 Hz )
	output outclok_dev
);

reg 	[20:0]count = 0;
wire	[20:0]temp;
reg	[20:0]var = 0;
reg	[20:0]var_half = 0;

single_port_rom_freq (.addr(comp),.clk(clk),.q(temp));

always @(posedge clk)
begin
	var <= temp;
	var_half <= temp >> 1;
	count <= count + 1'b1;
	if (count >= (var-1))
	begin
		count <= 0;
	end
end

assign outclok_dev = (count == (var_half)) ? 1'b0:1'b1;

endmodule
