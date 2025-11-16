library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is 
	port(
		clk : in std_logic;
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		rowOut : out unsigned(9 downto 0);
		colOut : out unsigned(9 downto 0);
		valid : out std_logic
	);
	end;
	
architecture synth of vga is

	signal row : unsigned (9 downto 0);
	signal col : unsigned (9 downto 0);

	
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if col = 799 then
				col <= "0000000000";
				if row = 524 then
					row <= "0000000000";
				else
					row <= row + 1;	
				end if;
			else 
				col <= col + 1;
			end if;
			
			
		end if;
		
		if col >= 656 and col < 752 then -- 655 -> 752
				HSYNC <= '0';
				
			else
				HSYNC <= '1';
			end if;
			
			if row >= 490 and row < 492 then --490 -> 491
					VSYNC <= '0';
				else 
					VSYNC <= '1';
			end if;
			
		if col < 640 and row < 480 then
			valid <= '1';
		else
			valid <= '0';
		end if;
		
		rowOut <= row;
		colOut <= col;
		
	end process;
end synth;

