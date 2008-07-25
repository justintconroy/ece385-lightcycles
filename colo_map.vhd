--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/17/2008                                                --
--  Design Name:    Color Mapper                                              --
--  Module Name:    colo_map - Behavioral                                     --
--                                                                            --
--  Comments:                                                                 --
--    This unit controls the direction and speed of a Player's light cycle.   --
--     It is made up of two entities each designated for controlling the      --
--     player's speed or velocity.                                            --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity colo_map is
	Port( Clk                : in std_logic;
	      Reset              : in std_logic;

	      play1_Y_pos        : in integer;
          play1_X_pos        : in integer;
          play1_Size         : in integer;

	      play2_Y_pos        : in integer;
          play2_X_pos        : in integer;
          play2_Size         : in integer;

	   --This is used for the VGA controller to query what color
	     --each pixel should be.
	      DrawX              : in std_logic_vector(9 downto 0);
	      DrawY              : in std_logic_vector(9 downto 0);

	   --This is the color of the pixel at (DrawX,DrawY).
	      Red                : out std_logic_vector(9 downto 0);
	      Green              : out std_logic_vector(9 downto 0);
	      Blue               : out std_logic_vector(9 downto 0);

	  --Adjacent positions
	    --above
	      play1_above_red    : out std_logic_vector(9 downto 0);
	      play1_above_green  : out std_logic_vector(9 downto 0);
	      play1_above_blue   : out std_logic_vector(9 downto 0);

	      play2_above_red    : out std_logic_vector(9 downto 0);
	      play2_above_green  : out std_logic_vector(9 downto 0);
	      play2_above_blue   : out std_logic_vector(9 downto 0);
	   --below
	      play1_below_red    : out std_logic_vector(9 downto 0);
	      play1_below_green  : out std_logic_vector(9 downto 0);
	      play1_below_blue   : out std_logic_vector(9 downto 0);

	      play2_below_red    : out std_logic_vector(9 downto 0);
	      play2_below_green  : out std_logic_vector(9 downto 0);
	      play2_below_blue   : out std_logic_vector(9 downto 0);
	   --right
	      play1_right_red    : out std_logic_vector(9 downto 0);
	      play1_right_green  : out std_logic_vector(9 downto 0);
	      play1_right_blue   : out std_logic_vector(9 downto 0);

	      play2_right_red    : out std_logic_vector(9 downto 0);
	      play2_right_green  : out std_logic_vector(9 downto 0);
	      play2_right_blue   : out std_logic_vector(9 downto 0);
	   --left
	      play1_left_red     : out std_logic_vector(9 downto 0);
	      play1_left_green   : out std_logic_vector(9 downto 0);
	      play1_left_blue    : out std_logic_vector(9 downto 0);

	      play2_left_red     : out std_logic_vector(9 downto 0);
	      play2_left_green   : out std_logic_vector(9 downto 0);
	      play2_left_blue    : out std_logic_vector(9 downto 0)
            );
end colo_map;

architecture Behavioral of colo_map is

constant X_size : integer := 639;
constant Y_size : integer := 479;

--Color of Player 1 currently set to blue 
constant PLAYER1_COLOR_RED   : std_logic_vector(9 downto 0) :="0000000000";
constant PLAYER1_COLOR_GREEN : std_logic_vector(9 downto 0) :="0000000000";
constant PLAYER1_COLOR_BLUE  : std_logic_vector(9 downto 0) :="1111111111";

--Color of Player 2 currently set to red 
constant PLAYER2_COLOR_RED   : std_logic_vector(9 downto 0) :="1111111111";
constant PLAYER2_COLOR_GREEN : std_logic_vector(9 downto 0) :="0000000000";
constant PLAYER2_COLOR_BLUE  : std_logic_vector(9 downto 0) :="0000000000";

type arena_type is array (integer range 0 to X_size, integer range 0 to Y_size) of std_logic_vector(9 downto 0);
signal arena_array_red   : arena_type;
signal arena_array_green : arena_type;
signal arena_array_blue  : arena_type;

signal draw_X, draw_Y    : integer;

begin

	draw_X <= to_integer(unsigned(DrawX));
	draw_Y <= to_integer(unsigned(DrawY));

 --Left Border of Arena
	mapper : process(Reset)
	
	begin
		if (Reset = '1') then

		 --Left Border of Arena
			for i in 4 downto 0 loop
				for j in 479 downto 99 loop
					arena_array_red(i,j)    <= "1111111111";
					arena_array_green(i,j)  <= "1111111111";
					arena_array_blue(i,j)   <= "1111111111";
				end loop;
			end loop;

		 --Right Border of Arena
			for i in 639 downto 635 loop
				for j in 479 downto 99 loop
					arena_array_red(i,j)    <= "1111111111";
					arena_array_green(i,j)  <= "1111111111";
					arena_array_blue(i,j)   <= "1111111111";
				end loop;
			end loop;

		 --Bottom Border of Arena
			for i in 634 downto 5 loop
				for j in 479 downto 475 loop
					arena_array_red(i,j)    <= "1111111111";
					arena_array_green(i,j)  <= "1111111111";
					arena_array_blue(i,j)   <= "1111111111";
				end loop;
			end loop;

		 --Top Border of Arena
			for i in 634 downto 5 loop
				for j in 103 downto 99 loop
					arena_array_red(i,j)    <= "1111111111";
					arena_array_green(i,j)  <= "1111111111";
					arena_array_blue(i,j)   <= "1111111111";
				end loop;
			end loop;

		 --Center of Arena
			for i in 634 downto 5 loop
				for j in 474 downto 104 loop
					arena_array_red(i,j)    <= "0000000000";
					arena_array_green(i,j)  <= "0000000000";
					arena_array_blue(i,j)   <= "0000000000";
				end loop;
			end loop;

		 --Heads Up Display, Background
			for i in 639 downto 0 loop
				for j in 98 downto 0 loop
					arena_array_red(i,j)    <= "0000000000";
					arena_array_green(i,j)  <= "0000000000";
					arena_array_blue(i,j)   <= "0000000000";
				end loop;
			end loop;

		else

		 --Set player 1 position color
			if ((draw_X >= play1_X_pos-(play1_Size)) AND (draw_X <= play1_X_pos+(play1_Size))) then
				if((draw_Y >= play1_Y_pos-(play1_Size)) AND (draw_Y <= play1_Y_pos+(play1_Size))) then
					arena_array_red(draw_X,draw_Y)    <= PLAYER1_COLOR_RED;
					arena_array_green(draw_X,draw_Y)  <= PLAYER1_COLOR_GREEN;
					arena_array_blue(draw_X,draw_Y)   <= PLAYER1_COLOR_BLUE; 
				end if;
			end if;

		 --Set player 2 position color
			if ((draw_X >= play2_X_pos-(play2_Size)) AND (draw_X <= play2_X_pos+(play2_Size))) then
				if((draw_Y >= play2_Y_pos-(play2_Size)) AND (draw_Y <= play2_Y_pos+(play2_Size))) then
					arena_array_red(draw_X,draw_Y)    <= PLAYER2_COLOR_RED;
					arena_array_green(draw_X,draw_Y)  <= PLAYER2_COLOR_GREEN;
					arena_array_blue(draw_X,draw_Y)   <= PLAYER2_COLOR_BLUE; 
				end if;
			end if;
		end if;
	end process;


	Red   <= arena_array_red(draw_X,draw_Y);
	Green <= arena_array_green(draw_X,draw_Y);
	Blue  <= arena_array_blue(draw_X,draw_Y);

	    --above
	      play1_above_red   <= arena_array_red  (play1_X_pos,play1_Y_pos-((play1_Size)-3));
	      play1_above_green <= arena_array_green(play1_X_pos,play1_Y_pos-((play1_Size)-3));
	      play1_above_blue  <= arena_array_blue (play1_X_pos,play1_Y_pos-((play1_Size)-3));

	      play2_above_red   <= arena_array_red  (play2_X_pos,play2_Y_pos-((play2_Size)-3));
	      play2_above_green <= arena_array_green(play2_X_pos,play2_Y_pos-((play2_Size)-3));
	      play2_above_blue  <= arena_array_blue (play2_X_pos,play2_Y_pos-((play2_Size)-3));
	   --below
	      play1_below_red   <= arena_array_red  (play1_X_pos,play1_Y_pos+((play1_Size)+3));
	      play1_below_green <= arena_array_green(play1_X_pos,play1_Y_pos+((play1_Size)+3));
	      play1_below_blue  <= arena_array_blue (play1_X_pos,play1_Y_pos+((play1_Size)+3));

	      play2_below_red   <= arena_array_red  (play2_X_pos,play2_Y_pos+((play2_Size)+3));
	      play2_below_green <= arena_array_green(play2_X_pos,play2_Y_pos+((play2_Size)+3));
	      play2_below_blue  <= arena_array_blue (play2_X_pos,play2_Y_pos+((play2_Size)+3));
	   --right
	      play1_right_red   <= arena_array_red  (play1_X_pos+((play1_Size)+3),play1_Y_pos);
	      play1_right_green <= arena_array_green(play1_X_pos+((play1_Size)+3),play1_Y_pos);
	      play1_right_blue  <= arena_array_blue (play1_X_pos+((play1_Size)+3),play1_Y_pos);

	      play2_right_red   <= arena_array_red  (play2_X_pos+((play2_Size)+3),play2_Y_pos);
	      play2_right_green <= arena_array_green(play2_X_pos+((play2_Size)+3),play2_Y_pos);
	      play2_right_blue  <= arena_array_blue (play2_X_pos+((play2_Size)+3),play2_Y_pos);
	   --left
	      play1_left_red    <= arena_array_red  (play1_X_pos-((play1_Size)-3),play1_Y_pos);
	      play1_left_green  <= arena_array_green(play1_X_pos-((play1_Size)-3),play1_Y_pos);
	      play1_left_blue   <= arena_array_blue (play1_X_pos-((play1_Size)-3),play1_Y_pos);

	      play2_left_red    <= arena_array_red  (play2_X_pos-((play2_Size)-3),play2_Y_pos);
	      play2_left_green  <= arena_array_green(play2_X_pos-((play2_Size)-3),play2_Y_pos);
	      play2_left_blue   <= arena_array_blue (play2_X_pos-((play2_Size)-3),play2_Y_pos);

End Behavioral;
