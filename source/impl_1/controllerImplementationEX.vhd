library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controllerTester is
	port(
		latch : out std_logic;
		clockOut : out std_logic;
		serial : in std_logic;
		moveActive : out std_logic;
		moveComplete : in std_logic;
		moveDirection : out std_logic_vector(1 downto 0)
	);
end entity;

architecture synth of controllerTester is
	signal clk : std_logic;
	
	component controller is
	port(
		clk : in std_logic;
		latch : out std_logic;
		clockOut : out std_logic;
		serial : in std_logic;
		moveActive : out std_logic;
		moveComplete : in std_logic;
		moveDirection : out std_logic_vector(1 downto 0)
	);
	end component;
	
	component HSOSC is
		generic (
			CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2ˆN (0-3)
		port(
			CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
			CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
			CLKHF : out std_logic := 'X'); -- Clock output
	end component;
	
begin
	osc : HSOSC generic map ( CLKHF_DIV => "0b00")
				port map (CLKHFPU => '1',
				CLKHFEN => '1',
				CLKHF => clk);
	NES : controller port map(clk, latch, clockOut, serial, moveActive, moveComplete, moveDirection);
	
end;