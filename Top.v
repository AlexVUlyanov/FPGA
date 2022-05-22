module Top
(
	//////////// CLOCK //////////
	input 		          		CLOCK_50, // 50Mhz in clock on board
	//////////// LED //////////
	output		     [7:0]		LED,
	//////////// KEY //////////
	input 		     [1:0]		KEY,
	//////////// SW //////////
	input 		     [3:0]		SW,
	/////////// I2C ///////////
	inout								SDA,
	output 							SCL,
	////////// SPI ///////////
	output 					  ADC_CS_N,
	output 					  ADC_SADDR,
	output                 ADC_SCLK,
	input 					  ADC_SDAT,
	//////////////////////////
	output 						GPIO_00
);

wire clock_5000Hz;
wire clock_50Hz;
wire [99:0]outCount_ReadROM;
wire [99:0]outNumberSineA;


Clock5000Hz (.clk(CLOCK_50),.outclok_dev(clock_5000Hz));
Clock50Hz (.clk(CLOCK_50), .outclok_dev(clock_50Hz));
////////////////////////////////////////////////////////////////////

ROMRead #(.NumberPoint(100))(.q(outCount_ReadROM), .clk(clock_5000Hz));

single_port_rom #(.DATA_WIDTH(7), .ADDR_WIDTH(7)) ( .addr(outCount_ReadROM), .clk(clock_5000Hz), .q(outNumberSineA));

PWM #(100, 7) ( .PWM_outP(LED[0]), .PWM_outN(LED[1]),
					 .data(outNumberSineA), .clk_in((CLOCK_50)),
					 .enable(SW[0]), .reset(SW[1]));


endmodule
