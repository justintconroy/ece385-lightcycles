library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--Create entity reg_11 which is an 11-bit shift register. When Shift_En is
	--high, the contents of the register will shift to the right (from
	--most significant bit to least) and the value of Shift_In will become
	--the new value of the most significant bit. The least significant bit
	--will be lost. Shift_Out is the value of the least significant bit.
	--When load is high, a parallel load will occur (at the next rising
	--clock edge) on all bits of the register: they will be replaced with D
entity reg_11 is
	Port ( Clk : in std_logic; -- Clock
		Reset : in std_logic; -- Asynchronous reset
		D : in std_logic_vector(10 downto 0); --parallel load value
		Shift_In : in std_logic; -- value to shift in from left
		Load : in std_logic; --if load is high, parallel load D
		Shift_En : in std_logic; --if shift_en is high, enable shifting
		Shift_Out : out std_logic; --the last bit in the shifter
		Data_Out : out std_logic_vector(10 downto 0)); --current value
														--of shifter
														--contents.
end reg_11;

--internal connections of reg_11
architecture Behavioral of reg_11 is
	signal reg_value: std_logic_vector(10 downto 0);
begin
	--begin new process.  The simulation output will change when
		--any of the ports listed in () after the word process
		--change values.  The actual FPGA will ignore that stuff 
		--and change whenever it feels like it.  It usually feels
		--like changing immediately after any input changes.
	operate_reg : process (Clk, Reset, Load, Shift_En, Shift_In)
	begin
		--When reset is high, all positions in the register should
			--be set to 0.
		if (Reset = '1') then
			reg_value <= "00000000000";

		elsif (rising_edge(Clk)) then	--if we don't reset and we're
											--at the rising edge of the
											--clock, do one of the 
											--following.

			if (Shift_En = '1') then	--first check if shift_en
											--is high. If it is, shift.
				reg_value <= Shift_In & reg_value(10 downto 1);

			elsif (Load = '1') then --if shift_en is low, next check
				reg_value <= D;			--to see if Load is high.  If it
										--is, do a parallel load of D.

			else						--if all else fails, the
				reg_value <= reg_value;		--the register doesn't
											--need to change, so
											--leave it alone.
			end if;
		end if;
	end process;

	--assign outputs
	Data_Out <= reg_value;
	Shift_Out <= reg_value(0);

end Behavioral;
