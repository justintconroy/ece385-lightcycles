--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/17/2008                                                --
--  Design Name:    Next Wall                                                 --
--  Module Name:    next_wall - Behavioral                                    --
--                                                                            --
--  Comments:                                                                 --
--                                                                            --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity next_wall is
	Port( RED   : in std_logic_vector(9 downto 0);
	      GREEN : in std_logic_vector(9 downto 0);
	      BLUE  : in std_logic_vector(9 downto 0);

	      wall : out std_logic
	    );
end next_wall;

architecture Behavioral of next_wall is

begin

	frontwall : process(RED, GREEN, BLUE)
        begin
		if((RED="0000000000") AND (GREEN="0000000000") AND (BLUE="0000000000")) then
			wall <= '0';
		else
			wall <= '1';
		end if;
	end process;

end Behavioral;
