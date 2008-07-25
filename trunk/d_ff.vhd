library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--this is a positive edge triggered D-type flip flop.
entity d_ff is
	Port(	clk		: in std_logic;
			reset	: in std_logic;
			d		: in std_logic;
			q		: out std_logic);
end d_ff;

architecture Behavioral of d_ff is

begin

	out_Q : process(clk, reset, d) is
	begin
		if (reset = '1') then
			q <= '0';
	--the value of the flip flop's output q will only be updated when
		--the clock is on the rising edge.
		elsif (rising_edge(clk)) then
			q <= d;
		end if;
	end process;

end Behavioral;
