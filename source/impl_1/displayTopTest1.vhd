--USE WITH patternGenTesting2 and topTest. Passes moveComplete as refresh signal to patternGen

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity displayTop is 
	port(
		clkIn : in std_logic;
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		rgb : out std_logic_vector(5 downto 0);
		r_addr : out unsigned(3 downto 0);
		r_data : in unsigned(3 downto 0);
		refresh : in std_logic
		--validOut : out std_logic
	);
	end;
	
architecture synth of displayTop is 

	signal testPin : std_logic;
	signal clock : std_logic;
	signal rowTemp : unsigned(9 downto 0);
	signal colTemp : unsigned(9 downto 0);
	signal validTemp : std_logic;
	

	signal temptoVGARAM : unsigned(3 downto 0);
	signal tempfromVGARAM : unsigned(3 downto 0);
	
	signal tempBlockGenEnable : std_logic;
	signal blockGenComplete : std_logic;
	signal temptoBlockRAM : unsigned (3 downto 0);
	signal tempfromBlockRAM : unsigned (3 downto 0);


	component mypll is
	port(
		ref_clk_i: in std_logic;
		rst_n_i: in std_logic;
		outcore_o: out std_logic;
		outglobal_o: out std_logic
		);
	end component;
	
	
	component vga is 
	port(
		clk : in std_logic;
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		rowOut : out unsigned(9 downto 0);
		colOut : out unsigned(9 downto 0);
		valid : out std_logic
	);
	end component;
	
	component patternGenEX is 
	port(
		clk : in std_logic;
		row : in unsigned(9 downto 0);
		col : in unsigned(9 downto 0);
		valid : in std_logic;
		rgbFinal : out std_logic_vector(5 downto 0);
		toRAM : out unsigned(3 downto 0);
		fromRAM : in unsigned(3 downto 0);
		refreshTrigger : in std_logic
		
	);
	end component;
	
	


begin
		pllMap : mypll port map(
			ref_clk_i=> clkIn,
			rst_n_i=> '1',
			outcore_o=> testPin,
			outglobal_o=> clock
		);
		
		vgaMap : vga port map(
			clock, 
			HSYNC, 
			VSYNC, 
			rowTemp, 
			colTemp, 
			validTemp
		);
		
		patternGenMap : patternGenEX port map(
			clk=> clock, 
			row=> rowTemp, 
			col=> colTemp, 
			valid=>validTemp,
			rgbFinal=> rgb,
			toRAM=> r_addr,
			fromRAM=> r_data,
			refreshTrigger => refresh
		);
		 
		
end architecture;
