------------------------------------------------------------------------------
--		Company:		UIUC ECE Dept.										--
--		Engineers:		David Ho											--
--						Justin Conroy										--
--																			--
--		Create Date:	07/16/2008											--
--		Design Name:	Game Control Unit									--
--		Module Name:	game_control - Behavioral							--
--																			--
--		Comments:															--
--				Game Control Unit controls the whole game. We use 			--
--				a state machine to control menu, start, round, and results.	--
--				Crash from crash_detection and number of lifes for players	--
--				determine which state it will go.							--
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity game_control is
	port ( clk : in std_logic;
	       reset : in std_logic;
	       crash : in std_logic_vector(1 downto 0); -- from crash_detection
	       keypress : in std_logic; -- from keyboard, it will make 
	                                   -- a new round starts
	       reset_game  : out std_logic; -- Reset game, to menu control
	       reset_round : out std_logic; -- Reset round, to vehicle_control
	       starter     : out std_logic;
	       begin_round : out std_logic;
	       menu_signal : out std_logic;
	       new_round   : out std_logic;
	       FIGHT       : out std_logic;
		   winner_play1: out std_logic;
		   winner_play2: out std_logic;

	       play1_lives : out std_logic_vector(1 downto 0);
	       play2_lives : out std_logic_vector(1 downto 0)
         );
end game_control;

architecture Behavioral of game_control is

	component reg_2 is
		port( clk       : in std_logic;
		      reset     : in std_logic;
		      load      : in std_logic;
		      d_in      : in std_logic_vector(1 downto 0);
		      
		      d_out     : out std_logic_vector(1 downto 0)
			);
	end component;

type cntrl_state is (MENU, START, ROUND, PLAY1CRASH, BOTHCRASH, PLAY2CRASH, CHECKLIVES, PLAY1WIN, PLAY2WIN, BOTHLOSE);
signal state, next_state : cntrl_state;

signal player1_life : std_logic_vector(1 downto 0);
signal player2_life : std_logic_vector(1 downto 0);
signal player1_life_temp : std_logic_vector(1 downto 0);
signal player2_life_temp : std_logic_vector(1 downto 0);
signal load1, load2      : std_logic;

constant PLAYER1 : std_logic_vector(1 downto 0) := "10";
constant PLAYER2 : std_logic_vector(1 downto 0) := "01";
constant BOTH    : std_logic_vector(1 downto 0) := "11";
constant NEITHER : std_logic_vector(1 downto 0) := "00";

begin

	reg_2A : reg_2
		Port Map( clk       => clk,
                  reset     => reset,
                  load      => load1,
                  d_in      => player1_life_temp,
                  
                  d_out     => player1_life
				);

	reg_2B : reg_2
		Port Map( clk       => clk,
                  reset     => reset,
                  load      => load2,
                  d_in      => player2_life_temp,
                  
                  d_out     => player2_life
				);

	control_reg: process (reset, clk)
	begin
		if (reset = '1') then
			state <= MENU;
		elsif (rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;

	get_next_state: process (state, player1_life, player2_life, crash, keypress)
	begin
		case state is
			when MENU =>
				if (keypress ='1') then
					next_state <= START;
				else
					next_state <= MENU;
				end if;
			when START =>
				if (keypress = '1') then
					next_state <= ROUND;
				else
					next_state <= START;
				end if;
			when ROUND =>
				if (crash = PLAYER1) then
					next_state <= PLAY1CRASH;
				elsif (crash = PLAYER2) then
					next_state <= PLAY2CRASH;
				elsif (crash = BOTH) then
					next_state <= BOTHCRASH;
				else --neither player crashed
					next_state <= ROUND;
				end if;
			when PLAY1CRASH =>
				next_state <= CHECKLIVES;
			when PLAY2CRASH =>
				next_state <= CHECKLIVES;
			when BOTHCRASH =>
				next_state <= CHECKLIVES;
			when CHECKLIVES =>
				if((player1_life = "00") AND (player2_life = "00")) then
					next_state <= BOTHLOSE;
				elsif(player1_life = "00") then
					next_state <= PLAY2WIN;
				elsif(player2_life = "00") then
					next_state <= PLAY1WIN;
				else
					next_state <= START;
				end if;
			when PLAY1WIN =>
				if(keypress = '1') then
					next_state <= MENU;
				else
					next_state <= PLAY1WIN;
				end if;
			when PLAY2WIN =>
				if(keypress ='1') then
					next_state <= MENU;
				else
					next_state <= PLAY2WIN;
				end if;
			when BOTHLOSE =>
				next_state <= ROUND;
			end case;
	end process;

	get_cntrl_out: process (state, player1_life, player2_life)

	begin
	reset_game  <= '0';
	reset_round <= '0';
	begin_round <= '0';
	starter     <= '0';
	load1       <= '0';
	load2       <= '0';
	player1_life_temp <= "00";
	player2_life_temp <= "00";
	menu_signal <= '0';
	new_round   <= '0';
	FIGHT       <= '0';

	winner_play1 <= '0';
	winner_play2 <= '0';

		case state is
			when MENU =>
				reset_game <= '1';
				reset_round <= '1';
				player1_life_temp <= "11";
				player2_life_temp <= "11";
				load1 <= '1';
				load2 <= '1';
				menu_signal <= '1';
			when START =>
				reset_round <= '1';
				begin_round <= '1';
				new_round   <= '1';
			when ROUND =>
				starter     <= '1';
				FIGHT       <= '1';
			when PLAY1CRASH =>
				player1_life_temp <= player1_life - 1;
				player2_life_temp <= player2_life;
				load1 <= '1';
			when PLAY2CRASH =>
				player1_life_temp <= player1_life;
				player2_life_temp <= player2_life -1;
				load2 <= '1';
			when BOTHCRASH =>
				player1_life_temp <= player1_life - 1;
				player2_life_temp <= player2_life -1;
				load1 <= '1';
				load2 <= '1';
			when BOTHLOSE =>
				reset_game  <= '0';
				reset_round <= '0';
				player1_life_temp <= player1_life + 1;
				player2_life_temp <= player2_life + 1;
				load1 <= '1';
				load2 <= '1';
			when PLAY1WIN =>
				--output player 1 win message and stop gameplay
				winner_play1 <= '1';
			when PLAY2WIN =>
				--output player 2 win message and stop gameplay
				winner_play2 <= '1';
			when others =>
				null;
		end case;
	end process;

	play1_lives <= player1_life;
	play2_lives <= player2_life;

end Behavioral;
