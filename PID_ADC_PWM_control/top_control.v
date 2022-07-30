module top_control ( 
input  CLOCK_50,              // 50 MHz Clock ref
input  ADC_SDAT,              // SPI ADC MISO
output ADC_CS_N,              // SPI ADC nCS
output ADC_SADDR,             // SPI ADC MOSI
output ADC_SCLK,              // SPI ADC SCK
output GPIO_00,               // PID out PWM
output [7:0] LED
);




//////-----ADC-SPI-----//////
wire ClkDev;
wire [7:0] in_adc_chanel_read = 8'b0;         // (default) IN0
wire o_RX_DV;
wire o_TX_Ready;
wire [7:0] adc_RX_Byte;

reg [7:0] count_byte  = 0;
reg [7:0] rx_byte_MSB = 0;
reg [7:0] rx_byte_LSB = 0;

assign ADC_CS_N = 1'b0;
clock_divider #(.M(4)) (.clock_out(ClkDev), .clk_in(CLOCK_50));

spi_master
#(.SPI_MODE(0), .CLKS_PER_HALF_BIT(4))
  (
   // Control/Data Signals,
   .i_Rst_L(1'b1),                          // FPGA Reset
   .i_Clk(CLOCK_50),                        // FPGA Clock
   
   // TX (MOSI) Signals
   .i_TX_Byte(in_adc_chanel_read),          // Byte to transmit on MOSI
   .i_TX_DV(ClkDev),                        // Data Valid Pulse with i_TX_Byte
   .o_TX_Ready(o_TX_Ready),                 // Transmit Ready for next byte
   
   // RX (MISO) Signals
   .o_RX_DV(o_RX_DV),                       // Data Valid pulse (1 clock cycle)
   .o_RX_Byte(adc_RX_Byte),                 // Byte received on MISO

   // SPI Interface
   .o_SPI_Clk(ADC_SCLK),
   .i_SPI_MISO(ADC_SDAT),
   .o_SPI_MOSI(ADC_SADDR)
   );

/// --- RX MSB and LSB byte --- ///
always @(posedge o_RX_DV)
begin
if (count_byte == 0)
begin
rx_byte_MSB <= adc_RX_Byte;
end
end

always @(posedge o_RX_DV)
begin
count_byte <= count_byte + 1;
if (count_byte == 1)
begin
rx_byte_LSB <= adc_RX_Byte;
count_byte <= 0;
end
end

always @(posedge ADC_SCLK)
begin
ADC_Data <= {rx_byte_MSB,rx_byte_LSB};
end

reg  [15:0] ADC_Data;
wire [15:0] w_ADC_DAta;

assign w_ADC_DAta = ADC_Data;

///-----PID-----////

wire signed [14:0] uk0;

top_PID (
//system signals
.clk(CLOCK_50),                                   // clock signal
.rst_n(1'b1),                                     // reset signal, active low
.target(10'd1000),                                // target value 0.8 V
.y(w_ADC_DAta),                                   // actual output value
.kp(4'd10),                                       // proportional coefficient
.ki(4'd9),                                        // integral coefficient
.kd(4'd8),                                        // differential coefficient
.uk0(uk0)                                         // pid output value
);


//////----PWM-OUT----///////
PWM_PID #(.DataTopValue(32767), .DataWidth(15)) (  
.PWM_outP(GPIO_00), 
.data(uk0), 
.clk_in(CLOCK_50),
.enable(1'b1),
.reset(1'b0));

assign LED[0] = GPIO_00; // real PWM out LED indicate

endmodule 