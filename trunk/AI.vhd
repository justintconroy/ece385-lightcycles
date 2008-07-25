--AI test

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AI is
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
end AI;

architecture Behavioral of AI is

	component next_wall is
		Port( RED   : in std_logic_vector(9 downto 0);
		      GREEN : in std_logic_vector(9 downto 0);
		      BLUE  : in std_logic_vector(9 downto 0);

		      wall : out std_logic
	    );
	end component;

	component reg is
	Port ( Clk : in std_logic;
		Reset : in std_logic;
		din : in std_logic;
		Load : in std_logic;
		dout : out std_logic);
	end component;

    signal red_f,green_f,blue_f : std_logic_vector(9 downto 0);
    signal wall_f : std_logic;
    signal red_l,green_l,blue_l : std_logic_vector(9 downto 0);
    signal wall_l : std_logic;
    signal red_r,green_r,blue_r : std_logic_vector(9 downto 0);
    signal wall_r : std_logic;
	signal alt_load : std_logic;
	signal alternate : std_logic;
	signal alt : std_logic;

constant UP     : std_logic_vector(1 downto 0) := "11";
constant DOWN   : std_logic_vector(1 downto 0) := "00";
constant LEFT   : std_logic_vector(1 downto 0) := "01";
constant RIGHT  : std_logic_vector(1 downto 0) := "10";


begin
		wallfront : next_wall
		Port Map( RED   => red_f,
		          GREEN => green_f,
		          BLUE  => blue_f,

		          wall => wall_f);

		wallleft : next_wall
		Port Map( RED   => red_l,
		          GREEN => green_l,
		          BLUE  => blue_l,

		          wall => wall_l);

		wallright : next_wall
		Port Map( RED   => red_r,
		          GREEN => green_r,
		          BLUE  => blue_r,

		          wall => wall_r);

		alt_reg : reg
		Port map( Clk => clk,
		          Reset => '0',
		          din => alt,
		          Load => alt_load,
		          dout => alternate);

	direction_chooser : process(DIR,play_right_red,play_right_green,play_right_blue,play_left_red,play_left_green,play_left_blue,play_above_red,play_above_green,play_above_blue,play_below_red,play_below_green,play_below_blue,wall_r,wall_l,wall_f,alternate)
	begin
		--default
		red_l   <= "0000000000";
		green_l <= "0000000000";
		blue_l  <= "0000000000";
		red_r   <= "0000000000";
		green_r <= "0000000000";
		blue_r  <= "0000000000";
		alt <= '0';
		alt_load <= '0';

		if(DIR=RIGHT) then
			red_f    <= play_right_red;
			green_f  <= play_right_green;
			blue_f   <= play_right_blue;
		elsif(DIR=LEFT) then
			red_f    <= play_left_red;
			green_f  <= play_left_green;
			blue_f   <= play_left_blue;
		elsif(DIR=UP) then
			red_f    <= play_above_red;
			green_f  <= play_above_green;
			blue_f   <= play_above_blue;
		else
			red_f    <= play_below_red;
			green_f  <= play_below_green;
			blue_f   <= play_below_blue;
		end if;

	if(wall_f='1') then
		if(DIR=UP) then
			red_l    <= play_left_red;
			green_l  <= play_left_green;
			blue_l   <= play_left_blue;

			red_r    <= play_right_red;
			green_r  <= play_right_green;
			blue_r   <= play_right_blue;
			
			if(wall_l = '1') then
				dir_AI <= RIGHT;
			elsif(wall_r = '1') then
				dir_AI <= LEFT;
			else
                if(alternate = '0') then
					dir_AI <= LEFT;
					alt <= '1';
				else
					dir_AI <= RIGHT;
					alt <= '0';
				end if;
				alt_load <= '1';
			end if;
		elsif(DIR=DOWN) then
			red_l    <= play_right_red;
			green_l  <= play_right_green;
			blue_l   <= play_right_blue;

			red_r    <= play_left_red;
			green_r  <= play_left_green;
			blue_r   <= play_left_blue;

			if(wall_l = '1') then
				dir_AI <= LEFT;
			elsif(wall_r = '1') then
				dir_AI <= RIGHT;
			else
                if(alternate = '0') then
					dir_AI <= RIGHT;
					alt <= '1';
				else
					dir_AI <= LEFT;
					alt <= '0';
				end if;
				alt_load <= '1';
			end if;
		elsif(DIR=LEFT) then
			red_l    <= play_below_red;
			green_l  <= play_below_green;
			blue_l   <= play_below_blue;

			red_r    <= play_above_red;
			green_r  <= play_above_green;
			blue_r   <= play_above_blue;

			if(wall_l = '1') then
				dir_AI <= UP;
			elsif(wall_r = '1') then
				dir_AI <= DOWN;
			else
                if(alternate = '0') then
					dir_AI <= DOWN;
					alt <= '1';
				else
					dir_AI <= UP;
					alt <= '0';
				end if;
				alt_load <= '1';
			end if;
		else
			red_l    <= play_above_red;
			green_l  <= play_above_green;
			blue_l   <= play_above_blue;

			red_r    <= play_below_red;
			green_r  <= play_below_green;
			blue_r   <= play_below_blue;

			if(wall_l = '1') then
				dir_AI <= DOWN;
			elsif(wall_r = '1') then
				dir_AI <= UP;
			else
                if(alternate = '0') then
					dir_AI <= UP;
					alt <= '1';
				else
					dir_AI <= DOWN;
					alt <= '0';
				end if;
				alt_load <= '1';
			end if;
		end if;
	else
		dir_AI <= DIR;
	end if;
        end process;
end Behavioral;
