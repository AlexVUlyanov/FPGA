module single_port_rom_phase_A
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=8)
(
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q
);

	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	initial
	begin
		$readmemb("rom_init_phase_A.txt", rom);
	end

	always @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule