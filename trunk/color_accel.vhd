--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/17/2008                                                --
--  Design Name:    Acceleration Decision Control Structure                   --
--  Module Name:    color_accel - Behavioral                                  --
--                                                                            --
--  Comments:                                                                 --
--    This unit takes in a color (via 3 10 bit vectors representing RGB) and  --
--    outputs an acceleration vector (accel) that defines if the light cycle  --
--    should accelerate, decelerate or remain at the same speed. It decides   --
--    this based on the color input to it. If the color is black, we remain   --
--    at the same speed. If it is white, we are next to a wall, so decelerate.--
--    If it is any other color, we are next to a trail, so accelerate.        --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity color_accel is
	Port( RED   : in std_logic_vector(9 downto 0);
	      GREEN : in std_logic_vector(9 downto 0);
	      BLUE  : in std_logic_vector(9 downto 0);

	      accel : out std_logic;
	      decel : out std_logic
	    );
end entity;

architecture Behavioral of color_accel is

begin

	colorify : process(RED, GREEN, BLUE)
        begin
		accel <= '1';
		decel <= '1';
		if((RED="0000000000") AND (GREEN="0000000000") AND (BLUE="0000000000")) then
			accel <= '1'; --both at 1 means constant speed.
			decel <= '1';
		elsif((RED="1111111111") AND (GREEN="1111111111") AND (BLUE="1111111111")) then
			accel <= '0'; --a white wall means decelerate
			decel <= '1';
		else
			accel <= '1'; --a trail of any other color means accelerate
			decel <= '0';
		end if;
	end process;

end Behavioral;
