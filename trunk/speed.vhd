--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/17/2008                                                --
--  Design Name:    Speed Control                                             --
--  Module Name:    speed - Behavioral                                        --
--                                                                            --
--  Comments:                                                                 --
--    This unit controls the speed of light cycle. It outputs a speed based   --
--     on the current speed and the input accel.                              --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity speed is
	Port( clk    : in std_logic;
	      reset  : in std_logic;
	      accel  : in std_logic_vector(1 downto 0);
	      speed  : out std_logic_vector(9 downto 0)
	    );
end speed;

architecture Behavioral of speed is

	component reg_10 is
		port( clk       : in std_logic;
		      reset     : in std_logic;
		      load      : in std_logic;
		      d_in      : in std_logic_vector(9 downto 0);
		      
		      d_out     : out std_logic_vector(9 downto 0)
			);
	end component;

type ctrl_state is (STOP,CONST,ACCELERATE,DECELERATE);
signal State, Next_state  : ctrl_state;
signal current_speed      : std_logic_vector(9 downto 0);
signal new_speed          : std_logic_vector(9 downto 0);

constant Speed_Step       : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR( 1,10);
constant Max_Speed        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(10,10);
constant Min_Speed        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR( 1,10);
constant Default_Speed    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR( 3,10);

begin

	reg_10A : reg_10
		Port Map( clk       => clk,
                  reset     => reset,
                  load      => '1',
                  d_in      => new_speed,
                  
                  d_out     => current_speed 
				);
	
	Assign_Next_State : process(clk,accel)
	begin
		if(accel = "00") then
			State <= STOP;
		elsif(rising_edge(clk)) then
			State <= Next_State;
		end if;
	end process;

	Get_Next_State : process(accel,state)
	begin
		case State is
			when STOP =>
				--if accel is "11", we wait for the game to start. When the game starts, we go to
					--state CONST before anything else.
				if(accel = "00") then
					Next_State <= STOP;
				else
					Next_State <= CONST;
				end if;
			--When we are not stopped, the next state is based only on the input accel.
			when others =>
				if(accel = "10") then
					Next_State <= DECELERATE;
				elsif(accel = "01") then
					Next_State <= ACCELERATE;
				elsif(accel = "11") then
					Next_State <= CONST;
				else
					Next_State <= CONST;
				end if;
		end case;
	end process;

	Assign_Control_Signals : process(State,current_speed)
	begin
		case State is

			--We will only be in the stop state at the start of the round or when we crash.
			when STOP =>
				new_speed <= "0000000000";

			--If we are in this state, we are not against a trail or wall and we are not pressing
				--the brake key.
			when CONST =>

				--You cannot stay at a speed less than the default speed. If after you let go of the
					--brake you are going slower than Default_Speed, you will accelerate back to the
					--default speed.
				if(current_speed <= Default_Speed) then
					new_speed <= current_speed + Speed_Step;

				--otherwise, the speed stays constant.
				else
					new_speed <= current_speed;
				end if;

			--Being in this state means that we are up against a trail. This means that we should accelerate.
			when ACCELERATE =>
				if (current_speed >= Max_Speed) then
					new_speed <= Max_Speed;
				else
					new_speed <= current_speed + Speed_Step;
				end if;

			--If we are in this state, we are either against the wall of the arena or we are braking. That
				--means we need to decelerate.
			when DECELERATE =>
				if (current_speed <= Min_Speed) then
					new_speed <= Min_Speed;
				else
					new_speed <= current_speed - Speed_Step;
				end if;
			when others =>
				new_speed <= current_speed;
		end case;
	end process;

	speed <= current_speed;

end Behavioral;
