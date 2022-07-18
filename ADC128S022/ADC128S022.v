module ADC128S022 (
	output ADC_SCLK,
	output ADC_SADDR,          // MOSI
	output ADC_CS_N,          // CSn
	output UART_TX_PIN,      // GPIO_09
	input  ADC_SDAT,        // MISO
	input  CLOCK_50        // in clk 50MHz

);

wire [7:0] in_adc_chanel_read = 8'b0; // (default) IN0
wire [7:0] adc_RX_Byte;
wire ClkDev;
wire o_RX_DV;
wire Clk_uart;
reg uart_tx_en = 0;
wire tx_en;
reg [19:0]uart_count = 0;

reg [7:0] rx_byte_0 = 0;
wire [7:0] w_rx_byte_0; 
wire o_TX_Ready;

// controle register bit - in_adc_chanel_read
//---------------------------------------------
// Bit 7(MSB)		Bit 6		Bit 5		Bit 4		Bit 3		Bit 2		Bit 1		Bit 0 (LSB)
//     X           X        ADD2     ADD1     ADD0     X        X        X
//           IN0              0        0        0      (default)
//           IN1              0        0        1
//           IN2              0        1        0
//           IN3              0        1        1
//           IN4              1        0        0
//           IN5              1        0        1
//           IN6              1        1        0
//           IN7              1        1        1

// ADC - SPI

clock_divider #(.M(4)) (.clock_out(ClkDev), .clk_in(CLOCK_50));


spi_master
#(.SPI_MODE(0), .CLKS_PER_HALF_BIT(4))
  (
   // Control/Data Signals,
   .i_Rst_L(1'b1),                          // FPGA Reset
   .i_Clk(CLOCK_50),                       // FPGA Clock
   
   // TX (MOSI) Signals
   .i_TX_Byte(in_adc_chanel_read),        // Byte to transmit on MOSI
   .i_TX_DV(ClkDev),                     // Data Valid Pulse with i_TX_Byte
   .o_TX_Ready(o_TX_Ready),             // Transmit Ready for next byte
   
   // RX (MISO) Signals
   .o_RX_DV(o_RX_DV),                 // Data Valid pulse (1 clock cycle)
   .o_RX_Byte(adc_RX_Byte),          // Byte received on MISO

   // SPI Interface
   .o_SPI_Clk(ADC_SCLK),
   .i_SPI_MISO(ADC_SDAT),
   .o_SPI_MOSI(ADC_SADDR)
   );
	
assign ADC_CS_N = 1'b0;

always @(posedge o_RX_DV)
begin
	rx_byte_0 <= adc_RX_Byte;
end 

assign w_rx_byte_0 = rx_byte_0;

// UART - send data //

uart_tx(
   .clk(CLOCK_50),                                  // Top level system clock input.
   .resetn(1'b1),                                  // Asynchronous active low reset.
   .uart_txd(UART_TX_PIN),                        // UART transmit pin.
   //.uart_tx_busy,                              // Module busy sending previous item.
   .uart_tx_en(tx_en),                          // Send the data on uart_tx_data
   .uart_tx_data(w_rx_byte_0)                  // The data to be sent
);


clock_divider #(.M(20)) (.clock_out(Clk_uart), .clk_in(CLOCK_50));

// UART uart_tx_en pin controle 

always @(posedge Clk_uart)
begin
	uart_count <= uart_count + 1;
	if (uart_count < 500000)
	begin
		uart_tx_en <= 0;
	end
		else
		begin
		if (uart_count > 500000)
		begin
		uart_tx_en <= 1;
		uart_count <= 0;
		end
		end
end

assign tx_en = uart_tx_en;

endmodule 




