library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--Create entity reg_10 which is a 10-bit register
entity reg_10 is
	Port ( Clk : in std_logic; -- Clock
		Reset : in std_logic; -- Asynchronous reset
		d_in : in std_logic_vector(9 downto 0); --parallel load value
		Load : in std_logic; --if load is high, parallel load D
		d_out : out std_logic_vector(9 downto 0)); --current value
														--of shifter
														--contents.
end reg_10;

--internal connections of reg_10
architecture Behavioral of reg_10 is
	signal reg_value: std_logic_vector(9 downto 0);
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
			reg_value <= "0000000000";

		elsif (rising_edge(Clk)) then	--if we don't reset and we're
											--at the rising edge of the
											--clock, do one of the 
											--following.

				if (Load = '1') then --If Load is high, 
				reg_value <= d_in;     --do a parallel load of D.

			else						--if it fails, the
				reg_value <= reg_value;		--the register doesn't
											--need to change, so
											--leave it alone.
			end if;
		end if;
	end process;

	--assign outputs
	d_out <= reg_value;

end Behavioral;
