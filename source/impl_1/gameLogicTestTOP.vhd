library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is 
    port(
	

		
		B1Out : out unsigned(1 downto 0);
		B2Out : out unsigned(1 downto 0);
		B3Out : out unsigned(1 downto 0);
		B4Out : out unsigned(1 downto 0);
		doubleBitIn : in unsigned(1 downto 0);
		
		done : out std_logic;
		tester : out std_logic;
		
		currentRowCol : in unsigned(1 downto 0);
		operating : in std_logic
		
    );
end top;

architecture synth of top is

	
	signal 	B1OutS :  unsigned(1 downto 0);
	signal 	B2OutS :  unsigned(1 downto 0);
	signal	B3OutS :  unsigned(1 downto 0);
	signal 	B4OutS :  unsigned(1 downto 0);
	signal doneCaller : std_logic := '0';
	signal enumerator : unsigned(28 downto 0);
	signal clk : std_logic;
	signal readAddressSig : unsigned(3 downto 0);
	signal blockFromRamSig : unsigned(1 downto 0);
	signal blockIntoRamSig : unsigned(1 downto 0);
	signal writeEnableSig : std_logic := '0';
	signal writeAddressSig : unsigned(3 downto 0);
	signal doneCall : std_logic := '0';
	
	signal testreadAddr : unsigned(3 downto 0);
	signal readAddrSwitch : unsigned(3 downto 0);
	signal wait_counter : integer range 0 to 2 := 0;
	type State is (WAITING, got1, got2, got3, resting);
	signal s : State := WAITING;
	signal holder1, holder2, holder3, holder4 : unsigned(1 downto 0);

	component gameLogicTop is
    port(
		clk : in std_logic;
        playerMoveIN : in unsigned(1 downto 0);
        testOut1 : out unsigned(1 downto 0);
        testOut2 : out unsigned(1 downto 0);
        testOut3 : out unsigned(1 downto 0);
        testOut4 : out unsigned(1 downto 0);

		
		grabbingBlockOutAddr : out unsigned(3 downto 0);
		grabbedBlockin : in unsigned(1 downto 0);
		writingBlockOut : out unsigned(1 downto 0);
		writeAddressOut : out unsigned(3 downto 0);
		writeEnableOut : out std_logic;

        startMove : in std_logic;
        turnComplete : out std_logic
    );
end component;
	

	
	component ramdp is
generic (
   WORD_SIZE : natural := 2; -- Bits per word (read/write block size)
     -- Each word stores a power as a 4-bit number since all values should be
     -- powers of 2. For example if we are storing a block with the number 64,
     -- we store "0110" instead of "00000100000" (will only go up to "1011")
   N_WORDS : natural := 16; -- Number of words in the memory
   ADDR_WIDTH : natural := 4 -- log2 of N_WORDS
  );	
		port(
		    clk : in std_logic;	
			r_addr : in unsigned(ADDR_WIDTH - 1 downto 0);
			r_data : out unsigned(WORD_SIZE - 1 downto 0);
			w_addr : in unsigned(ADDR_WIDTH - 1 downto 0);
			w_data : in unsigned(WORD_SIZE - 1 downto 0);
			w_enable : in std_logic
		);
	end component;
	

	
component HSOSC is
generic (
   CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2^N (0-3)
port(
   CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
   CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
   CLKHF : out std_logic := 'X'); -- Clock output
end component;


begin


clock : HSOSC
port map(
   CLKHFPU => '1',
   CLKHFEN => '1',
   CLKHF => clk
);


ramMod : ramdp
port map(
	clk => clk,
	r_addr => readAddrSwitch,
	r_data => blockFromRAMSig,
	w_addr => writeAddressSig,
	w_data => blockIntoRAMSig,
	w_enable => writeEnableSig
);


gameLogicTopMod : gameLogicTop
port map(
	clk => clk,
	playerMoveIN => doubleBitIn,
	testOut1 => B1OutS,
	testOut2 => B2OutS,
	testOut3 => B3OutS,
	testOut4 => B4OutS,
	turnComplete => done,
	
	startMove => doneCall,
	grabbingBlockOutAddr => readAddressSig,
	grabbedBlockin => blockFromRAMSig,
	
	
	writingBlockOut => blockIntoRAMSig,
	writeAddressOut => writeAddressSig,
	writeEnableOut => writeEnableSig


);





process(clk) begin 
	if rising_edge(clk) then 
		enumerator <= enumerator + 1;
			if enumerator(27) = '0' then 
					case s is
						when WAITING =>
							testreadAddr <= "00" & currentRowCol;
							holder1 <= blockFromRAMSig;
							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got1;         -- move to next state after 2 cycles
							end if;
									
						when got1 =>
							holder2 <= blockFromRAMSig;
							testreadAddr <= "01" & currentRowCol;

							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got2;         -- move to next state after 2 cycles
							end if;
										
						when got2 =>
							holder3 <= blockFromRAMSig;
							testreadAddr <= "10" & currentRowCol;
							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got3;         -- move to next state after 2 cycles
							end if;
										
						when got3 =>
							holder4 <= blockFromRAMSig;
							testreadAddr <= "11" & currentRowCol;
							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= resting;         -- move to next state after 2 cycles
							end if;
										

								
                        when resting =>				
							B1Out <= holder1;
							B2Out <= holder2;

							B3Out <= holder3;

							B4Out <= holder4;


							s <= WAITING;
              
                        end case;
		end if;
	end if;
end process;
--B1Out <= B1OutS;
--B2Out <= B2OutS;
--B3Out <= B3OutS;
--B4Out <= B4OutS;
doneCall <= enumerator(27);

tester <=  enumerator(27);
readAddrSwitch <= readAddressSig when (enumerator(27) = '1') else testreadAddr;
end synth;
