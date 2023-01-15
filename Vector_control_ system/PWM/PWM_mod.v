module PWM_mod(

input clk,

input [23:0]Ua,
input [23:0]Ub,
input [23:0]Uc,

output outUA_P,
output outUA_N,

output outUB_P,
output outUB_N,

output outUC_P,
output [23:0] outUC_N
				
);


reg        [23:0] const_step     = 23'h0001C2;// 0.10986328125 шаг
reg        [22:0] count 		   = 23'h22BF10; // инициализация 555.94140625
reg		         temp_sign 		= 1'b1; // инициализация минуса по умолчанию начинаем с -555.94140625
reg 			      count_up 	   = 1'b0; // считать вверх 1 / низ 0
reg			[1:0] zerro_detect	= 2'b0; // детекция пересечения 0 - середины 136

wire        [22:0] w_count;
wire		   [23:0] w_triangl_out;

// проверка нуля и знака 
wire [1:0] w_zerro_detect;
wire w_temp_sign, w_count_up;

assign w_zerro_detect = zerro_detect;
assign w_temp_sign    = temp_sign;


always @(posedge clk)
begin
	if (w_count == 23'h000088)
		begin
			temp_sign <= ~temp_sign; // добавляем знак
		end
end

assign w_count = count;
assign w_count_up = count_up;

// счетчик инкримент / дикремент
always @ (posedge clk)
begin
	count <= count + (count_up ? const_step : -const_step);
	 if ( count == 23'h000088) // определение нуля счетчика середина 136
		begin
		 count <= 23'h00024A;
		 count_up <= 1'b1;
		end
			else
				begin
					if (count == 23'h22BF10)
						begin
							count_up <= 1'b0;
							count <= 23'h22BD4E;
						end
				end
		end	
// формиование треугольника
assign w_triangl_out = {w_temp_sign,w_count};       // счетчик выход добовляем контокенацией знак
// компораторы > сравнение сигнала треугольника (опорный) с Uа,Ub,Uc

// выход для тестов 
assign outUC_N = w_triangl_out;       // счетчик выход
assign outUC_P = w_count_up;   // проверка счета +1/-1
assign outUB_P = w_temp_sign; // проверка знака 

endmodule

//----------------------------------------------------//
