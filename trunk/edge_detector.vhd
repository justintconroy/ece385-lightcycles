library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--This is an edge detector. It detects the falling edge of a signal. The clock
	--must change faster than the signal. When the signal a goes from high to
	--low, the first d_ff will have a low value for one clock pulse before the
	--second d_ff changes. Edge outputs a 1 when this happens. To change this
	--to a rising edge detector, you just need to switch the order of q1 and q2.
entity edge_detector is
	Port(	clk		: in std_logic;
			a		: in std_logic;
			edge	: out std_logic);
end entity;

architecture Behavioral of edge_detector is

	component d_ff is
		Port(	clk		: in std_logic;
				reset	: in std_logic;
				d		: in std_logic;
				q		: out std_logic);
	end component d_ff;

	signal q1, q2, q1_h : std_logic;
-- q1 is the output of the first D flip-flop 
-- and q2 is the output of the second D flip-flop.
-- If q1 is low and q2 is high, it means it is falling edge.
begin

	q1_h	<= not(q1);
	DA : d_ff
		Port map(	clk		=> clk,
					reset	=> '0',
					d		=> a,
					q		=> q1);
	DB : d_ff
		Port map(	clk		=> clk,
					reset	=> '0',
					d		=> q1,
					q		=> q2);

	edge	<= q2 AND q1_h;

end Behavioral;
