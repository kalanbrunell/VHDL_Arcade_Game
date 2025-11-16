library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity losswinFSM is
	port(
		clk : in std_logic; --Clock
		masterRAM_r_data : in unsigned (3 downto 0);
		masterRAM_r_addr : out unsigned (3 downto 0);
		gameOver : out std_logic --Goes high when you lose
	);
end;

architecture synth of losswinFSM is
	signal counter : unsigned(25 downto 0);
	signal direction : unsigned(1 downto 0); --Same encoding as control inputs: 00 left 01 up 10 right 11 down
	signal change : std_logic;
	
	signal moveActive : std_logic; --interaction with game logic
	signal moveComplete : std_logic;
	
	signal compareEnable : std_logic;
	signal compareReady : std_logic;
	
	signal compare : std_logic; --low if different, high if the same
	signal leftPass : std_logic;
	signal upPass : std_logic;
	signal rightPass : std_logic;
	signal downPass : std_logic;
	signal allPass : std_logic;
	
	--Miles ram stuff
	signal fsmRAM_w_addr : unsigned(3 downto 0);
	signal fsmRAM_w_data : unsigned (3 downto 0);
	signal fsmRAM_w_enable : std_logic;
	
	
	--FSM ram stuff
	signal fsmRAM_r_addr : unsigned(3 downto 0);
	signal fsmRAM_r_data : unsigned(3 downto 0);
	
	component gameLogicTop is
    port(
            clk : in std_logic;
            playerMoveIN : in unsigned(1 downto 0);
            blockFromRAM : in unsigned (3 downto 0);
            blockIntoRAM : out unsigned(3 downto 0);
            write_address : out unsigned (3 downto 0);
            read_address : out unsigned (3 downto 0);
            writeEnableLogic : out std_logic;
            
            makeAMoveBuddy : in std_logic;  -- This should be set high when you want game logic to preform a move
            stupidAssSignalSoYouCanTellYoShitTurnIsCompleted : out std_logic := '1' -- High when game logic is NOT preforming a move
    );
	end component;
	
	
	component ramdp is
	generic (
    WORD_SIZE : natural := 4; -- Bits per word (read/write block size)
      -- Each word stores a power as a 4-bit number since all values should be
      -- powers of 2. For example if we are storing a block with the number 64,
      -- we store "0110" instead of "00000100000" (will only go up to "1011")
    N_WORDS : natural := 16; -- Number of words in the memory
    ADDR_WIDTH : natural := 4 -- log2 of N_WORDS
	);
	port (
    clk : in std_logic;
    r_addr : in unsigned(ADDR_WIDTH - 1 downto 0);
    r_data : out unsigned(WORD_SIZE - 1 downto 0);
    w_addr : in unsigned(ADDR_WIDTH - 1 downto 0);
    w_data : in unsigned(WORD_SIZE - 1 downto 0);
    w_enable : in std_logic
	);
	end component;
	
	component comparator is
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
	end component;

	
	
begin

	mover : gameLogicTop port map(clk, direction, masterRAM_r_data, fsmRAM_w_data, fsmRAM_w_addr, masterRAM_r_addr, fsmRAM_w_enable, moveActive, moveComplete);
	lossWinRAM : ramdp port map(clk, fsmRAM_r_addr, fsmRAM_r_data, fsmRAM_w_addr, fsmRAM_w_data, fsmRAM_w_enable);
	comparer : comparator port map(clk, compareEnable, compareReady, masterRAM_r_data, masterRAM_r_addr, fsmRAM_r_data, fsmRAM_r_addr, compare);
	
	process(clk) is
	begin
	if(rising_edge(clk)) then
		allPass <= leftPass or upPass or rightPass or downPass;
		gameOver <= not allPass;
		
		if(moveComplete = '0' and compareEnable = '0') then --Game mover is ready for another move
			direction <= direction + 1; --Get new direction
			moveActive <= '1'; --Turn on the mover
		end if;
		
		if(moveComplete = '1') then --move is finished.
			moveActive <= '0'; --Turn off the mover
			compareEnable <= '1'; --Turn on the comparator
		end if;
		
		if(compareEnable = '1' and compareReady = '1') then --Comparator has updated compare signal
			compareEnable <= '0'; --Turn it off!
			--Store what has passed or failed
			if(direction = 0) then
				leftPass <= compare;
			elsif(direction = 1) then
				upPass <= compare;
			elsif(direction = 2) then
				rightPass <= compare;
			elsif(direction = 3) then
				downPass <= compare;
			end if;
		end if;
		
	end if;
	end process;
	
end synth;
	