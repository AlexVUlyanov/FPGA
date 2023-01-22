module PWM_mod(

input clk,reset,

input [23:0]Ua,
input [23:0]Ub,
input [23:0]Uc,


output outUA_P,
output outUA_N,

output outUB_P,
output outUB_N,

output outUC_P,
output outUC_N
				
);

reg        [22:0] const_step     = 23'h0001C2;// 0.10986328125 шаг
reg        [22:0] count 		   = 23'h22BF10; // инициализация 555.94140625
reg		         temp_sign 		= 1'b1; // инициализация минуса по умолчанию начинаем с -555.94140625
reg 			      count_up 	   = 1'b0; // считать вверх 1 / низ 0
reg			[1:0] zerro_detect	= 2'b0; // детекция пересечения 0 - середины 136

wire        [22:0] w_count;
wire		   [23:0] w_triangl_out;

/* test 
wire [23:0]Ua = 24'b00001001011_011000000110;
wire [23:0]Ub = 24'b10001001011_011000000110;
wire [23:0]Uc = 24'b00001000100_101111001010;
*/

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

reg r_outUA_P;
reg r_outUA_N;
reg r_outUB_P;
reg r_outUB_N;
reg r_outUC_P;
reg r_outUC_N;

always @(Ua, w_triangl_out)
begin
r_outUA_P = Ua > w_triangl_out;
r_outUA_N = ~r_outUA_P;
end

always @(Ub, w_triangl_out)
begin
r_outUB_P = Ub > w_triangl_out;
r_outUB_N = ~r_outUB_P;
end

always @(Uc, w_triangl_out)
begin
r_outUC_P = Uc > w_triangl_out;
r_outUC_N = ~r_outUC_P;
end

// выхорды ШИМ c защитой от сквозных токов //

wire delay_PWM_A_outP;
wire delay_PWM_A_outN;

wire delay_PWM_B_outP;
wire delay_PWM_B_outN;

wire delay_PWM_C_outP;
wire delay_PWM_C_outN;

delays_N_clock_shift_reg #(.N(35)) delay_AP_PWM_chanal (.in(r_outUA_P), .clk(clk), .reset(reset), .out(delay_PWM_A_outP));
delays_N_clock_shift_reg #(.N(35)) delay_AN_PWM_chanal (.in(r_outUA_N), .clk(clk), .reset(reset), .out(delay_PWM_A_outN));

delays_N_clock_shift_reg #(.N(35)) delay_BP_PWM_chanal (.in(r_outUB_P), .clk(clk), .reset(reset), .out(delay_PWM_B_outP));
delays_N_clock_shift_reg #(.N(35)) delay_BN_PWM_chanal (.in(r_outUB_N), .clk(clk), .reset(reset), .out(delay_PWM_B_outN));

delays_N_clock_shift_reg #(.N(35)) delay_CP_PWM_chanal (.in(r_outUC_P), .clk(clk), .reset(reset), .out(delay_PWM_C_outP));
delays_N_clock_shift_reg #(.N(35)) delay_CN_PWM_chanal (.in(r_outUC_N), .clk(clk), .reset(reset), .out(delay_PWM_C_outN));


assign outUA_P =  r_outUA_P & delay_PWM_A_outP;
assign outUA_N =  r_outUA_N & delay_PWM_A_outN;

assign outUB_P =  r_outUB_P & delay_PWM_B_outP;
assign outUB_N =  r_outUB_N & delay_PWM_B_outN;

assign outUC_P =  r_outUC_P & delay_PWM_C_outP;
assign outUC_N =  r_outUC_N & delay_PWM_C_outN;


// выход для тестов 
//assign outUC_N = w_triangl_out;       // счетчик выход
//assign outUC_P = w_count_up;   // проверка счета +1/-1
//assign outUB_P = w_temp_sign; // проверка знака 

endmodule

//----------------------------------------------------//


//------Формирователь мертвого времени ШИМ-------//

module delays_N_clock_shift_reg 
#(parameter N=35)
( 
	input in, clk, reset,
	output out
);

right_shift_register #(.N(N)) (.MSB_in(in), .clk(clk), .reset(reset), .LSB_out(out));

endmodule


module rights_shift_register 
#(parameter N=4)
(
	input MSB_in,
	input clk,reset,
	output reg [N-1:0] Data_out,
	output LSB_out
);

assign LSB_out = Data_out[0];

always @(posedge clk)
begin
	if (~reset)
		begin
			Data_out <= 0;
		end
			else
			begin
				Data_out <= {MSB_in, Data_out[N-1:1]};
			end
end
endmodule
