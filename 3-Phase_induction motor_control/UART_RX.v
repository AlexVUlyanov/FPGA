module UART_RX #(parameter CLKS_PER_BIT = 5208) ( 
								// 50Mhz/9600 = 5208
	input i_Clock,
	input i_Rx_Serial,
	output o_Rx_DV,
	output [7:0] o_Rx_Byte );

parameter s_IDLE            = 3'b000;
parameter s_RX_START_BIT    = 3'b001;
parameter s_RX_DATA_BITS    = 3'b010;
parameter s_RX_STOP_BIT     = 3'b011;
parameter s_CLEANUP         = 3'b100;

  reg           r_Rx_Data_R = 1'b1;
  reg           r_Rx_Data   = 1'b1;
   
  reg [7:0]     r_Clock_Count = 0;
  reg [2:0]     r_Bit_Index   = 0; // всего 8 bit
  reg [7:0]     r_Rx_Byte     = 0;
  reg           r_Rx_DV       = 0;
  reg [2:0]     r_SM_Main     = 0;

// классическое устранение метастабильности использем два регистра
always @(posedge i_Clock)
	begin
		r_Rx_Data_R <= i_Rx_Serial;
		r_Rx_Data   <= r_Rx_Data_R;
	end


always @(posedge i_Clock)
    begin
       
      case (r_SM_Main)
        s_IDLE :
          begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (r_Rx_Data == 1'b0)          // Start bit - найден
              r_SM_Main <= s_RX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
          end
         
// Проверьте середину начального бита, чтобы убедиться, что он все еще низкий
        s_RX_START_BIT :
          begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // сбросил счетчик, нашел середину
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= s_IDLE;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_START_BIT;
              end
          end // case: s_RX_START_BIT
         
         
// Подождите CLOCKS_PER_BIT-1 тактовых циклов для выборки последовательных данных
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                 
                // Проверьте, получили ли мы все биты
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS

// Receive Stop bit.  Stop bit = 1
        s_RX_STOP_BIT :
          begin
            // Подождите CLOCKS_PER_BIT-1 тактовых циклов для завершения стоп-бита
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_STOP_BIT;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // case: s_RX_STOP_BIT
     
         
// остаться 1 clock
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;
          end
default :
          r_SM_Main <= s_IDLE;
         
      endcase
    end   
   
assign o_Rx_DV   = r_Rx_DV;
assign o_Rx_Byte = r_Rx_Byte;

endmodule 