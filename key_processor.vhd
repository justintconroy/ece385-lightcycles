------------------------------------------------------------------------------
--		Company:		UIUC ECE Dept.										--
--		Engineers:		David Ho											--
--						Justin Conroy										--
--																			--
--		Create Date:	07/17/2008											--
--		Design Name:	Key Processor Unit									--
--		Module Name:	key_processor - Behavioral							--
--																			--
--		Comments:															--
--				Key Processor Unit detects z, x, and c by KeyCode. If you 	--
--				want to move your light cycle to left, you press z. 		--
--				If you want	to move	your light cycle to right, you press x. --
--				If you want to brake, you press c. If you want to start 	--
--				the game or the round, you press ENTER. By the 				--
--				case-statement, it determines which key was pressed	and 	--
--				if it was one of the keys used for Light Cycles, it outputs --
--				a dir_key_Pressection and makes key_press=1 while the key is still 	--
--				being pressed. If ENTER is pressed, enter_key = 1 so we can 	--
--				jump to the next state if we are in MENU or START state. 	--
--				If break=1, it means the key is released, so enter_key=0		--
--				and do nothing.												--
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity key_processor is
	port ( clk             : in std_logic;
	       reset           : in std_logic;
	       KeyCode         : in std_logic_vector(7 downto 0);
	       break           : in std_logic;

	       dir_key_Press   : out std_logic_vector(1 downto 0);
	       enter_key       : out std_logic); -- ENTER is pressed
end key_processor;

architecture Behavioral of key_processor is

	component reg is
		port( clk      : in std_logic;
		      reset    : in std_logic;
		      load     : in std_logic;
		      din      : in std_logic;

		      dout     : out std_logic
			);
	end component;

signal enter_wait, z_wait, x_wait : std_logic;
signal enter_wait_sig, z_wait_sig, x_wait_sig : std_logic;
signal loadz, loadx, loadenter : std_logic;

type ctrl_state is(RST,READ);
signal state, next_state :ctrl_state;

constant LEFT   : std_logic_vector(1 downto 0) := "10";
constant RIGHT  : std_logic_vector(1 downto 0) := "01";
constant BRAKE  : std_logic_vector(1 downto 0) := "11";
constant NONE   : std_logic_vector(1 downto 0) := "00";

begin
	
	reg_z : reg
	Port Map( clk    => clk,
	          reset  => reset,
			  load   => loadz,
			  din    => z_wait,
	          dout   => z_wait_sig
			);
	reg_x : reg
	Port Map( clk    => clk,
	          reset  => reset,
			  load   => loadx,
			  din    => x_wait,
	          dout   => x_wait_sig
			);
	reg_enter : reg
	Port Map( clk    => clk,
	          reset  => reset,
			  load   => loadenter,
			  din    => enter_wait,
	          dout   => enter_wait_sig
			);


	control_reg: process(reset, clk)
	begin
		if (reset ='1') then
			state <= RST;
		elsif(rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;

	get_next_state : process (state)
	begin
		case state is
			when RST =>
				next_state <= READ;
			when READ =>
				next_state <= READ;
		end case;
	end process;

	key : process(state,KeyCode, break,z_wait_sig,x_wait_sig,enter_wait_sig) is
	begin
	dir_key_Press  <= NONE;
	enter_key      <= '0';
	case state is
		when RST =>
			enter_wait <= '0';
			z_wait     <= '0';
			x_wait     <= '0';
			loadz      <= '1';
			loadx      <= '1';
			loadenter  <= '1';
		when READ =>
		--defaults
			loadz          <= '0';
			loadx          <= '0';
			loadenter      <= '0';
			z_wait         <= '0';
			x_wait         <= '0';
			enter_wait     <= '0';

		if (break = '1') then   --key was released

			case KeyCode is
				when x"1A" =>
					loadz     <= '1';
				when x"22" =>
					loadx     <= '1';
				when x"5A" =>
					loadenter <= '1';
				when others =>
					null;
			end case;
		else
			case KeyCode is
				when x"1A" =>   --If Z is pressed
					if(z_wait_sig = '1') then
						dir_key_Press <= NONE;
					else
						dir_key_Press <= LEFT;
						z_wait <= '1';
						loadz  <= '1';
					end if;
				when x"22" =>   --X is pressed
					if(x_wait_sig = '1') then
						dir_key_Press <= NONE;
					else
						dir_key_Press <= RIGHT;
						x_wait <= '1';
						loadx  <= '1';
					end if;
				when x"21" =>   --C is pressed
					dir_key_Press <= BRAKE;
				when x"5A" =>   --ENTER is pressed
					if(enter_wait_sig = '1') then
						enter_key  <= '0';
					else
						enter_key  <= '1';
						enter_wait <= '1';
						loadenter  <= '1';
					end if;
				when others =>
						enter_key <= '0';
						dir_key_Press <= NONE;
			end case;
		end if;
	end case;
	end process;
end Behavioral;
