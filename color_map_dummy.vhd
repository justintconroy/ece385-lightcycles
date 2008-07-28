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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity color_map_dummy is
	Port( Clk                : in std_logic;
	      Reset              : in std_logic;

	      play1_Y_pos        : in std_logic_vector(9 downto 0);
	      play1_X_pos        : in std_logic_vector(9 downto 0);
	      play1_Size         : in std_logic_vector(9 downto 0);

	      play2_Y_pos        : in std_logic_vector(9 downto 0);
	      play2_X_pos        : in std_logic_vector(9 downto 0);
	      play2_Size         : in std_logic_vector(9 downto 0);

	      play1_next_X_pos   : in std_logic_vector(9 downto 0);
	      play1_next_Y_pos   : in std_logic_vector(9 downto 0);

	      play2_next_X_pos   : in std_logic_vector(9 downto 0);
	      play2_next_Y_pos   : in std_logic_vector(9 downto 0);

	      play1_DIR          : in std_logic_vector(1 downto 0);
	      play2_DIR          : in std_logic_vector(1 downto 0);

	      play1_current_speed: in std_logic_vector(9 downto 0);
	      play2_current_speed: in std_logic_vector(9 downto 0);

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
	      play2_left_blue    : out std_logic_vector(9 downto 0);

	      play1_wall_front   : out std_logic;
	      play2_wall_front   : out std_logic;

	      play1_Grid_X_Out   : out std_logic_vector(7 downto 0);
	      play1_Grid_Y_Out   : out std_logic_vector(7 downto 0)
        );
end color_map_dummy;

architecture Behavioral of color_map_dummy is

	component reg_int is
		Port( Clk    : in std_logic;
		      Reset  : in std_logic;
		      d_in   : in integer;
		      Load   : in std_logic;
		      d_out  : out integer
		    );
	end component;

constant X_size         : integer := 64; --79;
constant Y_size         : integer := 64; --59;

constant ARENA_X_MIN    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(191,10);
constant ARENA_X_MAX    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(447,10);
constant ARENA_Y_MIN    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(161,10);
constant ARENA_Y_MAX    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(417,10);
constant HUD_MAX        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR( 99,10);

constant SCREEN_X_MIN   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(  0,10);
constant SCREEN_X_MAX   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(639,10);
constant SCREEN_Y_MIN   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(  0,10);
constant SCREEN_Y_MAX   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(479,10);


--colors
--constant BLACK          : std_logic_vector(1 downto 0) :="00";
--constant REDc           : std_logic_vector(1 downto 0) :="01";
--constant BLUEc          : std_logic_vector(1 downto 0) :="10";
--constant WHITE          : std_logic_vector(1 downto 0) :="11";
constant BLACK          : std_logic := '0';
constant BLUEc          : std_logic := '1';

--Color of Player 1 currently set to blue 
constant PLAYER1_COLOR  : std_logic := BLUEc;

--Color of Player 2 currently set to not(red) 
constant PLAYER2_COLOR  : std_logic := BLUEc; --REDc;

constant MAX_SPEED      : integer := 10;

constant UP             : std_logic_vector(1 downto 0) := "11";
constant DOWN           : std_logic_vector(1 downto 0) := "00";
constant RIGHT          : std_logic_vector(1 downto 0) := "01";
constant LEFT           : std_logic_vector(1 downto 0) := "10";

type arena_type is array (integer range 0 to X_size, integer range 0 to Y_size) of std_logic;
signal cell_color       : arena_type;

type ctrl_state is (A,B);
signal state,next_state : ctrl_state;

signal Grid_X           : integer range 0 to 639;
signal Grid_Y           : integer range 0 to 479;

signal GridX, GridY     : std_logic_vector(9 downto 0);

signal play1_on         : std_logic;
signal play2_on         : std_logic;

signal load_cell        : std_logic;
signal new_color        : std_logic;

constant play1_Size_int : integer := 1;
constant play2_Size_int : integer := 1;

--signal play1_wall_f     : std_logic_vector(9 downto 0);
--signal play2_wall_f     : std_logic_vector(9 downto 0);

signal play1_X          : integer range -1 to 65;
signal play1_Y          : integer range -1 to 65;
signal play2_X          : integer range -1 to 65;
signal play2_Y          : integer range -1 to 65;

signal play1_check_X    : integer range -1 to 65;
signal play1_check_Y    : integer range -1 to 65;
signal play2_check_X    : integer range -1 to 65;
signal play2_check_Y    : integer range -1 to 65;

signal temp1            : integer range 0 to MAX_SPEED;
signal temp1_in         : integer range 0 to MAX_SPEED;
signal load_temp1       : std_logic;
signal play1_Grid_X     : integer range -1 to 65;
signal play1_Grid_Y     : integer range -1 to 65;


begin

	GridX        <= (DrawX - ARENA_X_MIN);
	GridY        <= (DrawY - ARENA_Y_MIN);

	Grid_X       <= CONV_INTEGER(unsigned(GridX(9 downto 2)));
	Grid_Y       <= CONV_INTEGER(unsigned(GridY(9 downto 2)));

	play1_X      <= CONV_INTEGER(unsigned(GridX-play1_X_pos));
	play1_Y      <= CONV_INTEGER(unsigned(GridY-play1_Y_pos));
	play2_X      <= CONV_INTEGER(unsigned(GridX-play2_X_pos));
	play2_Y      <= CONV_INTEGER(unsigned(GridY-play2_Y_pos));

	play1_Grid_X <= CONV_INTEGER(signed(play1_X_pos(9 downto 2) - ARENA_X_MIN(9 downto 2)));
	play1_Grid_Y <= CONV_INTEGER(signed(play1_Y_pos(9 downto 2) - ARENA_Y_MIN(9 downto 2)));

	temp_reg_1 : reg_int
	Port Map( Clk    => Clk,
	          Reset  => Reset,
	          d_in   => temp1_in,
	          Load   => load_temp1,
	          d_out  => temp1
	        );


--	colors : process(Grid_X,Grid_Y,cell_color)
--	begin
--		case cell_color(Grid_X,Grid_Y) is
--			when BLACK =>
--				red    <= "0000000000";
--				green  <= "0000000000";
--				blue   <= "0000000000";
--			when REDc =>
--				red    <= "1111111111";
--				green  <= "0000000000";
--				blue   <= "0000000000";
--			when BLUEc =>
--				red    <= "0000000000";
--				green  <= "0000000000";
--				blue   <= "1111111111";
--			when WHITE =>
--				red    <= "1111111111";
--				green  <= "1111111111";
--				blue   <= "1111111111";
--		end case;
--	end process;

	play1 : process(DrawX,DrawY,play1_X_pos,play1_Y_pos,play1_Size)
	begin
	 --Set player 1 position color
		if ((DrawX >= (play1_X_pos-play1_Size)) AND (DrawX <= (play1_X_pos+play1_Size))AND (DrawY >= (play1_Y_pos-play1_Size)) AND (DrawY <= (play1_Y_pos+play1_Size))) then
			play1_on <= '1';
		else
			play1_on <= '0';
		end if;
	end process;
	
	play2 : process(DrawX,DrawY,play2_X_pos,play2_Y_pos,play2_Size)
	begin
	 --Set player 2 position color
		if ((DrawX >= (play2_X_pos-play2_Size)) AND (DrawX <= (play2_X_pos+play2_Size))AND (DrawY >= (play2_Y_pos-play2_Size)) AND (DrawY <= (play2_Y_pos+play2_Size))) then
			play2_on <= '1';
		else
			play2_on <= '0';
		end if;
	end process;

	--some sort of process for filling the array
	cell_fill : process(play1_on,play2_on)
	begin
		load_cell <= '0';
		new_color <= BLACK;
		if(play1_on = '1') then
			new_color  <= PLAYER1_COLOR;
			load_cell  <= '1';

		elsif(play2_on = '1') then
			new_color  <= PLAYER2_COLOR;
			load_cell  <= '1';
		end if;
	end process;


	--process for filling the array, register style!
	cell : process(Reset,Clk,load_cell,new_color,cell_color)
	begin
		if (Reset = '1') then
			for i in X_size downto 0 loop
				for j in Y_Size downto 0 loop
					cell_color(i,j) <= '0';
				end loop;
			end loop;
		elsif (rising_edge(Clk)) then
			if (load_cell = '1') then 
				cell_color(Grid_X,Grid_Y) <= new_color;
			else
				cell_color(Grid_X,Grid_Y) <= cell_color(Grid_X,Grid_Y);
			end if;
		end if;
	end process;

	--maps out the HUD, arena, and filler stuff to the VGA controller
	mapper : process(Reset,Grid_X,Grid_Y,DrawX,DrawY,play1_on,play2_on,cell_color)
	begin
		--default
		RED   <= "0000000000";
		GREEN <= "0000000000";
		BLUE  <= "0000000000";

		--top area (HUD)
		if ((DrawY <= HUD_MAX) and (DrawY >= SCREEN_Y_MIN)) then 
			RED   <= "0000000000";
			GREEN <= "0000000000";
			BLUE  <= "0000000000";
		--top border of arena
		elsif ((DrawY <= ARENA_Y_MIN ) and (DrawY >= HUD_MAX)) then 
			RED   <= "1111111111";
			GREEN <= "1111111111";
			BLUE  <= "1111111111";
		--middle area
		elsif ((DrawY <= ARENA_Y_MAX ) and (DrawY >= ARENA_Y_MIN)) then 
			if (DrawX <= ARENA_X_MAX) AND (DrawX >= ARENA_X_MIN) then 
				--This is the arena.  It checks the color of a cell
					--in the array cell_color and maps it to a location
					--on the screen.
				case cell_color(Grid_X,Grid_Y) is
					when BLACK =>
						red    <= "0000000000";
						green  <= "0000000000";
						blue   <= "0000000000";
--					when REDc =>
--						red    <= "1111111111";
--						green  <= "0000000000";
--						blue   <= "0000000000";
					when BLUEc =>
						red    <= "0000000000";
						green  <= "0000000000";
						blue   <= "1111111111";
--					when WHITE =>
--						red    <= "1111111111";
--						green  <= "1111111111";
--						blue   <= "1111111111";
--					when others =>
--						red    <= "0000000000";
--						green  <= "0000000000";
--						blue   <= "0000000000";
				end case;
			--left border of arena
			elsif ((DrawX <= ARENA_X_MIN) AND (DrawX >= SCREEN_X_MIN)) then 
				RED   <= "1111111111";
				GREEN <= "1111111111";
				BLUE  <= "1111111111";
			--right border of arena
			elsif ((DrawX <= SCREEN_X_MAX) and (DrawX >= ARENA_X_MAX)) then 
				RED   <= "1111111111";
				GREEN <= "1111111111";
				BLUE  <= "1111111111";
			end if;

		--bottom border of arena
		elsif ((DrawY <= SCREEN_Y_MAX) AND (DrawY >= ARENA_Y_MAX)) then
			RED   <= "1111111111";
			GREEN <= "1111111111";
			BLUE  <= "1111111111";
		end if;
	end process;

	--state machine controller
	control_reg: process (reset, clk, next_state)
	begin
		if (reset = '1') then
			state <= A;
		elsif (rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;

	--controls which state we go to next for the state machine
	get_next_state : process (clk,state)
	begin
		case state is
			--in state A, we go to state B next
			when A =>
				next_state <= B;
			--in state B, we loop around back to A
			when B =>
				next_state <= A;
		end case;
	end process;

	--checks an x and y position in array to see if it's clear
		--if it is, then there is no wall there, so play1_wall_front is 0
		--otherwise there is a wall there and we need to let the crash_detector
		--know so we can crash.
	check_play1 : process(play1_check_X,play1_check_Y,cell_color)
	begin
		play1_wall_front <= '0';
		if (state = B) then
			if((play1_check_X > 128) OR (play1_check_Y > 128) OR (play1_check_X < 0) OR (play1_check_Y < 0)) then
				play1_wall_front <= '1';
			elsif(cell_color(play1_check_X,play1_check_Y) = BLUEc) then
				play1_wall_front <= '1';
			end if;
		end if;
	end process;

	--generates an X and Y position to be checked for a wall.  We will go
		--through each of the positions on the grid between the current
		--position and the next position, based on current speed.
	play1_wall_check : process(play1_Grid_X,play1_Grid_Y,play1_DIR,play1_X,play1_Y,play1_next_X_pos,play1_next_Y_pos,play1_current_speed,state,temp1)
	begin
--		play1_wall_f     <= CONV_STD_LOGIC_VECTOR(0,10);
--		play1_wall_front <= '0';
		play1_check_X    <= play1_Grid_X+play1_Size_int+1;
		play1_check_Y    <= play1_Grid_Y+play1_Size_int+1;
		temp1_in         <= play1_Size_int+1;
		load_temp1       <= '0';

		--if the next position is outside the bounds of the arena, we crashed
		if((play1_next_X_pos >= ARENA_X_MAX) OR (play1_next_X_pos <= ARENA_X_MIN) OR (play1_next_Y_pos >= ARENA_Y_MAX) OR (play1_next_Y_pos <= ARENA_Y_MIN)) then
			play1_check_X <= -1;
			play1_check_Y <= -1;
		else
			--We use a state machine to check each of the positions
				--sequentially rather than at the same time.  This method
				--generates significantly less logic on the FPGA.
			case state is
				when A =>
					--The X and Y positions we want to check depends on
						--what direction we're going.
					case play1_DIR is
						when UP =>
							play1_check_Y <= play1_Grid_Y - temp1;
						when DOWN =>
							play1_check_Y <= play1_Grid_Y + temp1;
						when LEFT =>
							play1_check_X <= play1_Grid_X - temp1;
						when RIGHT =>
							play1_check_X <= play1_Grid_X + temp1;
					end case;
				--increment counter
				when B =>
					load_temp1  <= '1';
					if (temp1 >= play1_current_speed) then
						temp1_in    <= play1_Size_int+1;
						play1_check_y <= 
					else
						temp1_in    <= temp1 + 1;
					end if;
			end case;
		end if;

--			for i in play1_Size_int to MAX_SPEED loop
--				if(i <= play1_current_speed) then
--					case play1_DIR is
--						when UP =>
--							if(cell_color(play1_X,play1_Y-i) = '1') then
--								play1_wall_f(i-play1_Size_int) <= '1';
--							end if;
--						when DOWN =>
--							if(cell_color(play1_X,play1_Y+i) = '1') then
--								play1_wall_f(i-play1_Size_int) <= '1';
--							end if;
--						when LEFT =>
--							if(cell_color(play1_X-i,play1_Y) = '1') then
--								play1_wall_f(i-play1_Size_int) <= '1';
--							end if;
--						when RIGHT =>
--							if(cell_color(play1_X+i,play1_Y) = '1') then
--								play1_wall_f(i-play1_Size_int) <= '1';
--							end if;
--						end case;
--				end if;
--			end loop;
--		end if;

--		if(play1_wall_f /= CONV_STD_LOGIC_VECTOR(0,MAX_SPEED-play1_Size_int)) then
--			play1_wall_front <= '1';
--		end if;

	end process;

--	play2_wall_check : process(play2_DIR,play2_next_X_pos,play2_next_Y_pos,cell_color,play2_current_speed,play2_X,play2_Y,play2_wall_f)
--	begin

--		play2_wall_f     <= CONV_STD_LOGIC_VECTOR(0,10);
--		play2_wall_front <= '0';
		
--		if((play2_next_X_pos >= ARENA_X_MAX) OR (play2_next_X_pos <= ARENA_X_MIN) OR (play2_next_Y_pos >= ARENA_Y_MAX) OR (play2_next_Y_pos <= ARENA_Y_MIN)) then
--			play2_wall_front <= '1';
--		else
--			for i in play2_Size_int to MAX_SPEED loop
--				if(i <= play2_current_speed) then
--					case play2_DIR is
--						when UP =>
--							if(cell_color(play2_X,play2_Y-i) = '1') then
--								play2_wall_f(i-play2_Size_int) <= '1';
--							end if;
--						when DOWN =>
--							if(cell_color(play2_X,play2_Y+i) = '1') then
--								play2_wall_f(i-play2_Size_int) <= '1';
--							end if;
--						when LEFT =>
--							if(cell_color(play2_X-i,play2_Y) = '1') then
--								play2_wall_f(i-play2_Size_int) <= '1';
--							end if;
--						when RIGHT =>
--							if(cell_color(play2_X+i,play2_Y) = '1') then
--								play2_wall_f(i-play2_Size_int) <= '1';
--							end if;
--					end case;
--				end if;
--			end loop;
--		end if;

--		if(play2_wall_f /= CONV_STD_LOGIC_VECTOR(0,MAX_SPEED-play2_Size_int)) then
--			play2_wall_front <= '1';
--		end if;

--	end process;

	    --above
	      play1_above_red   <= "0000000000";
	      play1_above_green <= "0000000000";
	      play1_above_blue  <= "0000000000";

	      play2_above_red   <= "0000000000";
	      play2_above_green <= "0000000000";
	      play2_above_blue  <= "0000000000";
	   --below
	      play1_below_red   <= "0000000000";
	      play1_below_green <= "0000000000";
	      play1_below_blue  <= "0000000000";

	      play2_below_red   <= "0000000000";
	      play2_below_green <= "0000000000";
	      play2_below_blue  <= "0000000000";
	   --right
	      play1_right_red   <= "0000000000";
	      play1_right_green <= "0000000000";
	      play1_right_blue  <= "0000000000";

	      play2_right_red   <= "0000000000";
	      play2_right_green <= "0000000000";
	      play2_right_blue  <= "0000000000";
	   --left
	      play1_left_red    <= "0000000000";
	      play1_left_green  <= "0000000000";
	      play1_left_blue   <= "0000000000";

	      play2_left_red    <= "0000000000";
	      play2_left_green  <= "0000000000";
	      play2_left_blue   <= "0000000000";

	      play1_Grid_X_Out  <= CONV_STD_LOGIC_VECTOR(play1_Grid_X,8);
	      play1_Grid_Y_Out  <= CONV_STD_LOGIC_VECTOR(play1_Grid_Y,8);
End Behavioral;
