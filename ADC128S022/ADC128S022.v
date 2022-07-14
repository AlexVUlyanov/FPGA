module ADC128S022 (
	output o_SPI_Clk,
	output o_SPI_MOSI,
	output [7:0] adc_RX_Byte,
	output adc_cs_n,
	output o_RX_DV,
	output o_TX_Ready,
	input i_Rst_L,
	input  [7:0] in_adc_chanel_read,
	input  i_SPI_MISO,
	input  clk
);

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

spi_master
#(.SPI_MODE(0), .CLKS_PER_HALF_BIT(4))
  (
   // Control/Data Signals,
   .i_Rst_L(i_Rst_L),     // FPGA Reset
   .i_Clk(clk),       // FPGA Clock
   
   // TX (MOSI) Signals
   .i_TX_Byte(in_adc_chanel_read),        // Byte to transmit on MOSI
   .i_TX_DV(i_TX_DV),          // Data Valid Pulse with i_TX_Byte
   .o_TX_Ready(o_TX_Ready),       // Transmit Ready for next byte
   
   // RX (MISO) Signals
   .o_RX_DV(o_RX_DV),     // Data Valid pulse (1 clock cycle)
   .o_RX_Byte(adc_RX_Byte),   // Byte received on MISO

   // SPI Interface
   .o_SPI_Clk(o_SPI_Clk),
   .i_SPI_MISO(i_SPI_MISO),
   .o_SPI_MOSI(o_SPI_MOSI)
   );

assign adc_cs_n = 1'b1;
assign i_TX_DV = 1'b1;

endmodule 