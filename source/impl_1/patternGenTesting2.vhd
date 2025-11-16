--IDENTICAL to patternGenFinal except requires an external trigger (refreshTrigger) to trigger reading from RAM. Will not refresh the ram values, until the trigger is passed

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity patternGenEX is 
	port(
		clk : in std_logic;
		row : in unsigned(9 downto 0);
		col : in unsigned(9 downto 0);
		valid : in std_logic;
		rgbFinal : out std_logic_vector(5 downto 0);
		
		toRAM : out unsigned(3 downto 0);
		fromRAM : in unsigned(3 downto 0);
		
		refreshTrigger : in std_logic
	);
end;
	
architecture synth of patternGenEX is
	
	signal reading : std_logic;
	
	signal temp : unsigned(9 downto 0) := "0000000000";
	signal counter : unsigned(3 downto 0) := "0000";
	signal fromRAMVal : unsigned(3 downto 0);
	signal changePos : std_logic;
	signal readRAM : std_logic;
	
	signal pxColOffset : unsigned(9 downto 0);
	signal pxRowOffset : unsigned(9 downto 0);
	signal blockPos : unsigned(3 downto 0);
	
	signal loc2 : std_logic_vector(15 downto 0);
	signal loc4 : std_logic_vector(15 downto 0);
	signal loc8 : std_logic_vector(15 downto 0);
	signal loc16 : std_logic_vector(15 downto 0);
	signal loc32 : std_logic_vector(15 downto 0);
	signal loc64 : std_logic_vector(15 downto 0);
	signal loc128 : std_logic_vector(15 downto 0);
	signal loc256 : std_logic_vector(15 downto 0);
	signal loc512 : std_logic_vector(15 downto 0);
	signal loc1024 : std_logic_vector(15 downto 0);
	signal loc2048 : std_logic_vector(15 downto 0);
	
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
	
	signal colOneOffset : unsigned(9 downto 0) := "0010010110"; --150
	signal colTwoOffset : unsigned(9 downto 0) := "0011100001"; --225
	signal colThreeOffset : unsigned(9 downto 0) := "0100101100"; --300
	signal colFourOffset : unsigned(9 downto 0) := "0101110111"; --375
	
	signal rowOneOffset : unsigned(9 downto 0) := "0001010000"; --80
	signal rowTwoOffset : unsigned(9 downto 0) := "0010100000"; --160
	signal rowThreeOffset : unsigned(9 downto 0) := "0011110000"; --240
	signal rowFourOffset : unsigned(9 downto 0) := "0101000000"; --320
	
	signal rgb : std_logic_vector(5 downto 0);
	
	signal backgroundRGB : std_logic_vector(5 downto 0);
	
	signal twoBlockRGB : std_logic_vector(5 downto 0);
	signal twoBlockColOff : unsigned(9 downto 0);
	signal twoBlockRowOff : unsigned(9 downto 0);
	
	signal fourBlockRGB : std_logic_vector(5 downto 0);
	signal fourBlockColOff : unsigned(9 downto 0);
	signal fourBlockRowOff : unsigned(9 downto 0);
	
	signal eightBlockRGB : std_logic_vector(5 downto 0);
	signal eightBlockColOff : unsigned(9 downto 0);
	signal eightBlockRowOff : unsigned(9 downto 0);
	
	signal sixteenBlockRGB : std_logic_vector(5 downto 0);
	signal sixteenBlockColOff : unsigned(9 downto 0);
	signal sixteenBlockRowOff : unsigned(9 downto 0);
	
	signal thirtyTwoBlockRGB : std_logic_vector(5 downto 0);
	signal thirtyTwoBlockColOff : unsigned(9 downto 0);
	signal thirtyTwoBlockRowOff : unsigned(9 downto 0);
	
	signal sixtyFourBlockRGB : std_logic_vector(5 downto 0);
	signal sixtyFourBlockColOff : unsigned(9 downto 0);
	signal sixtyFourBlockRowOff : unsigned(9 downto 0);
	
	signal oneTwentyEightBlockRGB : std_logic_vector(5 downto 0);
	signal oneTwentyEightBlockColOff : unsigned(9 downto 0);
	signal oneTwentyEightBlockRowOff : unsigned(9 downto 0);
	
	signal twoFiftySixBlockRGB : std_logic_vector(5 downto 0);
	signal twoFiftySixBlockColOff : unsigned(9 downto 0);
	signal twoFiftySixBlockRowOff : unsigned(9 downto 0);
	
	signal fiveTwelveBlockRGB : std_logic_vector(5 downto 0);
	signal fiveTwelveBlockColOff : unsigned(9 downto 0);
	signal fiveTwelveBlockRowOff : unsigned(9 downto 0);
	
	signal tenTwoFourBlockRGB : std_logic_vector(5 downto 0);
	signal tenTwoFourBlockColOff : unsigned(9 downto 0);
	signal tenTwoFourBlockRowOff : unsigned(9 downto 0);
	
	signal twentyFourtyEightBlockRGB : std_logic_vector(5 downto 0);
	signal twentyFourtyEightBlockColOff : unsigned(9 downto 0);
	signal twentyFourtyEightBlockRowOff : unsigned(9 downto 0);
	
	signal showTwoBlock : std_logic;
	signal twoBlockValid : std_logic;
	
	signal showFourBlock : std_logic;
	signal fourBlockValid : std_logic;
	
	signal showEightBlock : std_logic;
	signal eightBlockValid : std_logic;
	
	signal showSixteenBlock : std_logic;
	signal sixteenBlockValid : std_logic;
	
	signal showThirtyTwoBlock : std_logic;
	signal thirtyTwoBlockValid : std_logic;
	
	signal showSixtyFourBlock : std_logic;
	signal sixtyFourBlockValid : std_logic;
	
	signal showOneTwentyEightBlock : std_logic;
	signal oneTwentyEightBlockValid : std_logic;
	
	signal showTwoFiftySixBlock : std_logic;
	signal twoFiftySixBlockValid : std_logic;
	
	signal showFiveTwelveBlock : std_logic;
	signal fiveTwelveBlockValid : std_logic;
	
	signal showTenTwoFourBlock : std_logic;
	signal tenTwoFourBlockValid : std_logic;
	
	signal showTwentyFourtyEightBlock : std_logic;
	signal twentyFourtyEightBlockValid : std_logic;
	
	--ROM COMPONENT

	component backgroundRom is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			--rowOffset : in unsigned (9 downto 0);
			--colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component twoBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component fourBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component eightBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component sixteenBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component thirtyTwoBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component sixtyFourBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component oneTwentyEightBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component twoFiftySixBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component fiveTwelveBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component tenTwoFourBlockROM is 
		port(
			clk : in std_logic;
			rowIn : in unsigned(9 downto 0);
			colIn : in unsigned(9 downto 0);
			rowOffset : in unsigned (9 downto 0);
			colOffset : in unsigned (9 downto 0);
			rgbOut : out std_logic_vector(5 downto 0)
		);
	end component;
	

begin
	
	backgroundRomMap: backgroundRom port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		--rowOffset=> temp,
		--colOffset=> temp,
		rgbOut=> backgroundRGB
		);	
		
	twoBlockROMMap: twoBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> twoBlockRowOff,
		colOffset=> twoBlockColOff,
		rgbOut=> twoBlockRGB
		);	
		
	fourBlockROMMap: fourBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> fourBlockRowOff,
		colOffset=> fourBlockColOff,
		rgbOut=> fourBlockRGB
		);
		
	eightBlockROMMap: eightBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> eightBlockRowOff,
		colOffset=> eightBlockColOff,
		rgbOut=> eightBlockRGB
		);
		
	sixteenBlockROMMap: sixteenBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> sixteenBlockRowOff,
		colOffset=> sixteenBlockColOff,
		rgbOut=> sixteenBlockRGB
		);
		
	thirtyTwoBlockROMMap: thirtyTwoBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> thirtyTwoBlockRowOff,
		colOffset=> thirtyTwoBlockColOff,
		rgbOut=> thirtyTwoBlockRGB
		);
		
	sixtyFourBlockROMMap: sixtyFourBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> sixtyFourBlockRowOff,
		colOffset=> sixtyFourBlockColOff,
		rgbOut=> sixtyFourBlockRGB
		);
	
	oneTwentyEightBlockROMMap: oneTwentyEightBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> oneTwentyEightBlockRowOff,
		colOffset=> oneTwentyEightBlockColOff,
		rgbOut=> oneTwentyEightBlockRGB
		);
		
	twoFiftySixBlockROMMap: twoFiftySixBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> twoFiftySixBlockRowOff,
		colOffset=> twoFiftySixBlockColOff,
		rgbOut=> twoFiftySixBlockRGB
		);
		
	fiveTwelveBlockROMMap: fiveTwelveBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> fiveTwelveBlockRowOff,
		colOffset=> fiveTwelveBlockColOff,
		rgbOut=> fiveTwelveBlockRGB
		);
		
	tenTwoFourBlockROMMap: tenTwoFourBlockROM port map(
		clk=> clk,
		rowIn=> row,
		colIn=> col,
		rowOffset=> tenTwoFourBlockRowOff,
		colOffset=> tenTwoFourBlockColOff,
		rgbOut=> tenTwoFourBlockRGB
		);
		

	


	
	
	process(clk, refreshTrigger) begin --reading values sequentially into signals
	
			if(rising_edge(refreshTrigger) and counter /= 15) then
				reading <= '1';
			end if;
			
			if(rising_edge(clk) and reading = '1') then
				if(readRAM = '0') then
					toRam <= counter + 1;
					readRAM <= '1';		
				end if;
			end if;
		
			if (rising_edge(clk) and readRAM = '1') then
				if(counter = "0000") then
				block0 <= fromRAM;
				elsif(counter = 1) then
					block1 <= fromRAM;
				elsif(counter = 2) then
					block2 <= fromRAM;
				elsif(counter = 3) then
					block3 <= fromRAM;
				elsif(counter = 4) then
					block4 <= fromRAM;
				elsif(counter = 5) then
					block5 <= fromRAM;
				elsif(counter = 6) then
					block6 <= fromRAM;
				elsif(counter = 7) then
					block7 <= fromRAM;
				elsif(counter = 8) then
					block8 <= fromRAM;
				elsif(counter = 9) then
					block9 <= fromRAM;
				elsif(counter = 10) then
					block10 <= fromRAM;
				elsif(counter = 11) then
					block11 <= fromRAM;
				elsif(counter = 12) then
					block12 <= fromRAM;
				elsif(counter = 13) then
					block13 <= fromRAM;
				elsif(counter = 14) then
					block14 <= fromRAM;
				elsif(counter = 15) then
					block15 <= fromRAM;
					reading <= '0';
				end if;
			
			
				counter <= counter + 1;
				readRAM <= '0';
				
			end if;
	end process;
	
				
	process(clk) begin
		if (rising_edge(clk)) then
			if(col > colOneOffset and col < colTwoOffset and row > rowOneOffset and row < rowTwoOffset) then --POSITION 0
				pxColOffset <= colOneOffset;
				pxRowOffset <= rowOneOffset;
				blockPos <= "0000";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
		
			if(col > colOneOffset and col < colTwoOffset and row > rowTwoOffset and row < rowThreeOffset) then --POSITION 1
				pxColOffset <= colOneOffset;
				pxRowOffset <= rowTwoOffset;
				blockPos <= "0001";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
		
			if(col > colOneOffset and col < colTwoOffset and row > rowThreeOffset and row < rowFourOffset) then --POSITION 2
				pxColOffset <= colOneOffset;
				pxRowOffset <= rowThreeOffset;
				blockPos <= "0010";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
			if(col > colOneOffset and col < colTwoOffset and row > rowFourOffset) then --POSITION 3
				pxColOffset <= colOneOffset;
				pxRowOffset <= rowFourOffset;
				blockPos <= "0011";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
			--COLUMN 2
			if(col > colTwoOffset and col < colThreeOffset and row > rowOneOffset and row < rowTwoOffset) then --POSITION 4
				pxColOffset <= colTwoOffset;
				pxRowOffset <= rowOneOffset;
				blockPos <= "0100";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
		
			if(col > colTwoOffset and col < colThreeOffset and row > rowTwoOffset and row < rowThreeOffset) then --POSITION 5
				pxColOffset <= colTwoOffset;
				pxRowOffset <= rowTwoOffset;
				blockPos <= "0101";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
		
			if(col > colTwoOffset and col < colThreeOffset and row > rowThreeOffset and row < rowFourOffset) then --POSITION 6
				pxColOffset <= colTwoOffset;
				pxRowOffset <= rowThreeOffset;
				blockPos <= "0110";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
			
			if(col > colTwoOffset and col < colThreeOffset and row > rowFourOffset) then --POSITION 7
				pxColOffset <= colTwoOffset;
				pxRowOffset <= rowFourOffset;
				blockPos <= "0111";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
			--COl 3
			if(col > colThreeOffset and col < colFourOffset and row > rowOneOffset and row < rowTwoOffset) then --POSITION 8
				pxColOffset <= colThreeOffset;
				pxRowOffset <= rowOneOffset;
				blockPos <= "1000";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
		
			if(col > colThreeOffset and col < colFourOffset and row > rowTwoOffset and row < rowThreeOffset) then --POSITION 9
				pxColOffset <= colThreeOffset;
				pxRowOffset <= rowTwoOffset;
				blockPos <= "1001";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
		
			if(col > colThreeOffset and col < colFourOffset and row > rowThreeOffset and row < rowFourOffset) then --POSITION 10
				pxColOffset <= colThreeOffset;
				pxRowOffset <= rowThreeOffset;
				blockPos <= "1010";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
			if(col > colThreeOffset and col < colFourOffset and row > rowFourOffset) then --POSITION 11
				pxColOffset <= colThreeOffset;
				pxRowOffset <= rowFourOffset;
				blockPos <= "1011";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
			--COLUMN 4
			if(col > colFourOffset and row > rowOneOffset and row < rowTwoOffset) then --POSITION 12
				pxColOffset <= colFourOffset;
				pxRowOffset <= rowOneOffset;
				blockPos <= "1100";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
		
			if(col > colFourOffset and row > rowTwoOffset and row < rowThreeOffset) then --POSITION 12
				pxColOffset <= colFourOffset;
				pxRowOffset <= rowTwoOffset;
				blockPos <= "1101";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
		
			if(col > colFourOffset and row > rowThreeOffset and row < rowFourOffset) then --POSITION 14
				pxColOffset <= colFourOffset;
				pxRowOffset <= rowThreeOffset;
				blockPos <= "1110";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
			if(col > colFourOffset and row > rowFourOffset) then --POSITION 15
				pxColOffset <= colFourOffset;
				pxRowOffset <= rowFourOffset;
				blockPos <= "1111";
				if(loc2(to_integer(blockPos)) = '1') then
					twoBlockColOff <= pxColOffset;
					twoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '1';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc4(to_integer(blockPos)) = '1') then
					fourBlockValid <= '1';
					fourBlockColOff <= pxColOffset;
					fourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '1';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc8(to_integer(blockPos)) = '1') then
					eightBlockValid <= '1';
					eightBlockColOff <= pxColOffset;
					eightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '1';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc16(to_integer(blockPos)) = '1') then
					sixteenBlockColOff <= pxColOffset;
					sixteenBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '1';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc32(to_integer(blockPos)) = '1') then
					thirtyTwoBlockColOff <= pxColOffset;
					thirtyTwoBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '1';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				elsif(loc64(to_integer(blockPos)) = '1') then
					sixtyFourBlockColOff <= pxColOffset;
					sixtyFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '1';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc128(to_integer(blockPos)) = '1') then
					oneTwentyEightBlockColOff <= pxColOffset;
					oneTwentyEightBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '1';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc256(to_integer(blockPos)) = '1') then
					twoFiftySixBlockColOff <= pxColOffset;
					twoFiftySixBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '1';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc512(to_integer(blockPos)) = '1') then
					fiveTwelveBlockColOff <= pxColOffset;
					fiveTwelveBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '1';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc1024(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '1';
					twentyFourtyEightBlockValid <= '0';
					
				elsif(loc2048(to_integer(blockPos)) = '1') then
					tenTwoFourBlockColOff <= pxColOffset;
					tenTwoFourBlockRowOff <= pxRowOffset;
					
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '1';
				
				else
					twoBlockValid <= '0';
					fourBlockValid <= '0';
					eightBlockValid <= '0';
					sixteenBlockValid <= '0';
					thirtyTwoBlockValid <= '0';
					sixtyFourBlockValid <= '0';
					oneTwentyEightBlockValid <= '0';
					twoFiftySixBlockValid <= '0';
					fiveTwelveBlockValid <= '0';
					tenTwoFourBlockValid <= '0';
					twentyFourtyEightBlockValid <= '0';
				end if;
			end if;
			
			
			--More stuff below
			if twoBlockValid = '1' then
				if (twoBlockRGB > backgroundRGB) then
					showTwoBlock <= '1';
				else
					showTwoBlock <= '0';
				end if;
			end if;
			
			if fourBlockValid = '1' then
				if (fourBlockRGB > backgroundRGB) then
					showFourBlock <= '1';
				else
					showFourBlock <= '0';
				end if;
			end if;
		
			if eightBlockValid = '1' then
				if (eightBlockRGB > backgroundRGB) then
					showEightBlock <= '1';
				else
					showEightBlock <= '0';
				end if;
			end if;
			
			if sixteenBlockValid = '1' then
				if (sixteenBlockRGB > backgroundRGB) then
					showSixteenBlock <= '1';
				else
					showSixteenBlock <= '0';
				end if;
			end if;
			
			if thirtyTwoBlockValid = '1' then
				if (thirtyTwoBlockRGB > backgroundRGB) then
					showThirtyTwoBlock <= '1';
				else
					showThirtyTwoBlock <= '0';
				end if;
			end if;
			
			if sixtyFourBlockValid = '1' then
				if (sixtyFourBlockRGB > backgroundRGB) then
					showSixtyFourBlock <= '1';
				else
					showSixtyFourBlock <= '0';
				end if;
			end if;
			
			if oneTwentyEightBlockValid = '1' then
				if (oneTwentyEightBlockRGB > backgroundRGB) then
					showOneTwentyEightBlock <= '1';
				else
					showOneTwentyEightBlock <= '0';
				end if;
			end if;
			
			if twoFiftySixBlockValid = '1' then
				if (twoFiftySixBlockRGB > backgroundRGB) then
					showTwoFiftySixBlock <= '1';
				else
					showTwoFiftySixBlock <= '0';
				end if;
			end if;
			
			if fiveTwelveBlockValid = '1' then
				if (fiveTwelveBlockRGB > backgroundRGB) then
					showFiveTwelveBlock <= '1';
				else
					showFiveTwelveBlock <= '0';
				end if;
			end if;
			
			if tenTwoFourBlockValid = '1' then
				if (tenTwoFourBlockRGB > backgroundRGB) then
					showTenTwoFourBlock <= '1';
				else
					showTenTwoFourBlock <= '0';
				end if;
			end if;
			
			if twentyFourtyEightBlockValid = '1' then
				if (twentyFourtyEightBlockRGB > backgroundRGB) then
					showTwentyFourtyEightBlock <= '1';
				else
					showTwentyFourtyEightBlock <= '0';
				end if;
			end if;
			
			
			
			
		end if;
	end process;
	
	
	process(clk) begin --
		if (rising_edge(clk)) then
			if showTwoBlock = '1' then
				rgb <= twoBlockRGB;
			elsif showFourBlock = '1' then
				rgb <= fourBlockRGB;
			elsif showEightBlock = '1' then
				rgb <= eightBlockRGB;
			elsif showSixteenBlock = '1' then
				rgb <= sixteenBlockRGB;
			elsif showThirtyTwoBlock = '1' then
				rgb <= thirtyTwoBlockRGB;
			elsif showSixtyFourBlock = '1' then
				rgb <= sixtyFourBlockRGB;
			elsif showOneTwentyEightBlock = '1' then
				rgb <= oneTwentyEightBlockRGB;
			elsif showTwoFiftySixBlock = '1' then
				rgb <= twoFiftySixBlockRGB;
			elsif showFiveTwelveBlock = '1' then
				rgb <= fiveTwelveBlockRGB;
			elsif showTenTwoFourBlock = '1' then
				rgb <= tenTwoFourBlockRGB;
			--2048 RGB here
			else 
				rgb <= backgroundRGB;
			end if;
		end if;
	end process;
	
	--ASSIGN WHERE 2s are
		loc2(0) <= '1' when block0 = 1 else '0';
	loc2(1) <= '1' when block1 = 1 else '0';
	loc2(2) <= '1' when block2 = 1 else '0';
	loc2(3) <= '1' when block3 = 1 else '0';
	loc2(4) <= '1' when block4 = 1 else '0';
	loc2(5) <= '1' when block5 = 1 else '0';
	loc2(6) <= '1' when block6 = 1 else '0';
	loc2(7) <= '1' when block7 = 1 else '0';
	loc2(8) <= '1' when block8 = 1 else '0';
	loc2(9) <= '1' when block9 = 1 else '0';
	loc2(10) <= '1' when block10 = 1 else '0';
	loc2(11) <= '1' when block11 = 1 else '0';
	loc2(12) <= '1' when block12 = 1 else '0';
	loc2(13) <= '1' when block13 = 1 else '0';
	loc2(14) <= '1' when block14 = 1 else '0';
	loc2(15) <= '1' when block15 = 1 else '0';
	
	loc4(0) <= '1' when block0 = 2 else '0';
	loc4(1) <= '1' when block1 = 2 else '0';
	loc4(2) <= '1' when block2 = 2 else '0';
	loc4(3) <= '1' when block3 = 2 else '0';
	loc4(4) <= '1' when block4 = 2 else '0';
	loc4(5) <= '1' when block5 = 2 else '0';
	loc4(6) <= '1' when block6 = 2 else '0';
	loc4(7) <= '1' when block7 = 2 else '0';
	loc4(8) <= '1' when block8 = 2 else '0';
	loc4(9) <= '1' when block9 = 2 else '0';
	loc4(10) <= '1' when block10 = 2 else '0';
	loc4(11) <= '1' when block11 = 2 else '0';
	loc4(12) <= '1' when block12 = 2 else '0';
	loc4(13) <= '1' when block13 = 2 else '0';
	loc4(14) <= '1' when block14 = 2 else '0';
	loc4(15) <= '1' when block15 = 2 else '0';
	
	loc8(0) <= '1' when block0 = 3 else '0';
	loc8(1) <= '1' when block1 = 3 else '0';
	loc8(2) <= '1' when block2 = 3 else '0';
	loc8(3) <= '1' when block3 = 3 else '0';
	loc8(4) <= '1' when block4 = 3 else '0';
	loc8(5) <= '1' when block5 = 3 else '0';
	loc8(6) <= '1' when block6 = 3 else '0';
	loc8(7) <= '1' when block7 = 3 else '0';
	loc8(8) <= '1' when block8 = 3 else '0';
	loc8(9) <= '1' when block9 = 3 else '0';
	loc8(10) <= '1' when block10 = 3 else '0';
	loc8(11) <= '1' when block11 = 3 else '0';
	loc8(12) <= '1' when block12 = 3 else '0';
	loc8(13) <= '1' when block13 = 3 else '0';
	loc8(14) <= '1' when block14 = 3 else '0';
	loc8(15) <= '1' when block15 = 3 else '0';
	
	loc16(0) <= '1' when block0 = 4 else '0';
	loc16(1) <= '1' when block1 = 4 else '0';
	loc16(2) <= '1' when block2 = 4 else '0';
	loc16(3) <= '1' when block3 = 4 else '0';
	loc16(4) <= '1' when block4 = 4 else '0';
	loc16(5) <= '1' when block5 = 4 else '0';
	loc16(6) <= '1' when block6 = 4 else '0';
	loc16(7) <= '1' when block7 = 4 else '0';
	loc16(8) <= '1' when block8 = 4 else '0';
	loc16(9) <= '1' when block9 = 4 else '0';
	loc16(10) <= '1' when block10 = 4 else '0';
	loc16(11) <= '1' when block11 = 4 else '0';
	loc16(12) <= '1' when block12 = 4 else '0';
	loc16(13) <= '1' when block13 = 4 else '0';
	loc16(14) <= '1' when block14 = 4 else '0';
	loc16(15) <= '1' when block15 = 4 else '0';
	
	loc32(0) <= '1' when block0 = 5 else '0';
	loc32(1) <= '1' when block1 = 5 else '0';
	loc32(2) <= '1' when block2 = 5 else '0';
	loc32(3) <= '1' when block3 = 5 else '0';
	loc32(4) <= '1' when block4 = 5 else '0';
	loc32(5) <= '1' when block5 = 5 else '0';
	loc32(6) <= '1' when block6 = 5 else '0';
	loc32(7) <= '1' when block7 = 5 else '0';
	loc32(8) <= '1' when block8 = 5 else '0';
	loc32(9) <= '1' when block9 = 5 else '0';
	loc32(10) <= '1' when block10 = 5 else '0';
	loc32(11) <= '1' when block11 = 5 else '0';
	loc32(12) <= '1' when block12 = 5 else '0';
	loc32(13) <= '1' when block13 = 5 else '0';
	loc32(14) <= '1' when block14 = 5 else '0';
	loc32(15) <= '1' when block15 = 5 else '0';
	
	loc64(0) <= '1' when block0 = 6 else '0';
	loc64(1) <= '1' when block1 = 6 else '0';
	loc64(2) <= '1' when block2 = 6 else '0';
	loc64(3) <= '1' when block3 = 6 else '0';
	loc64(4) <= '1' when block4 = 6 else '0';
	loc64(5) <= '1' when block5 = 6 else '0';
	loc64(6) <= '1' when block6 = 6 else '0';
	loc64(7) <= '1' when block7 = 6 else '0';
	loc64(8) <= '1' when block8 = 6 else '0';
	loc64(9) <= '1' when block9 = 6 else '0';
	loc64(10) <= '1' when block10 = 6 else '0';
	loc64(11) <= '1' when block11 = 6 else '0';
	loc64(12) <= '1' when block12 = 6 else '0';
	loc64(13) <= '1' when block13 = 6 else '0';
	loc64(14) <= '1' when block14 = 6 else '0';
	loc64(15) <= '1' when block15 = 6 else '0';
	
	loc128(0) <= '1' when block0 = 7 else '0';
	loc128(1) <= '1' when block1 = 7 else '0';
	loc128(2) <= '1' when block2 = 7 else '0';
	loc128(3) <= '1' when block3 = 7 else '0';
	loc128(4) <= '1' when block4 = 7 else '0';
	loc128(5) <= '1' when block5 = 7 else '0';
	loc128(6) <= '1' when block6 = 7 else '0';
	loc128(7) <= '1' when block7 = 7 else '0';
	loc128(8) <= '1' when block8 = 7 else '0';
	loc128(9) <= '1' when block9 = 7 else '0';
	loc128(10) <= '1' when block10 = 7 else '0';
	loc128(11) <= '1' when block11 = 7 else '0';
	loc128(12) <= '1' when block12 = 7 else '0';
	loc128(13) <= '1' when block13 = 7 else '0';
	loc128(14) <= '1' when block14 = 7 else '0';
	loc128(15) <= '1' when block15 = 7 else '0';
	
	loc256(0) <= '1' when block0 = 8 else '0';
	loc256(1) <= '1' when block1 = 8 else '0';
	loc256(2) <= '1' when block2 = 8 else '0';
	loc256(3) <= '1' when block3 = 8 else '0';
	loc256(4) <= '1' when block4 = 8 else '0';
	loc256(5) <= '1' when block5 = 8 else '0';
	loc256(6) <= '1' when block6 = 8 else '0';
	loc256(7) <= '1' when block7 = 8 else '0';
	loc256(8) <= '1' when block8 = 8 else '0';
	loc256(9) <= '1' when block9 = 8 else '0';
	loc256(10) <= '1' when block10 = 8 else '0';
	loc256(11) <= '1' when block11 = 8 else '0';
	loc256(12) <= '1' when block12 = 8 else '0';
	loc256(13) <= '1' when block13 = 8 else '0';
	loc256(14) <= '1' when block14 = 8 else '0';
	loc256(15) <= '1' when block15 = 8 else '0';
	
	loc512(0) <= '1' when block0 = 9 else '0';
	loc512(1) <= '1' when block1 = 9 else '0';
	loc512(2) <= '1' when block2 = 9 else '0';
	loc512(3) <= '1' when block3 = 9 else '0';
	loc512(4) <= '1' when block4 = 9 else '0';
	loc512(5) <= '1' when block5 = 9 else '0';
	loc512(6) <= '1' when block6 = 9 else '0';
	loc512(7) <= '1' when block7 = 9 else '0';
	loc512(8) <= '1' when block8 = 9 else '0';
	loc512(9) <= '1' when block9 = 9 else '0';
	loc512(10) <= '1' when block10 = 9 else '0';
	loc512(11) <= '1' when block11 = 9 else '0';
	loc512(12) <= '1' when block12 = 9 else '0';
	loc512(13) <= '1' when block13 = 9 else '0';
	loc512(14) <= '1' when block14 = 9 else '0';
	loc512(15) <= '1' when block15 = 9 else '0';
	
	loc1024(0) <= '1' when block0 = 10 else '0';
	loc1024(1) <= '1' when block1 = 10 else '0';
	loc1024(2) <= '1' when block2 = 10 else '0';
	loc1024(3) <= '1' when block3 = 10 else '0';
	loc1024(4) <= '1' when block4 = 10 else '0';
	loc1024(5) <= '1' when block5 = 10 else '0';
	loc1024(6) <= '1' when block6 = 10 else '0';
	loc1024(7) <= '1' when block7 = 10 else '0';
	loc1024(8) <= '1' when block8 = 10 else '0';
	loc1024(9) <= '1' when block9 = 10 else '0';
	loc1024(10) <= '1' when block10 = 10 else '0';
	loc1024(11) <= '1' when block11 = 10 else '0';
	loc1024(12) <= '1' when block12 = 10 else '0';
	loc1024(13) <= '1' when block13 = 10 else '0';
	loc1024(14) <= '1' when block14 = 10 else '0';
	loc1024(15) <= '1' when block15 = 10 else '0';
	
	loc2048(0) <= '1' when block0 = 11 else '0';
	loc2048(1) <= '1' when block1 = 11 else '0';
	loc2048(2) <= '1' when block2 = 11 else '0';
	loc2048(3) <= '1' when block3 = 11 else '0';
	loc2048(4) <= '1' when block4 = 11 else '0';
	loc2048(5) <= '1' when block5 = 11 else '0';
	loc2048(6) <= '1' when block6 = 11 else '0';
	loc2048(7) <= '1' when block7 = 11 else '0';
	loc2048(8) <= '1' when block8 = 11 else '0';
	loc2048(9) <= '1' when block9 = 11 else '0';
	loc2048(10) <= '1' when block10 = 11 else '0';
	loc2048(11) <= '1' when block11 = 11 else '0';
	loc2048(12) <= '1' when block12 = 11 else '0';
	loc2048(13) <= '1' when block13 = 11 else '0';
	loc2048(14) <= '1' when block14 = 11 else '0';
	loc2048(15) <= '1' when block15 = 11 else '0';
	

	rgbFinal <= rgb when (valid = '1') else "000000";
end architecture;