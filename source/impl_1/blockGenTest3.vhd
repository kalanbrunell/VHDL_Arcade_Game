library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity blockgen is
port (
   clk : in std_logic;
   blockgen_enable : in std_logic; -- enable, should be set high when move is complete
   --moveDirection : unsigned(1 downto 0);

   blockGen_r_addr : in unsigned(3 downto 0);
   blockGen_r_data : in unsigned(3 downto 0);
   blockGen_w_addr : out unsigned(3 downto 0);
   blockGen_w_data : out unsigned(3 downto 0);
   blockGen_w_enable : out std_logic
);
end;

architecture synth of blockgen is
	signal start : std_logic;
	signal ramWait : std_logic;
	signal writeWait : std_logic;
	signal readFrom : unsigned(3 downto 0);
	signal counter : unsigned(2 downto 0) := "000";
begin

	--process(blockgen_enable) is
	--begin
		--if(rising_edge(blockgen_enable)) then
			--start <= '1';
		--end if;
	--end process;
	
	blockGen_w_data <= "0001" when(readFrom = "0001" or readFrom = "0000") else
					"0010" when(readFrom = "0010") else
					"0011" when(readFrom = "0011") else
					"0100" when(readFrom = "0100") else
					"0101" when(readFrom = "0101") else
					"0110" when(readFrom = "0110") else
					"0111" when(readFrom = "0111") else
					"1000" when(readFrom = "1000") else
					"1001" when(readFrom = "1001") else
					"1010" when(readFrom = "1010") else
					"1011" when(readFrom = "1011") else "0001";

	readFrom <= blockGen_r_data;
						
	
	
	process(clk) is
	begin
		
		if(rising_edge(clk)) then
			if blockgen_enable = '1'  then --and counter /= "111"`
					counter <= counter + 1;
					blockGen_w_enable <= '1';
			else
				
				blockGen_w_enable <= '0';
				counter <= "000";
			end if;
				
		
			
			--if(moveDirection = "00" or moveDirection = "01") then
				--if(ramWait = '0') then --we've started
				--	blockGen_w_enable <= '0';
			--		ramWait <= '1'; --we're waiting a cycle
			--	elsif(ramWait = '1') then --we have value from ram
					--if(blockGen_r_data = "0000") then --if its a zero
					--	blockGen_w_data <= "0001";
					--	blockGen_w_enable <= '1';
					--elsif(blockGen_r_data = "0001") then
			--		ramWait <= '0';
			--		readFrom <= blockGen_r_data;
			--		if(readFrom = "0000") then
			--			blockGen_w_data <= "0001";
			--			blockGen_w_enable <= '1';
			--		end if;
					
			--		if(blockGen_r_data = "0001") then
			--			blockGen_w_data <= "0001";
			--			blockGen_w_enable <= '1';
			--		elsif(blockGen_r_data = "0010") then
			--			blockGen_w_data <= "0010";
			--			blockGen_w_enable <= '1';
			--		elsif(blockGen_r_data = "0011") then
			--			blockGen_w_data <= "0011";
			--			blockGen_w_enable <= '1';
			--		elsif(blockGen_r_data = "0100") then
			--			blockGen_w_data <= "0100";
			--			blockGen_w_enable <= '1';
			--	elsif(blockGen_r_data = "0101") then
			--			blockGen_w_data <= "0101";
			--			blockGen_w_enable <= '1';
			--		elsif(blockGen_r_data = "0110") then
			--			blockGen_w_data <= "0110";
			--			blockGen_w_enable <= '1';
			--		else
			--			blockGen_w_data <= "0001";
			--			blockGen_w_enable <= '1';
			--		end if;
				--end if;
				
			--end if;
		end if;
	end process;
	--readFrom <= blockGen_r_data;
	--blockGen_r_addr <= "1111";
	blockGen_w_addr <= "1111";
	

end;