library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity blockgen is
port (
   clk : in std_logic;
   blockgen_enable : in std_logic; -- enable, should be set high when move is complete
   --moveDirection : unsigned(1 downto 0);

   blockGen_r_addr : out unsigned(3 downto 0);
   blockGen_r_data : in unsigned(3 downto 0);
   blockGen_w_addr : out unsigned(3 downto 0);
   blockGen_w_data : out unsigned(3 downto 0);
   blockGen_w_enable : out std_logic
);
end;


architecture synth of blockgen is
	signal counter : unsigned(3 downto 0);
	signal readRAM : std_logic;
	signal writeReady : std_logic;

	signal block0 : unsigned(3 downto 0);
	signal block1 : unsigned(3 downto 0);
	signal block2 : unsigned(3 downto 0);
	signal block3 : unsigned(3 downto 0);
	signal block4 : unsigned(3 downto 0);
	signal block5 : unsigned(3 downto 0);
	signal block6 : unsigned(3 downto 0);
	signal block7 : unsigned(3 downto 0);
	signal block8 : unsigned(3 downto 0);
	signal block9 : unsigned(3 downto 0);
	signal block10 : unsigned(3 downto 0);
	signal block11 : unsigned(3 downto 0);
	signal block12 : unsigned(3 downto 0);
	signal block13 : unsigned(3 downto 0);
	signal block14 : unsigned(3 downto 0);
	signal block15 : unsigned(3 downto 0);
	

begin
	process(clk) begin --reading values sequentially into signals
		if(rising_edge(clk)) then
			if(readRAM = '0') then
				blockGen_r_addr <= counter + 1;
				readRAM <= '1';
				
			end if;
		end if;
		
		if (rising_edge(clk) and readRAM = '1') then
			if(counter = "0000") then
				block0 <= blockGen_r_data;
			elsif(counter = 1) then
				block1 <= blockGen_r_data;
			elsif(counter = 2) then
				block2 <= blockGen_r_data;
			elsif(counter = 3) then
				block3 <= blockGen_r_data;
			elsif(counter = 4) then
				block4 <= blockGen_r_data;
			elsif(counter = 5) then
				block5 <= blockGen_r_data;
			elsif(counter = 6) then
				block6 <= blockGen_r_data;
			elsif(counter = 7) then
				block7 <= blockGen_r_data;
			elsif(counter = 8) then
				block8 <= blockGen_r_data;
			elsif(counter = 9) then
				block9 <= blockGen_r_data;
			elsif(counter = 10) then
				block10 <= blockGen_r_data;
			elsif(counter = 11) then
				block11 <= blockGen_r_data;
			elsif(counter = 12) then
				block12 <= blockGen_r_data;
			elsif(counter = 13) then
				block13 <= blockGen_r_data;
			elsif(counter = 14) then
				block14 <= blockGen_r_data;
			elsif(counter = 15) then
				block15 <= blockGen_r_data;
				writeReady <= '1';
			end if;
			
			counter <= counter + 1;
			
			readRAM <= '0';
		end if;
	end process;
	
	process(clk) is
	begin
		if(rising_edge(clk)) then
			if(blockgen_enable = '1' and writeReady = '1') then
				--writeReady <= '0';
		--		if(std_logic_vector(block15) = "0000") then
		--			blockGen_w_enable <= '1';
		--			blockGen_w_addr <= "1111";
		--			blockGen_w_data <= "0001";
				if((block15) = "1111") then
					blockGen_w_enable <= '1';
					blockGen_w_addr <= "1111";
					blockGen_w_data <= "0001";
		--		else
		--			blockGen_w_enable <= '1';
		--			blockGen_w_addr <= "1111";
		--			blockGen_w_data <= "0010";
				end if;
			else
				blockGen_w_enable <= '0';
			end if;
			
		end if;
	end process;
end;