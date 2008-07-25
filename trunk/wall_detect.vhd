--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/17/2008                                                --
--  Design Name:    Wall/Trail Detector                                       --
--  Module Name:    wall_detect - Behavioral                                  --
--                                                                            --
--  Comments:                                                                 --
--    The wall detector checks to see if the light cycle is driving along a   --
--    wall or trail and sets the acceleration/deceleration accordingly. It    --
--    only checks the positions to the left and right of the light cycle      --
--    (relative to the direction the light cycle is moving) for calculating   --
--    the acceleration/deceleration. When driving next to a trail, the light  --
--    cycle will accelerate. When driving next to a wall, the light cycle     --
--    decelerate. When driving in between a wall and a trail, the two effects --
--    cancel each other and the light cycle will move at constant speed.      --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity wall_detect is
	Port( DIR               : in std_logic_vector(1 downto 0);
	  --Adjacent positions
	    --above
	      play_above_red    : in std_logic_vector(9 downto 0);
	      play_above_green  : in std_logic_vector(9 downto 0);
	      play_above_blue   : in std_logic_vector(9 downto 0);
	   --below
	      play_below_red    : in std_logic_vector(9 downto 0);
	      play_below_green  : in std_logic_vector(9 downto 0);
	      play_below_blue   : in std_logic_vector(9 downto 0);
	   --right
	      play_right_red    : in std_logic_vector(9 downto 0);
	      play_right_green  : in std_logic_vector(9 downto 0);
	      play_right_blue   : in std_logic_vector(9 downto 0);
	   --left
	      play_left_red     : in std_logic_vector(9 downto 0);
	      play_left_green   : in std_logic_vector(9 downto 0);
	      play_left_blue    : in std_logic_vector(9 downto 0);

	      accel             : out std_logic_vector(1 downto 0)
	    );
end wall_detect;

architecture Behavioral of wall_detect is

	component color_accel is
		Port( RED   : in std_logic_vector(9 downto 0);
		      GREEN : in std_logic_vector(9 downto 0);
		      BLUE  : in std_logic_vector(9 downto 0);

		      accel : out std_logic;
		      decel : out std_logic
		    );
	end component;

signal acceleratey, deceleratey : std_logic;
signal acceleratei, deceleratei : std_logic;
signal ac, dc                   : std_logic;
signal redy, greeny, bluey      : std_logic_vector(9 downto 0);
signal redi, greeni, bluei      : std_logic_vector(9 downto 0);

begin

	colorizer1 : color_accel
		Port Map( RED   => redy,
		          GREEN => greeny,
		          BLUE  => bluey,

		          accel => acceleratey,
		          decel => deceleratey
		        );

	colorizer2 : color_accel
		Port Map( RED   => redi,
		          GREEN => greeni,
		          BLUE  => bluei,

		          accel => acceleratei,
		          decel => deceleratei
		        );

	color_chooser : process(DIR,play_right_red,play_right_green,play_right_blue,play_left_red,play_left_green,play_left_blue,play_above_red,play_above_green,play_above_blue,play_below_red,play_below_green,play_below_blue)
	begin
		--if we are going up or down.
		if((DIR="11") OR (DIR="00")) then
			redy    <= play_right_red;
			greeny  <= play_right_green;
			bluey   <= play_right_blue;

			redi    <= play_left_red;
			greeni  <= play_left_green;
			bluei   <= play_left_blue;
		else
			redy    <= play_above_red;
			greeny  <= play_above_green;
			bluey   <= play_above_blue;

			redi    <= play_below_red;
			greeni  <= play_below_green;
			bluei   <= play_below_blue;
		end if;
	end process;

	accel_proc : process(ac,dc,acceleratey, acceleratei, deceleratey, deceleratei)
	begin
		ac <= acceleratey AND acceleratei;
		dc <= deceleratey AND deceleratei;

		if((ac='0') AND (dc='0')) then
			accel <= "11";
		else
			accel <= dc & ac;
		end if;
	end process;
end Behavioral;
