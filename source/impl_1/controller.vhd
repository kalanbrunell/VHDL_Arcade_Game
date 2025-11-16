library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller is
	port(
		clk : in std_logic;
		latch : out std_logic;
		clockOut : out std_logic;
		serial : in std_logic;
		moveActive : out std_logic;
		moveComplete : in std_logic;
		moveDirection : out unsigned(1 downto 0)
	);
end entity;

architecture synth of controller is
	signal nesOutputs : std_logic_vector(4 downto 0);
	signal moveAllowed : std_logic;
	signal counter : unsigned(25 downto 0);
	
	
	component nes is
		port(
			clk : in std_logic; --master project clock
			serial : in std_logic; --serial connection to NES controller
			latch : out std_logic; --latch connection to NES controller
			clockOut : out std_logic; --Clock to NES controller
			NESout : out std_logic_vector(4 downto 0) --NES key positions: start (4), up (3), down (2), left (1), right (0)
	);
	end component;
	
begin
	process(clk) is
	begin
		if(rising_edge(clk)) then
			counter <= counter + 1;
			-- reset moveActive if moveComplete is high
			--if moveComplete = '1' and moveActive = '1' then
			--if moveComplete = '1' then
			--	moveActive <= '0';
			--end if;
			
			
			

			if (moveActive = '0' and moveAllowed = '1') then
				if (nesOutputs(3) = '1') and (moveAllowed = '1') then --up
					moveActive <= '1';
					moveDirection <= "01";
				elsif (nesOutputs(2) = '1') and (moveAllowed = '1') then --down
					moveActive <= '1';
					moveDirection <= "11";
				elsif (nesOutputs(1) = '1') and (moveAllowed = '1') then --left
					moveActive <= '1';
					moveDirection <= "00";
				elsif (nesOutputs(0) = '1') and (moveAllowed = '1') then --right
					moveActive <= '1';
					moveDirection <= "10";
				end if;
			end if;
			
			
			if moveComplete = '1'  and moveActive = '1' then
				moveActive <= '0';
			end if;

			
		end if;
	end process;
	
	
	moveAllowed <= counter(22);
	controller1 : nes port map(clk, serial, latch, clockOut, nesOutputs);
end;