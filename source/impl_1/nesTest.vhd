library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nes is
	port(
		clk : in std_logic; --master project clock
		serial : in std_logic; --serial connection to NES controller
		latch : out std_logic; --latch connection to NES controller
		clockOut : out std_logic; --Clock to NES controller
		NESout : out std_logic_vector(4 downto 0) --NES key positions: start (4), up (3), down (2), left (1), right (0)
	);
end;



architecture synth of nes is
	signal s : std_logic;
	signal errorCycle : unsigned(1 downto 0);
	signal NESclk : std_logic;
	signal NEScount : unsigned(3 downto 0);
	signal counter : unsigned(25 downto 0);
	signal start_key : std_logic;
	signal up_key : std_logic;
	signal down_key : std_logic;
	signal left_key : std_logic;
	signal right_key : std_logic;
	signal keyPressed : std_logic;
	signal outputs : std_logic_vector(4 downto 0);
	signal temp0 : std_logic_vector(4 downto 0);
	signal temp1 : std_logic_vector(4 downto 0);
	signal temp2 : std_logic_vector(4 downto 0);
	
begin
	
	process (clk) is
	begin
		if rising_edge(clk) then
			counter <= counter + 1;
			if NEScount = "0011" then
				start_key <= '0' when (s = '1') else '1';
			end if;
			if NEScount = "0100" then
				up_key <= '0' when (s = '1') else '1';
			end if;
			if NEScount = "0101" then
				down_key <= '0' when (s = '1') else '1';
			end if;
			if NEScount = "0110" then
				left_key <= '0' when (s = '1') else '1';
			end if;
			if NEScount = "0111" then
				right_key <= '0' when (s = '1') else '1';
			end if;
			--ERROR CHECKING: Prevent small transient button presses by making sure it's held for at least 4 controller cycles. Otherwise - imply no buttons are pressed
			if NEScount = "1000" then
				if errorCycle = "00" then
					temp0 <= start_key & up_key & down_key & left_key & right_key;
				elsif errorCycle = "01" then
					temp1 <= start_key & up_key & down_key & left_key & right_key;
				elsif errorCycle = "10" then
					temp2 <= start_key & up_key & down_key & left_key & right_key;
				elsif errorCycle = "11" then
					if (temp1 = temp2) and (temp0 = temp1)  then --and ((temp0 = "00001") or (temp0 = "00010") or (temp0 = "00100") or (temp0 = "01000"))
						outputs <= temp0;
					else
						outputs <= "00000";
					end if;
				end if;
			end if;
			if NEScount = "1111" then
				nesOut <= outputs;
			end if;
		end if;
		
	end process;
	
	NESclk <= counter(8);
	NEScount <= counter(12 downto 9);
	errorCycle <= counter(14 downto 13);
	clockOut <= NESclk when (NEScount < 9) else '0';
	
	latch <=  '1' when (NEScount = "0000" or NEScount = "1111") else '0';
	
	s <= serial;
	
	
end synth;