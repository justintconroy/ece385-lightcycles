--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/17/2008                                                --
--  Design Name:    Player Velocity Control                                   --
--  Module Name:    player_velocity_control - Behavioral                      --
--                                                                            --
--  Comments:                                                                 --
--    This unit controls the direction and speed of a Player's light cycle.   --
--     It is made up of two entities each designated for controlling the      --
--     player's speed or direction.                                           --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity player_velocity_control is
	Port(clk          : in std_logic;
	     reset        : in std_logic;
	     key_Press    : in std_logic_vector(1 downto 0);
	     Default_X    : in std_logic_vector(9 downto 0);
	     Default_Y    : in std_logic_vector(9 downto 0);
	     Default_DIR  : in std_logic_vector(1 downto 0);
	     Acceleration : in std_logic_vector(1 downto 0);
	     start        : in std_logic;

	     DIR          : out std_logic_vector(1 downto 0);
	     Xpos         : out std_logic_vector(9 downto 0);
	     Ypos         : out std_logic_vector(9 downto 0);
		 speed_out    : out std_logic_vector(9 downto 0)
	    );

end player_velocity_control;

architecture Behavioral of player_velocity_control is

	component direction is
		Port( clk         : in std_logic;
		      reset       : in std_logic;
		      Default_DIR : in std_logic_vector(1 downto 0);
		      key_DIR     : in std_logic_vector(1 downto 0);
		      next_DIR    : out std_logic_vector(1 downto 0)
		    );
	end component;


	component speed is
		Port( clk    : in std_logic;
		      reset  : in std_logic;
		      accel  : in std_logic_vector(1 downto 0);
		      speed  : out std_logic_vector(9 downto 0)
		    );
	end component;

signal next_DIR : std_logic_vector(1 downto 0);
signal accel    : std_logic_vector(1 downto 0);
signal speed_s  : std_logic_vector(9 downto 0);
signal key_DIR  : std_logic_vector(1 downto 0);
signal new_X_pos: std_logic_vector(9 downto 0);
signal new_Y_pos: std_logic_vector(9 downto 0);
signal X_Motion : std_logic_vector(9 downto 0);
signal Y_Motion : std_logic_vector(9 downto 0);

constant UP     : std_logic_vector(1 downto 0) := "11";
constant DOWN   : std_logic_vector(1 downto 0) := "00";
constant LEFT   : std_logic_vector(1 downto 0) := "10";
constant RIGHT  : std_logic_vector(1 downto 0) := "01";

constant BRAKE  : std_logic_vector(1 downto 0) := "11";
constant NONE   : std_logic_vector(1 downto 0) := "00";
constant STOP   : std_logic_vector(1 downto 0) := "00";


begin


	directional : direction
		Port Map( clk         => clk,
		          reset       => reset,
				  Default_DIR => Default_DIR,
		          key_DIR     => key_DIR,
		          next_DIR    => next_DIR
		        );

	speedal : speed
		Port Map( clk     => clk,
		          reset   => reset,
		          accel   => accel,
		          speed   => speed_s
		        );

	next_position : process(Default_X,Default_Y,key_Press,reset,clk,next_DIR,speed_s,Acceleration,Default_DIR)
        begin
		accel(0) <= Acceleration(0);
		if(Reset = '1') then
			new_X_pos     <= Default_X;
			new_Y_pos     <= Default_Y;
			accel         <= STOP;
		elsif(rising_edge(clk)) then

			key_DIR <= key_Press;

			--Get next Position.
			if(start = '1') then
				case next_DIR is
					when UP =>
						X_Motion <= "0000000000";
						Y_Motion <= not(speed_s) + 1;
					when DOWN =>
						X_Motion <= "0000000000";
						Y_Motion <= speed_s;
					when LEFT =>
						X_Motion <= not(speed_s) + 1;
						Y_Motion <= "0000000000";
					when RIGHT =>
						X_Motion <= speed_s;
						Y_Motion <= "0000000000";
					end case;
	
				case key_Press is
					when NONE =>
						key_DIR <= NONE;
						accel(1) <= Acceleration(1);
					when BRAKE =>
						key_DIR <= NONE;
						accel(1) <= '1'; --brakes
					when LEFT =>
						key_DIR <= LEFT;
						accel(1) <= '1'; --turning slows you down
					when RIGHT =>
						key_DIR <= RIGHT;
						accel(1) <= '1'; --turning slows you donw
				end case;

			else
				X_Motion     <= "0000000000";
				Y_Motion     <= "0000000000";
			end if;

		new_X_pos <= new_X_Pos + X_Motion;
		new_Y_pos <= new_Y_Pos + Y_Motion;

		end if;
	end process;

	DIR  <= next_DIR;
	Xpos <= new_X_Pos;
	Ypos <= new_Y_Pos;
	speed_out <= speed_s;

end Behavioral;
