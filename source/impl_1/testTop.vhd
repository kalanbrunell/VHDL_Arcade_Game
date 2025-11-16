--Working top file

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity upduino2048 is
	port(
		clk : in std_logic; --CLOCK FROM MYPLL
		sCLK : out std_logic; --NES Controller Clock
		sLATCH : out std_logic; --NES Controller Latch
		SERIAL : in std_logic; --NES Controller Serial
		--VGA stuff:
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		rgb : out std_logic_vector(5 downto 0)
	);
end;

architecture synth of upduino2048 is
	signal testpin : std_logic;
	signal pllClock : std_logic;
	
	
	signal clockDivider : unsigned(3 downto 0);
	signal slowClock : std_logic;
	signal vgaActive : std_logic; -- Low = 
	signal gameState : std_logic; --Low = playing, high = game over
	signal moveActive : std_logic;
	signal moveComplete : std_logic;
	signal moveDirection : unsigned(1 downto 0);
	
	signal gameLogic_w_addr, gameLogic_w_data, blockGen_w_addr, blockGen_w_data : unsigned(3 downto 0);
	signal gameLogic_w_enable, blockGen_w_enable : std_logic;
	
	--RAM writing
	signal masterRAM_r_addr : unsigned(3 downto 0);
	signal masterRAM_r_data : unsigned(3 downto 0);
	signal masterRAM_w_addr : unsigned(3 downto 0);
	signal masterRAM_w_data : unsigned(3 downto 0);
	signal masterRAM_w_enable : std_logic;
	
	--RAM reading
	signal vgaRAM_r_addr : unsigned(3 downto 0);
	signal vgaRAM_r_data : unsigned(3 downto 0);
	signal stateRAM_r_addr : unsigned(3 downto 0);
	signal stateRAM_r_data : unsigned(3 downto 0);
	signal blockRAM_r_addr : unsigned(3 downto 0);
	signal blockRAM_r_data : unsigned(3 downto 0);

	
	component controller is
	port(
		clk : in std_logic;
		latch : out std_logic;
		clockOut : out std_logic;
		serial : in std_logic;
		moveActive : out std_logic;
		moveComplete : in std_logic;
		moveDirection : out unsigned(1 downto 0)
	);
	end component;
	
	component mypll is
	port(
		ref_clk_i: in std_logic;
		rst_n_i: in std_logic;
		outcore_o: out std_logic;
		outglobal_o: out std_logic
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
	
	component displayTop is 
	port(
		clkIn : in std_logic;
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		rgb : out std_logic_vector(5 downto 0);
		r_addr : out unsigned(3 downto 0);
		r_data : in unsigned(3 downto 0)
		--validOut : out std_logic
	);
	end component;
	
	--component losswinFSM is
	--port(
	--	clk : in std_logic; --Clock
	--	masterRAM_r_data : in unsigned (3 downto 0);
	--	masterRAM_r_addr : out unsigned (3 downto 0);
	--	gameOver : out std_logic --Goes high when you lose
	--);
	--end component;
	
	component gameLogicTop is
    port(
        clk : in std_logic;
        playerMoveIN : in unsigned(1 downto 0);

            
        grabbingBlockOutAddr : out unsigned(3 downto 0);
        grabbedBlockin : in unsigned(3 downto 0);
            

        startMove : in std_logic;
        turnComplete : out std_logic;
		
		writingBlockOut : out unsigned(3 downto 0);
		writeAddressOut : out unsigned(3 downto 0);
		writeEnableOut : out std_logic
		
    );
	end component;
	
	component blockGen is
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
	end component;
	
	
begin
	
	pllMap : mypll port map(
			ref_clk_i=> clk,
			rst_n_i=> '1',
			outcore_o=> testPin,
			outglobal_o=> pllClock
		);
	--RAM module for game logic to interact with
	gameRAM : ramdp port map(clk, masterRAM_r_addr, masterRAM_r_data, masterRAM_w_addr, masterRAM_w_data, masterRAM_w_enable);
	gameLogic : gameLogicTop port map(clk, moveDirection, masterRAM_r_addr, masterRAM_r_data, moveActive, moveComplete, gameLogic_w_data, gameLogic_w_addr, gameLogic_w_enable);
	
	masterRAM_w_data <= blockGen_w_data when (moveComplete = '1') else gameLogic_w_data;
	masterRAM_w_addr <= blockGen_w_addr when (moveComplete = '1') else gameLogic_w_addr;
	masterRAM_w_enable <= blockGen_w_enable when (moveComplete = '1') else gameLogic_w_enable;
	--RAM module for state machine
	--stateRAM : ramdp port map(clk, stateRAM_r_addr, stateRAM_r_data, masterRAM_w_addr, masterRAM_w_data, masterRAM_w_enable);
	--game state machine
	--losswinMachine : losswinFSM port map(clk, stateRAM_r_data, stateRAM_r_addr, gameState);
	
	--RAM module for VGA
	vgaRAM : ramdp port map(clk, vgaRAM_r_addr, vgaRAM_r_data, masterRAM_w_addr, masterRAM_w_data, masterRAM_w_enable);
	--VGA module
	VGA : displayTop port map(clk, HSYNC, VSYNC, rgb, vgaRAM_r_addr, vgaRAM_r_data);
	
	blockRAM : ramdp port map(clk, blockRAM_r_addr, blockRAM_r_data, masterRAM_w_addr, masterRAM_w_data, masterRAM_w_enable);
	blockGenerator : blockGen port map(clk, moveComplete, blockRAM_r_addr, blockRAM_r_data, blockGen_w_addr, blockGen_w_data, blockGen_w_enable);
	--NES controller
	NES : controller port map(clk, sLATCH, sCLK, SERIAL, moveActive, moveComplete, moveDirection);
	
	
end synth;
	