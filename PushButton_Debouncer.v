module PushButton_Debouncer (
input clk,
input PB, // "PB" - это прерывистый, асинхронный с clk, активный низкий кнопочный сигнал

// синхронизированные выходы с тактовым сигналом

output reg PB_state, //1 до тех пор, пока кнопка активна (нажата)
output PB_down, // 1 в течение одного такта, когда кнопка опускается (т.е. просто нажата)
output PB_up // 1 в течение одного такта, когда кнопка поднимается (т.е. только что отпущена)
);

// Сначала используем два триггера для синхронизации сигнала PB с тактовым доменом "clk"

reg PB_sync_0;
reg PB_sync_1;

always@(posedge clk)
begin
	PB_sync_0 <= ~PB; // инверсия PB для активного high
end
	
always@(posedge clk)
begin
	PB_sync_1 <= PB_sync_0;
end
	
	

// Когда кнопка нажата или отпущена, мы увеличиваем счетчик
// Счетчик должен быть увеличен до максимума, прежде чем мы решим, что состояние кнопки изменилось

// Сделамем счетчик
reg [19:0] PB_cnt;

wire PB_idle;
wire PB_cnt_max;

assign PB_idle = (PB_state == PB_sync_1);
assign PB_cnt_max = &PB_cnt; 

always @(posedge clk)
	if (PB_idle)
	begin
		PB_cnt <= 0;
	end
			else 
			begin
				PB_cnt <= PB_cnt + 1'd1;
				if (PB_cnt_max)
				begin
					PB_state <= ~PB_state;
				end
			end
assign PB_down = ~PB_idle & PB_cnt_max & ~PB_state;
assign PB_up   = ~PB_idle & PB_cnt_max &  PB_state;

endmodule 