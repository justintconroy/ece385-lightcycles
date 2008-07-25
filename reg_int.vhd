library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--Create entity reg_2 which is an 2-bit register
entity reg_int is
	Port( Clk : in std_logic; -- Clock
 	      Reset : in std_logic; -- Asynchronous reset
	      d_in : in integer;
	      Load : in std_logic;
	      d_out : out integer
        );
end reg_int;

--internal connections of reg_int
architecture Behavioral of reg_int is
	signal reg_value: integer;
begin
	operate_reg : process (Clk, Reset, Load)
	begin
		--When reset is high, all positions in the register should
			--be set to 0.
		if (Reset = '1') then
			reg_value <= 0;

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
