--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/18/2008                                                --
--  Design Name:    Light Cycles                                              --
--  Module Name:    LightCycles - Behavioral                                  --
--                                                                            --
--  Comments:                                                                 --
--                                                                            --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LightCycles is
	Port( clk           : in std_logic;
	      reset         : in std_logic;
	      ps2clk        : in std_logic;
	      ps2data       : in std_logic;

	      Red           : out std_logic_vector(9 downto 0);
	      Green         : out std_logic_vector(9 downto 0);
	      Blue          : out std_logic_vector(9 downto 0);
	      VGA_clk       : out std_logic;
	      sync          : out std_logic;
	      blank         : out std_logic;
	      vs            : out std_logic;
	      hs            : out std_logic;

	      LEDG          : out std_logic_vector(7 downto 0);
		  LEDR          : out std_logic_vector(6 downto 0);

		  HEX4          : out std_logic_vector(6 downto 0);
		  HEX5          : out std_logic_vector(6 downto 0)
	    );
end LightCycles;

Architecture Behavioral of LightCycles is

	component game_control is
		port( clk         : in std_logic;
		      reset       : in std_logic;
		      crash       : in std_logic_vector(1 downto 0);
		      keypress    : in std_logic;

		      starter     : out std_logic;
		      reset_game  : out std_logic;
		      reset_round : out std_logic;
			  menu_signal : out std_logic;
		      new_round   : out std_logic;
		      FIGHT       : out std_logic;

		      winner_play1: out std_logic;
		      winner_play2: out std_logic;

		      play1_lives : out std_logic_vector(1 downto 0);
		      play2_lives : out std_logic_vector(1 downto 0)
		    );
	end component;

	component player_velocity_control is
		Port( clk          : in std_logic;
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
	end component;

	component crash_detect is
		Port( clk           : in std_logic;
		      reset         : in std_logic;
		      beginning     : in std_logic;
		      next_X_pos    : in std_logic_vector(9 downto 0);
		      next_Y_pos    : in std_logic_vector(9 downto 0);
		      play_Size     : in std_logic_vector(9 downto 0);
		      DIR           : in std_logic_vector(1 downto 0);
		      DrawX         : in std_logic_vector(9 downto 0);
		      DrawY         : in std_logic_vector(9 downto 0);
		      RED           : in std_logic_vector(9 downto 0);
		      GREEN         : in std_logic_vector(9 downto 0);
		      BLUE          : in std_logic_vector(9 downto 0);
		      wall_front    : in std_logic;

		      Xpos          : out std_logic_vector(9 downto 0);
		      Ypos          : out std_logic_vector(9 downto 0);
		      crashed       : out std_logic;
		      black_OUT     : out std_logic;

			  in_start      : out std_logic;
			  in_check      : out std_logic;
			  in_crash      : out std_logic
		    );
	end component;

component wall_detect is
	Port( DIR               : in std_logic_vector(1 downto 0);
	      play_above_red    : in std_logic_vector(9 downto 0);
	      play_above_green  : in std_logic_vector(9 downto 0);
	      play_above_blue   : in std_logic_vector(9 downto 0);

	      play_below_red    : in std_logic_vector(9 downto 0);
	      play_below_green  : in std_logic_vector(9 downto 0);
	      play_below_blue   : in std_logic_vector(9 downto 0);

	      play_right_red    : in std_logic_vector(9 downto 0);
	      play_right_green  : in std_logic_vector(9 downto 0);
	      play_right_blue   : in std_logic_vector(9 downto 0);

	      play_left_red     : in std_logic_vector(9 downto 0);
	      play_left_green   : in std_logic_vector(9 downto 0);
	      play_left_blue    : in std_logic_vector(9 downto 0);

	      accel             : out std_logic_vector(1 downto 0)
	    );
end component;

	component key_processor is
		port( clk             : in std_logic;
		      reset           : in std_logic;
			  KeyCode         : in std_logic_vector(7 downto 0);
		      break           : in std_logic;

		      dir_key_Press   : out std_logic_vector(1 downto 0);
		      enter_key       : out std_logic
		    );
	end component;

	component keyboard is
		Port( ps2data, ps2clk, clk, reset   : in std_logic;
		      keyCode                       : out std_logic_vector(7 downto 0);
		      break                         : out std_logic);
	end component;

	component color_map_dummy is
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

		      DrawX              : in std_logic_vector(9 downto 0);
		      DrawY              : in std_logic_vector(9 downto 0);

		      Red                : out std_logic_vector(9 downto 0);
		      Green              : out std_logic_vector(9 downto 0);
		      Blue               : out std_logic_vector(9 downto 0);

		      play1_above_red    : out std_logic_vector(9 downto 0);
		      play1_above_green  : out std_logic_vector(9 downto 0);
		      play1_above_blue   : out std_logic_vector(9 downto 0);

		      play2_above_red    : out std_logic_vector(9 downto 0);
		      play2_above_green  : out std_logic_vector(9 downto 0);
		      play2_above_blue   : out std_logic_vector(9 downto 0);

		      play1_below_red    : out std_logic_vector(9 downto 0);
		      play1_below_green  : out std_logic_vector(9 downto 0);
		      play1_below_blue   : out std_logic_vector(9 downto 0);

		      play2_below_red    : out std_logic_vector(9 downto 0);
		      play2_below_green  : out std_logic_vector(9 downto 0);
		      play2_below_blue   : out std_logic_vector(9 downto 0);

		      play1_right_red    : out std_logic_vector(9 downto 0);
		      play1_right_green  : out std_logic_vector(9 downto 0);
		      play1_right_blue   : out std_logic_vector(9 downto 0);

		      play2_right_red    : out std_logic_vector(9 downto 0);
		      play2_right_green  : out std_logic_vector(9 downto 0);
		      play2_right_blue   : out std_logic_vector(9 downto 0);

		      play1_left_red     : out std_logic_vector(9 downto 0);
		      play1_left_green   : out std_logic_vector(9 downto 0);
		      play1_left_blue    : out std_logic_vector(9 downto 0);

		      play2_left_red     : out std_logic_vector(9 downto 0);
		      play2_left_green   : out std_logic_vector(9 downto 0);
		      play2_left_blue    : out std_logic_vector(9 downto 0);

		      play1_wall_front   : out std_logic;
		      play2_wall_front   : out std_logic
            );
	end component;

	component AI is
		Port( clk               : in std_logic;
		      DIR               : in std_logic_vector(1 downto 0);

		      play_right_red    : in std_logic_vector(9 downto 0);
		      play_right_green  : in std_logic_vector(9 downto 0);
		      play_right_blue   : in std_logic_vector(9 downto 0);

		      play_left_red     : in std_logic_vector(9 downto 0);
		      play_left_green   : in std_logic_vector(9 downto 0);
		      play_left_blue    : in std_logic_vector(9 downto 0);

		      play_above_red    : in std_logic_vector(9 downto 0);
		      play_above_green  : in std_logic_vector(9 downto 0);
		      play_above_blue   : in std_logic_vector(9 downto 0);

		      play_below_red    : in std_logic_vector(9 downto 0);
		      play_below_green  : in std_logic_vector(9 downto 0);
		      play_below_blue   : in std_logic_vector(9 downto 0);

		      dir_AI            : out std_logic_vector(1 downto 0)
		    );
	end component;

	component vga_controller is
	  Port( clk       : in  std_logic;
	        reset     : in  std_logic;
	        hs        : out std_logic;
	        vs        : out std_logic;
	        pixel_clk : out std_logic;
	        blank     : out std_logic;
	        sync      : out std_logic;
	        DrawX     : out std_logic_vector(9 downto 0);
	        DrawY     : out std_logic_vector(9 downto 0)
	      );
	end component;

	component HexDriver is
	port( In0 : in std_logic_vector(3 downto 0);
	      Out0 : out std_logic_vector(6 downto 0)
        );
	end component;

	signal reset_h            : std_logic;
	signal crash_sig          : std_logic_vector(1 downto 0);
	signal enter              : std_logic;
	signal menu_reset         : std_logic;
	signal reset_vehicle      : std_logic;
	signal key_dir            : std_logic_vector(1 downto 0);
	signal comp_dir           : std_logic_vector(1 downto 0);
	signal keycode            : std_logic_vector(7 downto 0);
	signal break              : std_logic;
	signal starter            : std_logic;
	signal vsSig              : std_logic;
	signal pixel_clk          : std_logic;

	signal play1_wall_front   : std_logic;
	signal play2_wall_front   : std_logic;

	signal p1_start           : std_logic;
	signal p1_check           : std_logic;
	signal p1_crash           : std_logic;

	signal drawX              : std_logic_vector(9 downto 0);
	signal drawY              : std_logic_vector(9 downto 0);

	signal play1_accel        : std_logic_vector(1 downto 0);
	signal play1_X            : std_logic_vector(9 downto 0);
	signal play1_Y            : std_logic_vector(9 downto 0);
	signal play1_dir          : std_logic_vector(1 downto 0);
	signal play1_new_X        : std_logic_vector(9 downto 0);
	signal play1_new_Y        : std_logic_vector(9 downto 0);
	signal play1_speed        : std_logic_vector(9 downto 0);

	signal play2_accel        : std_logic_vector(1 downto 0);
	signal play2_X            : std_logic_vector(9 downto 0);
	signal play2_Y            : std_logic_vector(9 downto 0);
	signal play2_dir          : std_logic_vector(1 downto 0);
	signal play2_new_X        : std_logic_vector(9 downto 0);
	signal play2_new_Y        : std_logic_vector(9 downto 0);
	signal play2_speed        : std_logic_vector(9 downto 0);

	signal play1_above_red    : std_logic_vector(9 downto 0);
	signal play1_above_green  : std_logic_vector(9 downto 0);
	signal play1_above_blue   : std_logic_vector(9 downto 0);

	signal play1_below_red    : std_logic_vector(9 downto 0);
	signal play1_below_green  : std_logic_vector(9 downto 0);
	signal play1_below_blue   : std_logic_vector(9 downto 0);

	signal play1_right_red    : std_logic_vector(9 downto 0);
	signal play1_right_green  : std_logic_vector(9 downto 0);
	signal play1_right_blue   : std_logic_vector(9 downto 0);

	signal play1_left_red     : std_logic_vector(9 downto 0);
	signal play1_left_green   : std_logic_vector(9 downto 0);
	signal play1_left_blue    : std_logic_vector(9 downto 0);

	signal play2_above_red    : std_logic_vector(9 downto 0);
	signal play2_above_green  : std_logic_vector(9 downto 0);
	signal play2_above_blue   : std_logic_vector(9 downto 0);

	signal play2_below_red    : std_logic_vector(9 downto 0);
	signal play2_below_green  : std_logic_vector(9 downto 0);
	signal play2_below_blue   : std_logic_vector(9 downto 0);

	signal play2_right_red    : std_logic_vector(9 downto 0);
	signal play2_right_green  : std_logic_vector(9 downto 0);
	signal play2_right_blue   : std_logic_vector(9 downto 0);

	signal play2_left_red     : std_logic_vector(9 downto 0);
	signal play2_left_green   : std_logic_vector(9 downto 0);
	signal play2_left_blue    : std_logic_vector(9 downto 0);

	signal Draw_red           : std_logic_vector(9 downto 0);
	signal Draw_green         : std_logic_vector(9 downto 0);
	signal Draw_blue          : std_logic_vector(9 downto 0);

	signal play1_lives        : std_logic_vector(1 downto 0);
	signal play2_lives        : std_logic_vector(1 downto 0);

	constant play1_Size       : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(1,10);
	constant play2_Size       : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(1,10);

begin

	reset_h <= not(reset); --push buttons are active low

	gameplay :  game_control
		port map( clk         => vsSig,
		          reset       => reset_h,
		          crash       => crash_sig,
		          keypress    => enter,
				  starter     => starter,

		          reset_game  => menu_reset,
		          reset_round => reset_vehicle,
				  menu_signal => LEDG(0),
				  new_round   => LEDG(1),
				  FIGHT       => LEDG(2),
				  winner_play1=> LEDR(5),
				  winner_play2=> LEDR(6),

		          play1_lives => play1_lives,
		          play2_lives => play2_lives
		        );

	player1_velocity : player_velocity_control
		port map( clk          => vsSig,
		          reset        => reset_vehicle,
		          key_Press    => key_dir,
		          Default_X    => CONV_STD_LOGIC_VECTOR(210,10),
		          Default_Y    => CONV_STD_LOGIC_VECTOR(290,10),
		          Default_DIR  => "01",
		          Acceleration => play1_accel,
				  start        => starter,

		          DIR          => play1_dir,
		          Xpos         => play1_X,
		          Ypos         => play1_Y,
				  speed_out    => play1_speed
		        );

	player2_velocity : player_velocity_control
		port map( clk          => vsSig,
		          reset        => reset_vehicle,
		          key_Press    => comp_dir,
		          Default_X    => CONV_STD_LOGIC_VECTOR(430,10),
		          Default_Y    => CONV_STD_LOGIC_VECTOR(290,10),
		          Default_DIR  => "10",
		          Acceleration => play2_accel,
				  start        => starter,

		          DIR          => play2_dir,
		          Xpos         => play2_X,
		          Ypos         => play2_Y,
				  speed_out    => play2_speed
		        );

	player1_crash_detect : crash_detect
		port map( clk           => pixel_clk,
		          reset         => reset_vehicle,
		          beginning     => starter,
		          next_X_pos    => play1_X,
		          next_Y_pos    => play1_Y,
		          play_Size     => play1_Size,
		          DIR           => play1_dir,
				  DrawX         => DrawX,
				  DrawY         => DrawY,
				  RED           => Draw_red,
				  GREEN         => Draw_green,
				  BLUE          => Draw_blue,
				  wall_front    => play1_wall_front,

		          Xpos          => play1_new_X,
		          Ypos          => play1_new_Y,
		          crashed       => crash_sig(1),
				  black_OUT     => LEDG(6),

		          in_start      => p1_start,
				  in_check      => p1_check,
				  in_crash      => p1_crash
		        );

	player2_crash_detect : crash_detect
		port map( clk           => pixel_clk,
		          reset         => reset_vehicle,
		          beginning     => starter,
		          next_X_pos    => play2_X,
		          next_Y_pos    => play2_Y,
		          play_Size     => play2_Size,
		          DIR           => play2_dir,
				  DrawX         => DrawX,
				  DrawY         => DrawY,
				  RED           => Draw_red,
				  GREEN         => Draw_green,
				  BLUE          => Draw_blue,
				  wall_front    => play2_wall_front,

		          Xpos          => play2_new_X,
		          Ypos          => play2_new_Y,
		          crashed       => crash_sig(0),
				  black_OUT     => LEDG(7)
		        );

	player1_wall_detect : wall_detect
		port map( DIR               => play1_dir,
		          play_above_red    => play1_above_red,
		          play_above_green  => play1_above_green,
		          play_above_blue   => play1_above_blue,

		          play_below_red    => play1_below_red,
		          play_below_green  => play1_below_green,
		          play_below_blue   => play1_below_blue,

		          play_right_red    => play1_right_red,
		          play_right_green  => play1_right_green,
		          play_right_blue   => play1_right_blue,

		          play_left_red     => play1_left_red,
		          play_left_green   => play1_left_green,
		          play_left_blue    => play1_left_blue,

		          accel             => play1_accel
		        );

	player2_wall_detect : wall_detect
		port map( DIR               => play2_dir,
		          play_above_red    => play2_above_red,
		          play_above_green  => play2_above_green,
		          play_above_blue   => play2_above_blue,

		          play_below_red    => play2_below_red,
		          play_below_green  => play2_below_green,
		          play_below_blue   => play2_below_blue,

		          play_right_red    => play2_right_red,
		          play_right_green  => play2_right_green,
		          play_right_blue   => play2_right_blue,

		          play_left_red     => play2_left_red,
		          play_left_green   => play2_left_green,
		          play_left_blue    => play2_left_blue,

		          accel             => play2_accel
		        );

	play1_key_process : key_processor
		port map ( clk             => vsSig,
		           reset           => reset_h,
				   KeyCode         => keycode,
		           break           => break,

		           dir_key_Press   => key_dir,
		           enter_key       => enter
		         );

	keyboard_entity :  keyboard
		Port map( ps2data          => ps2data,
		          ps2clk           => ps2clk,
		          clk              => clk,
		          reset            => reset_h,
		          keyCode          => keycode,
		          break            => break
		        );

	color_mapper : color_map_dummy
		Port map( Clk                => clk,
		          Reset              => reset_vehicle,

		          play1_Y_pos        => play1_new_Y,
		          play1_X_pos        => play1_new_X,
		          play1_Size         => play1_Size,

		          play2_Y_pos        => play2_new_Y,
		          play2_X_pos        => play2_new_X,
		          play2_Size         => play2_Size,

				  play1_next_X_pos   => play1_X,
				  play1_next_Y_pos   => play1_Y,

				  play2_next_X_pos   => play2_X,
				  play2_next_Y_pos   => play2_Y,

				  play1_current_speed=> play1_speed,
				  play2_current_speed=> play2_speed,

				  play1_DIR          => play1_dir,
				  play2_DIR          => play2_dir,

		          DrawX              => drawX,
		          DrawY              => drawY,

		          Red                => Draw_red,
		          Green              => Draw_green,
		          Blue               => Draw_blue,

		          play1_above_red    => play1_above_red,
		          play1_above_green  => play1_above_green,
		          play1_above_blue   => play1_above_blue,

		          play2_above_red    => play2_above_red,
		          play2_above_green  => play2_above_green,
		          play2_above_blue   => play2_above_blue,

		          play1_below_red    => play1_below_red,
		          play1_below_green  => play1_below_green,
		          play1_below_blue   => play1_below_blue,

		          play2_below_red    => play2_below_red,
		          play2_below_green  => play2_below_green,
		          play2_below_blue   => play2_below_blue,

		          play1_right_red    => play1_right_red,
		          play1_right_green  => play1_right_green,
		          play1_right_blue   => play1_right_blue,

		          play2_right_red    => play2_right_red,
		          play2_right_green  => play2_right_green,
		          play2_right_blue   => play2_right_blue,

		          play1_left_red     => play1_left_red,
		          play1_left_green   => play1_left_green,
		          play1_left_blue    => play1_left_blue,

		          play2_left_red     => play2_left_red,
		          play2_left_green   => play2_left_green,
		          play2_left_blue    => play2_left_blue,
		          play1_wall_front   => play1_wall_front,
		          play2_wall_front   => play2_wall_front
		        );

		AE : AI
		Port Map( clk               => clk,
		          DIR               => comp_dir,

		          play_right_red    => play2_right_red,
		          play_right_green  => play2_right_green,
		          play_right_blue   => play2_right_blue,

		          play_left_red     => play2_left_red,
		          play_left_green   => play2_left_green,
		          play_left_blue    => play2_left_blue,

		          play_above_red    => play2_above_red,
		          play_above_green  => play2_above_green,
		          play_above_blue   => play2_above_blue,

		          play_below_red    => play2_below_red,
		          play_below_green  => play2_below_green,
		          play_below_blue   => play2_below_blue,

		          dir_AI            => comp_dir
		        );

		VGA_entity : VGA_controller
		Port Map( clk       => clk,
		          reset     => reset_h,
		          hs        => hs,
		          vs        => vsSIG,
		          pixel_clk => pixel_clk,
		          blank     => blank,
		          sync      => sync,
		          DrawX     => DrawX,
		          DrawY     => DrawY
		        );

		Hex4_ent : HexDriver
		Port Map( in0       => "00" & play1_lives,
		          out0      => HEX4
		        );

		Hex5_ent : HexDriver
		Port Map( in0       => "00" & play2_lives,
		          out0      => HEX5
		        );

	Red     <= Draw_red;
	Green   <= Draw_green;
	Blue    <= Draw_blue;
	VGA_clk <= pixel_clk;

	LEDG(3) <= enter;
	LEDG(5 downto 4) <= play1_dir;

	LEDR(0) <= reset_h;
	LEDR(1) <= reset_vehicle;
	LEDR(2) <= p1_start;
	LEDR(3) <= play1_wall_front;
	LEDR(4) <= play2_wall_front;

	vs      <= vsSig;


end Behavioral;
