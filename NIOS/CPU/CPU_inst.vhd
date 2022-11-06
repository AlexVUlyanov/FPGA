	component CPU is
		port (
			clk_clk    : in  std_logic                    := 'X'; -- clk
			led_export : out std_logic_vector(1 downto 0)         -- export
		);
	end component CPU;

	u0 : component CPU
		port map (
			clk_clk    => CONNECTED_TO_clk_clk,    -- clk.clk
			led_export => CONNECTED_TO_led_export  -- led.export
		);

