library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comparator is
	port(
		clk : in std_logic; --Clock
		enable : in std_logic;
		complete : out std_logic;
		ram1_block : in unsigned (3 downto 0);
		ram1_address : out unsigned (3 downto 0);
		ram2_block : in unsigned (3 downto 0);
		ram2_address : out unsigned (3 downto 0);
		comparison : out std_logic --Low = same, high = different
	);
end;

architecture synth of comparator is
	signal counter : unsigned(3 downto 0);
	signal running : std_logic;
begin
	process(clk) is
	begin
		if(rising_edge(clk)) then
			counter <= counter + 1;
			if(enable = '1' and running = '0') then --Starting process
				counter <= "0000";
				running <= '1';
				complete <= '0';
			end if;
			
			if(enable = '1' and running = '1') then --Running process
				ram1_address <= counter;
				ram2_address <= counter;
				
				if(ram1_block /= ram2_block) then --If they aren't the same, then they must be different - complete
					running <= '0';
					comparison <= '0';
					complete <= '1';
				end if;
			end if;
			
			if(enable = '1' and running = '1' and counter = "1111") then --Reached the end and all are the same
				running <= '0';
				complete <= '1';
				comparison <= '1';
			end if;
			
		end if;
	end process;
	
	
end;