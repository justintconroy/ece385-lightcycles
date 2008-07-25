library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--Create entity reg_10 which is a 10-bit register
entity reg is
	Port ( Clk : in std_logic; -- Clock
		Reset : in std_logic; -- Asynchronous reset
		din : in std_logic; --parallel load value
		Load : in std_logic; --if load is high, parallel load D
		dout : out std_logic); --current value
														--of shifter
														--contents.
end reg;

--internal connections of reg
architecture Behavioral of reg is
	signal reg_value: std_logic;
begin
	--begin new process.  The simulation output will change when
		--any of the ports listed in () after the word process
		--change values.  The actual FPGA will ignore that stuff 
		--and change whenever it feels like it.  It usually feels
		--like changing immediately after any input changes.
	operate_reg : process (Clk, Reset, Load)
	begin
		--When reset is high, all positions in the register should
			--be set to 0.
		if (Reset = '1') then
			reg_value <= '0';

		elsif (rising_edge(Clk)) then	--if we don't reset and we're
											--at the rising edge of the
											--clock, do one of the 
											--following.

				if (Load = '1') then --If Load is high, 
				reg_value <= din;     --do a parallel load of D.

			else						--if it fails, the
				reg_value <= reg_value;		--the register doesn't
											--need to change, so
											--leave it alone.
			end if;
		end if;
	end process;

	--assign outputs
	dout <= reg_value;

end Behavioral;
