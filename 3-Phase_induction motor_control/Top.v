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
	output 						GPIO_00, GPIO_01, GPIO_03
);

wire clock_var;
wire [6:0]outCount_ReadROM;
wire [6:0]outNumberSineA;
wire [6:0]outNumberSineB;
wire [6:0]outNumberSineC;

wire [6:0]out_NumberSineA;
wire [6:0]out_NumberSineB;
wire [6:0]out_NumberSineC;

reg [6:0] FreqSet = 35;

FreqControll (.clk(CLOCK_50), .comp(FreqSet-1), .outclok_dev(clock_var));

Voltage (.clk(CLOCK_50),.PhaseA(outNumberSineA), .PhaseB(outNumberSineB), .PhaseC(outNumberSineC),
	.Freq(FreqSet),
	.outPhaseA(out_NumberSineA),
	.outPhaseB(out_NumberSineB),
	.outPhaseC(out_NumberSineC)
);

//////////////////////////////-SINE 3-phase//////////////////////////////////////

ROMRead #(.NumberPoint(100)) ROMRead (.q(outCount_ReadROM), .clk(clock_var));
/////PWM-Phase A////////
single_port_rom_phase_A #(.DATA_WIDTH(7), .ADDR_WIDTH(7))  PhaseA_ROM ( .addr(outCount_ReadROM), .clk(clock_var), .q(outNumberSineA));
PWM #(100, 7) PhaseA_PWM_out ( .PWM_outP(LED[0]), .PWM_outN(LED[1]),
					 .data(out_NumberSineA), .clk_in((CLOCK_50)),
					 .enable(SW[0]), .reset(SW[1]));
/////PWM-Phase B////////
single_port_rom_phase_B #(.DATA_WIDTH(7), .ADDR_WIDTH(7))  PhaseB_ROM ( .addr(outCount_ReadROM), .clk(clock_var), .q(outNumberSineB));
PWM #(100, 7) PhaseB_PWM_out ( .PWM_outP(LED[2]), .PWM_outN(LED[3]),
					 .data(out_NumberSineB), .clk_in((CLOCK_50)),
					 .enable(SW[0]), .reset(SW[1]));
/////PWM-Phase C////////
single_port_rom_phase_C #(.DATA_WIDTH(7), .ADDR_WIDTH(7))  PhaseC_ROM ( .addr(outCount_ReadROM), .clk(clock_var), .q(outNumberSineC));
PWM #(100, 7) PhaseC_PWM_out ( .PWM_outP(LED[4]), .PWM_outN(LED[5]),
					 .data(out_NumberSineC), .clk_in((CLOCK_50)),
					 .enable(SW[0]), .reset(SW[1]));


assign GPIO_00 = LED[0]; // Phase A_P
assign GPIO_01 = LED[2]; // Phase B_P
assign GPIO_03 = LED[4]; // Phase C_P

endmodule
