module FMS_M (
	input clock,
	input reset_n,
	input enable,
	input a,
   output [7:0]y
);
	parameter [2:0] S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
	reg [2:0] state, next_state;
	
	// Регистр состояния
	
always @ (posedge clock or negedge reset_n)
	if (! reset_n)
		begin
			state <= S0;
		end 
			else 
				begin 
						if (enable)
							begin
								state <= next_state;
								end
				end

// Комбинационная схема выбора следующего состояния
	
always @*
	case (state)
		S0:
			if (a)
				begin
					next_state = S1;
				end
				else
				begin
					next_state = S0;
				end
		S1:
			if (a)
				begin
					next_state = S2;
				end
				else
				begin
					next_state = S1;
				end
		S2:	
			if (a)
				begin
					next_state = S3;
				end
				else
				begin
					next_state = S2;
				end
		S3:	
			if (a)
				begin
					next_state = S4;
				end
				else
				begin
					next_state = S3;
				end
		S4:	
			if (a)
				begin
					next_state = S0;
				end
				else
				begin
					next_state = S4;
				end
	default:
		next_state = S0;
endcase

// комбинационная логика выход
	
	assign y[0] = (state == S1) ? 1 : 0;
	assign y[1] = (state == S2) ? 1 : 0;
	assign y[2] = (state == S3) ? 1 : 0;
	assign y[3] = (state == S4) ? 1 : 0;

endmodule


