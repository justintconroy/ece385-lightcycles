--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/17/2008                                                --
--  Design Name:    Crash Detector                                            --
--  Module Name:    crash_detect - Behavioral                                 --
--                                                                            --
--  Comments:                                                                 --
--    The crash detector checks all of the pixels in between current position --
--    and next position to determine if there are any obstacles present. If   --
--    there is any color other than black within the area in that the light   --
--    cycle will move, the crash detector reports a crash to game control and --
--    stops reporting new positions. Otherwise, it relays the new position to --
--    the color mapper to be drawn on the screen.                             --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity crash_detect is
	Port( clk           : in std_logic;
	      reset         : in std_logic;
	      next_X_pos    : in std_logic_vector(9 downto 0);
	      next_Y_pos    : in std_logic_vector(9 downto 0);
	      play_Size     : in std_logic_vector(9 downto 0);
	      DIR           : in std_logic_vector(1 downto 0);
	      beginning     : in std_logic;

	      DrawX         : in std_logic_vector(9 downto 0);
	      DrawY         : in std_logic_vector(9 downto 0);

	      RED           : in std_logic_vector(9 downto 0);
	      GREEN         : in std_logic_vector(9 downto 0);
	      BLUE          : in std_logic_vector(9 downto 0);

	      Xpos          : out std_logic_vector(9 downto 0);
	      Ypos          : out std_logic_vector(9 downto 0);
	      crashed       : out std_logic;
	      black_OUT     : out std_logic;
	      
	      in_start      : out std_logic;
	      in_check      : out std_logic;
	      in_crash      : out std_logic
	    );
end crash_detect;

architecture Behavioral of crash_detect is

type ctrl_state is (START,CHECK,CRASH);
signal state,next_state : ctrl_state;

signal crashing : std_logic;
signal curr_X   : std_logic_vector(9 downto 0);
signal curr_Y   : std_logic_vector(9 downto 0);
signal black    : std_logic;

--signal DrawX   : integer;
--signal DrawY   : integer;

constant UP     : std_logic_vector(1 downto 0) := "11";
constant DOWN   : std_logic_vector(1 downto 0) := "00";
constant RIGHT  : std_logic_vector(1 downto 0) := "01";
constant LEFT   : std_logic_vector(1 downto 0) := "10";

constant X_MAX  : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(447,10);
constant X_MIN  : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(191,10);
constant Y_MAX  : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(417,10);
constant Y_MIN  : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(161,10);

begin
	
--	DrawX <= to_integer(unsigned(DrawX));
--	DrawY <= to_integer(unsigned(DrawY));

	cell_black : process(RED,GREEN,BLUE)
	begin
		black <= '0';
		if((RED /= "0000000000") AND (GREEN /= "0000000000") AND (BLUE /= "0000000000")) then
			black <= '1';
		end if;
	end process;

	get_next_state : process(reset, clk)
	begin
		if(reset ='1') then
			state <= START;
		elsif(rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;

	assign_next_state : process(state,crashing,beginning)
	begin
		case state is
			when START =>
				if(beginning = '1') then
					next_state <= CHECK;
				else
					next_state <= START;
				end if;
			when CHECK =>
				if(crashing = '1') then
					next_state <= CRASH;
				else
					next_state <= CHECK;
                                end if;
			when CRASH =>
				next_state <= CRASH;
		end case;
	end process;

	crashilize : process(state,crashing,next_X_pos,next_Y_pos,DIR,DrawX,DrawY,curr_X,curr_Y,play_Size,RED,GREEN,BLUE,black)

	begin
	crashing <= '0';
	crashed  <= '0';
	in_start <= '0';
	in_check <= '0';
	in_crash <= '0';



		case state is
			when START =>
				curr_X <= next_X_pos;
				curr_Y <= next_Y_pos;
				in_start <= '1';
			when CHECK =>
				in_check <= '1';
--				if((next_X_pos >= X_MAX) OR (next_X_pos <= X_MIN) OR (next_Y_pos >= Y_MAX) OR (next_Y_pos <= Y_MIN)) then
--					crashing <= '1';
--				else
--				case DIR is
--					when LEFT =>
--						if((DrawX<=(curr_X-play_Size-1))AND(DrawX>=next_X_pos-play_Size))then 
--							if((DrawY<=(curr_Y+play_Size))AND(DrawY>=(curr_Y-play_Size))) then
--								if(black = '0') then
--									crashing <= '1';
--								else
--									null;
--								end if;
--							end if;
--						end if;
--					when RIGHT =>
--						if((DrawX>=(curr_X+play_Size+1))AND(DrawX<=next_X_pos+play_Size))then 
--							if((DrawY<=(curr_Y+play_Size))AND(DrawY>=(curr_Y-play_Size))) then
--								if(black = '0') then
--									crashing <= '1';
--								else
--									null;
--								end if;
--							end if;
--						end if;
--					when UP =>
--						if((DrawY<=(curr_Y-play_Size-1))AND(DrawY>=next_Y_pos-play_Size))then 
--							if((DrawX<=(curr_X+play_Size))AND(DrawX>=(curr_X-play_Size))) then
--								if(black = '0') then
--									crashing <= '1';
--								else
--									null;
--								end if;
--							end if;
--						end if;
--					when DOWN =>
--						if((DrawY<=(curr_Y+play_Size+1))AND(DrawY>=next_Y_pos+play_Size))then 
--							if((DrawX<=(curr_X+play_Size))AND(DrawX>=(curr_X-play_Size))) then
--								if(black = '0') then
--									crashing <= '1';
--								else
--									null;
--								end if;
--							end if;
--						end if;
--				end case;
--				end if;
			when CRASH =>
				crashed <= '1';
				in_crash <= '1';
		end case;
		if(crashing='0') then
			Curr_X <= next_X_pos;
			Curr_Y <= next_Y_pos;
		else
			Curr_X <= DrawX;
			Curr_Y <= DrawY;
		end if;
	end process;

	Xpos <= Curr_X;
	Ypos <= Curr_Y;
	
	black_OUT <= black;
end Behavioral;
