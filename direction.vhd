--------------------------------------------------------------------------------
--  Company:        UIUC ECE Dept.                                            --
--  Engineers:      Justin Conroy                                             --
--                  David Ho                                                  --
--                                                                            --
--  Create Date:    07/17/2008                                                --
--  Design Name:    Direction Control                                         --
--  Module Name:    direction - Behavioral                                    --
--                                                                            --
--  Comments:                                                                 --
--    This unit controls the direction of a light cycle. It rembembers the    --
--    current direction and outputs the new direction based on the direction  --
--    input to it by key_DIR.                                                 --
--                                                                            --
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity direction is
	Port( clk         : in std_logic;
	      reset       : in std_logic;
	      key_DIR     : in std_logic_vector(1 downto 0);
	      Default_DIR : in std_logic_vector(1 downto 0);
	      next_DIR    : out std_logic_vector(1 downto 0)
	    );
end direction;

architecture Behavioral of direction is

type ctrl_state is (UP,DOWN,LEFT,RIGHT);
signal State, Next_state : ctrl_state;

begin

	Assign_Next_State : process(clk,key_DIR,reset,State,Default_DIR)
	begin
		if(reset = '1') then
			if(Default_DIR = "00") then
				State <= DOWN;
			elsif(Default_DIR = "11") then
				State <= UP;
			elsif(Default_DIR = "01") then
				State <= RIGHT;
			elsif(Default_DIR = "10") then
				State <= LEFT;
			end if;
		elsif(rising_edge(clk)) then
			State <= Next_State;
		end if;
	end process;

	Get_Next_State : process(key_DIR,State)
	begin
		case State is
			when UP =>
				if(key_DIR = "10") then
					Next_State <= LEFT;
				elsif(key_DIR = "01") then
					Next_State <= RIGHT;
				else
					Next_State <= UP;
				end if;
			when DOWN =>
				if(key_DIR = "10") then
					Next_State <= RIGHT;
				elsif(key_DIR = "01") then
					Next_State <= LEFT;
				else
					Next_State <= DOWN;
				end if;
			when LEFT =>
				if(key_DIR = "10") then
					Next_State <= DOWN;
				elsif(key_DIR = "01") then
					Next_State <= UP;
				else
					Next_State <= LEFT;
				end if;
			when RIGHT =>
				if(key_DIR = "10") then
					Next_State <= UP;
				elsif(key_DIR = "01") then
					Next_State <= DOWN;
				elsif(key_DIR = "11") then
					Next_State <= UP;
				else
					Next_State <= RIGHT;
				end if;
		end case;
	end process;

	Assign_Control_Signals : process(State)
	begin
		case State is
			when UP =>
				next_DIR <= "11";
			when DOWN =>
				next_DIR <= "00";
			when LEFT =>
				next_DIR <= "10";
			when RIGHT =>
				next_DIR <= "01";
		end case;
	end process;

end Behavioral;
