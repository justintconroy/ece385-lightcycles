------------------------------------------------------------------------------
--		Company:		UIUC ECE Dept.										--
--		Engineers:		David Ho											--
--						Justin Conroy										--
--																			--
--		Create Date:	07/17/2008											--
--		Design Name:	Keyboardr Unit										--
--		Module Name:	keyboard - Behavioral								--
--																			--
--		Comments:															--
--			This entity takes input from a keyboard and processes it into 	--
--			a key. If we press a key and hold it for a while, it will 		--
--			repeat. Occasionally while it is repeating, this will cause 	--
--			the shifter register to look like it is holding a different key.--
--			We use state machine so that it updates the current value of	--
--			the keycode only when we have read in the entire keycode.		--
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keyboard is
	Port( ps2data, ps2clk, clk, reset   : in std_logic;
	      keyCode                       : out std_logic_vector(7 downto 0);
	      break                         : out std_logic);
end keyboard;

architecture Behavioral of keyboard is

type control_state is(A, B, C, D, E, F, G, H, I, J, K);
	-- Since it is 11 bits, we need 11 states.

	component edge_detector is
		Port(	clk		: in std_logic;
				a		: in std_logic;
				edge	: out std_logic);
	end component;
	
	component reg_8 is
	Port (	Clk : in std_logic;
			Reset : in std_logic;
			D : in std_logic_vector(7 downto 0);
			Shift_In : in std_logic;
			Load : in std_logic;
			Shift_En : in std_logic;
			Shift_Out : out std_logic;
			Data_Out : out std_logic_vector(7 downto 0));
	end component;

	component reg_11 is
		Port ( Clk : in std_logic; 
			Reset : in std_logic; 
			D : in std_logic_vector(10 downto 0); 
			Shift_In : in std_logic; 
			Load : in std_logic; 
			Shift_En : in std_logic; 
			Shift_Out : out std_logic; 
			Data_Out : out std_logic_vector(10 downto 0)); 
	end component;

signal atob, edge, ld : std_logic;
signal AA, BB : std_logic_vector(7 downto 0);
signal state, next_state : control_state;

begin


	control_reg : process(Reset, edge, clk)
	begin
		if (Reset='1') then			--reset returns you to state
			state <= A;					--A (asynchronously).
		elsif (rising_edge(clk)) then		--if not resetting, go to the
			if (edge = '1') then				--next natural state.
				state <= next_state;
			end if;
		end if;
			end process;

		get_next_state: process(state)
		begin
			case state is
				when A =>
					next_state <= B;
				when B =>
					next_state <= C;
				when C =>
					next_state <= D;
				when D =>
					next_state <= E;
				when E =>
					next_state <= F;
				when F =>
					next_state <= G;
				when G =>
					next_state <= H;
				when H =>
					next_state <= I;
				when I =>
					next_state <= J;
				when J =>
					next_state <= K;
				when K =>
					next_state <= A;
			end case;
		end process;
		
		get_cntrl_out : process(edge, state, AA)
		begin
			case state is
				when A => -- Load the 8 bits only when it is in state A
					ld <= '1'; -- It helps to protect misdetecting
									-- when we press a wrong key for a while.
				when others => -- Do not load the 8 bits 
									-- when it is in other states.
					ld <= '0';
			end case;
		end process;
					
	ps_clk_edge : edge_detector
		Port map (	clk		=> clk,
					a		=> ps2clk,
					edge	=> edge);
	
	regA : reg_11
		Port map (	Clk						=> clk,
					Reset					=> reset,
					D						=> "00000000000",
					Shift_In				=> ps2data,
					Load					=> '0',
					Shift_En				=> edge,
					Shift_Out				=> atob,
					Data_Out(8 downto 1)	=> AA
		         );


	regB : reg_11
		Port map (	Clk						=> clk,
					Reset					=> reset,
					D						=> "00000000000",
					Shift_In				=> atob,
					Load					=> '0',
					Shift_En				=> edge,
					Data_Out(8 downto 1)	=> BB
		         );
	
	regC : reg_8
		Port map (	Clk						=> clk,
					Reset					=> reset,
					D						=> AA,
					Shift_In				=> 'X',
					Load					=> ld,
					Shift_En				=> '0',
					Data_Out				=> KeyCode);
	
--checks for xF0 in the second register. If it is present, then this is the
	--break code of key with the corresponding make code shown in register A.
	break	<=	'1' when BB = x"F0" else
				'0';	

end Behavioral;
