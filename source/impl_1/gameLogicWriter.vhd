library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gameLogicWriter is
    port(
        clk : in std_logic;
		
        moveDirection : in unsigned(1 downto 0); --direction of move, left up right down (0, 1, 2, 3)
		rowCol : in unsigned(1 downto 0); --Which row or column is being written to. Constant through the operation and should not be changed until complete
		
        w_data : out unsigned(3 downto 0);
        w_addr : out unsigned(3 downto 0);
           
        data0 : in unsigned(3 downto 0);
        data1 : in unsigned(3 downto 0);    
        data2 : in unsigned(3 downto 0);
        data3 : in unsigned(3 downto 0);
 
        enable : in std_logic; -- when set to 1, storer must go through whole row or col
        complete : out std_logic -- high when storer is not doing something, until operating again
    );
end gameLogicWriter;

architecture synth of gameLogicWriter is
	signal counter : unsigned(1 downto 0);
	signal completeSignal : std_logic;
begin
	process(clk) is 
	begin
		if rising_edge(clk) then
		
			if(enable = '1' and completeSignal = '1' and counter = "00") then --"reset state"
				--counter <= "00";
				completeSignal <= '0';
			end if;
			if(enable = '1' and completeSignal = '0') then
				if(counter = "00") then
					--dependent on direction.
					--Memory address column:row
					if(moveDirection = "00") then --LEFT MOVE
						w_addr <= counter & rowCol;
						w_data <= data0;
					elsif(moveDirection = "01") then --UP MOVE
						w_addr <= rowCol & counter;
						w_data <= data0;
					elsif(moveDirection = "10") then --RIGHT MOVE
						w_addr <= counter & rowCol;
						w_data <= data3;
					elsif(moveDirection = "11") then --DOWN MOVE
						w_addr <= rowCol & counter;
						w_data <= data3;
					end if;
					
				elsif(counter = 1) then
					if(moveDirection = "00") then --LEFT MOVE
						w_addr <= counter & rowCol;
						w_data <= data1;
					elsif(moveDirection = "01") then --UP MOVE
						w_addr <= rowCol & counter;
						w_data <= data1;
					elsif(moveDirection = "10") then --RIGHT MOVE
						w_addr <= counter & rowCol;
						w_data <= data2;
					elsif(moveDirection = "11") then --DOWN MOVE
						w_addr <= rowCol & counter;
						w_data <= data2;
					end if;
				elsif(counter = 2) then
					if(moveDirection = "00") then --LEFT MOVE
						w_addr <= counter & rowCol;
						w_data <= data2;
					elsif(moveDirection = "01") then --UP MOVE
						w_addr <= rowCol & counter;
						w_data <= data2;
					elsif(moveDirection = "10") then --RIGHT MOVE
						w_addr <= counter & rowCol;
						w_data <= data1;
					elsif(moveDirection = "11") then --DOWN MOVE
						w_addr <= rowCol & counter;
						w_data <= data1;
					end if;
				elsif(counter = 3) then
					if(moveDirection = "00") then --LEFT MOVE
						w_addr <= counter & rowCol;
						w_data <= data3;
					elsif(moveDirection = "01") then --UP MOVE
						w_addr <= rowCol & counter;
						w_data <= data3;
					elsif(moveDirection = "10") then --RIGHT MOVE
						w_addr <= counter & rowCol;
						w_data <= data0;
					elsif(moveDirection = "11") then --DOWN MOVE
						w_addr <= rowCol & counter;
						w_data <= data0;
					end if;
					completeSignal <= '1';
				end if;
				--counter <= counter + 1;
			end if;
			counter <= counter + 1;
		end if;
	end process;
	complete <= completeSignal;

end;