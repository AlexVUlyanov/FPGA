module PWM #(parameter DataTopValue = 100, DataWidth = 7) 
(  output  PWM_outP, 
	output  PWM_outN,
	input  [DataWidth-1:0]data, 
	input clk_in,
	input enable,
	input reset);

wire clk_dev;
reg [DataWidth-1:0] cnt;

reg temp_PWM_outP;
reg temp_PWM_outN;

binary_counter (.clk(clk_in), .outclok_dev(clk_dev));

always @(posedge clk_dev)
begin

	cnt <= cnt + 1;
	
	if (cnt >= DataTopValue )
		begin
			cnt <= 0;
		end
end

	always @(*)
		begin
			if (!enable || reset)
			begin
					temp_PWM_outP = 1'b0;
					temp_PWM_outN = 1'b0;
			end
				else
				begin
								if (data > cnt)
								begin
										temp_PWM_outP = 1'b1;
										temp_PWM_outN = ~temp_PWM_outP;
								end
									else
									begin
										temp_PWM_outP = 1'b0;
										temp_PWM_outN = ~temp_PWM_outP;
									end
				end
		end

wire delay_PWM_outP;
wire delay_PWM_outN;

delay_N_clock_shift_reg #(.N(35)) delay_P_PWM_chanal (.in(temp_PWM_outP), .clk(clk_in), .reset(1'b1), .out(delay_PWM_outP));
delay_N_clock_shift_reg #(.N(35)) delay_N_PWM_chanal(.in(temp_PWM_outN), .clk(clk_in), .reset(1'b1), .out(delay_PWM_outN));

////add deadTime out 680ns, PWM - 2.46kHz////

assign PWM_outP = temp_PWM_outP & delay_PWM_outP;
assign PWM_outN = temp_PWM_outN & delay_PWM_outN;

endmodule

module binary_counter
(
	input clk,
	output outclok_dev
);

reg [15:0]count = 0;

always @(posedge clk)
begin
	count <= count + 1'b1;
	if (count >= (400-1)) //341
	begin
		count <= 0;
	end
end

assign outclok_dev = (count < 200) ? 1'b0:1'b1; // 171

endmodule

//////////////////DeadTime controle//////////////

module delay_N_clock_shift_reg 
#(parameter N=35)
( 
	input in, clk, reset,
	output out
);

right_shift_register #(.N(N)) (.MSB_in(in), .clk(clk), .reset(reset), .LSB_out(out));

endmodule


module right_shift_register 
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
