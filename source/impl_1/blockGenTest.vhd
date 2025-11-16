library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity blockGen is
	port(
		clk : in std_logic;
		enable : in std_logic;
		--reset : in std_logic;
		r_addr : out unsigned(3 downto 0);
		r_data : in unsigned(3 downto 0);
		w_addr : out unsigned(3 downto 0);
		w_data : out unsigned(3 downto 0);
		w_enable : out std_logic
		);
end;

architecture synth of blockGen is
	signal waitingForRead : std_logic;
	signal waitingForWrite : std_logic;
	signal final_addr : unsigned(3 downto 0);
	signal counter : unsigned(3 downto 0);
	signal init : unsigned(3 downto 0);
	signal foundAddress : std_logic;
	
	type state is (WAITING, LOOKING, WRITING);
	signal currentState : state;
	
begin
	
	
	
	process(clk, enable) is 
	begin
	
		if(enable = '0') then
			currentState <= WAITING;
			
		elsif(rising_edge(clk)) then	
			counter <= counter + 1;
			
			if(currentState = WAITING) then --Waiting to looking state
				if(enable = '1') then
					currentState <= LOOKING;
					init <= counter;
				end if;
			end if;
			
			if(currentState = LOOKING) then
			
				if(waitingForRead = '0') then
					r_addr <= counter + 1;
					waitingForRead <= '1';
					
				elsif(waitingForRead = '1') then
					if(r_data = "0000") then
						final_addr <= counter;
						currentState <= WRITING;
					else
						waitingForRead <= '0'; -- look for a new one
					end if;
				end if;
			end if;
			
			if(currentState = WRITING) then
				if(waitingForWrite = '0') then
					waitingForWrite <= '1';
					w_enable <= '1';
					w_addr <= final_addr;
					w_data <= "0001";
				elsif(waitingForWrite = '1') then
					waitingForWrite <= '0';
					w_enable <= '0';
					currentState <= WAITING;
					
				end if;
			end if;
		end if;
	end process;
end synth;
		