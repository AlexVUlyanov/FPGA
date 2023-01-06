module Top_sys (
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
	output 					  		ADC_CS_N,
	output 					  		ADC_SADDR,
	output                 		ADC_SCLK,
	input 					  		ADC_SDAT,
	//////////////////////////
	output 							GPIO_00, 
										GPIO_01, 
										GPIO_03,
	//////////////////////////
	input 							in_UART_RX // GPIO_05
);
	
	
	
endmodule 