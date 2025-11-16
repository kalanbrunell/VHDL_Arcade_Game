library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gameLogicTop is
    port(
            clk : in std_logic;
        playerMoveIN : in unsigned(1 downto 0);

            
        grabbingBlockOutAddr : out unsigned(3 downto 0);
        grabbedBlockin : in unsigned(3 downto 0);
            

        startMove : in std_logic;
        turnComplete : out std_logic := '1';
		
		writingBlockOut : out unsigned(3 downto 0);
		writeAddressOut : out unsigned(3 downto 0);
		writeEnableOut : out std_logic
		
    );
end gameLogicTop;

architecture synth of gameLogicTop is

    -- Signals between modules
    signal B1Feed, B2Feed, B3Feed, B4Feed : unsigned(3 downto 0);
    signal B1Store, B2Store, B3Store, B4Store : unsigned(3 downto 0);
    signal feedOperating, logicOperating, storeOperating : std_logic := '0';
    signal feedDone, logicDone, storeDone : std_logic := '0';
    signal blockFromRAM, blockIntoRAM : unsigned(3 downto 0);
    signal write_address, read_address : unsigned(3 downto 0);
    signal write_enable : std_logic := '0';
	signal iterationCount : integer := 0;
	signal prevMove : std_logic := '0';
	signal outDoneSig : std_logic := '1';
    -- After computing, we latch the results here before outputting
    signal holder1, holder2, holder3, holder4 : unsigned(3 downto 0);

    -- State machine for the main logic
    type State is (feeding, computing, storing, done);
    signal s : State := feeding;




    -- For triggering cycles
    signal turnCompleteSig : std_logic := '1';

    component gameLogicFeeder is
        port(
            clk : in std_logic;
            playerMove : in unsigned(1 downto 0);
            grabbedBlock : in unsigned(3 downto 0);
            r_addr : out unsigned(3 downto 0);
            B1Out : out unsigned(3 downto 0);
            B2Out : out unsigned(3 downto 0);    
            B3Out : out unsigned(3 downto 0);
            B4Out : out unsigned(3 downto 0);
            operating : in std_logic;
            done : out std_logic
        );
    end component;



      component gamelogicFSM is
                  port(
                        clk : in std_logic;
                        B1 : in unsigned(3 downto 0);
                        B2 : in unsigned(3 downto 0);    
                        B3 : in unsigned(3 downto 0);
                        B4 : in unsigned(3 downto 0);

                        B1F : out unsigned(3 downto 0);
                        B2F : out unsigned(3 downto 0);    
                        B3F : out unsigned(3 downto 0);
                        B4F : out unsigned(3 downto 0);

                        operating : in std_logic;
                        done : out std_logic
                  );
            end component;
	component gameLogicStorer is
		port(
			clk : in std_logic;
			 playerMove : in unsigned(1 downto 0); --constant for whole turn
			writingBlock : out unsigned(3 downto 0);
			   
			w_addr : out unsigned(3 downto 0);
			   

			B1Fin : in unsigned(3 downto 0);
			B2Fin : in unsigned(3 downto 0);    
			B3Fin : in unsigned(3 downto 0);
			B4Fin : in unsigned(3 downto 0);
			   
			operating : in std_logic; -- when set to 1, storer must go through whole row or col
			done : out std_logic := '0' -- high when storer is not doing something, until operating again
		);
	end component;



begin

    feederMod : gameLogicFeeder
        port map (
            playerMove => playerMoveIn, -- UPDATE!!
            clk => clk,
            grabbedBlock => blockFromRAM,
            r_addr => read_address,
            B1Out => B1Feed,
            B2Out => B2Feed,
            B3Out => B3Feed,
            B4Out => B4Feed,
            operating => feedOperating,
            done => feedDone
        );

      
      logicMod : gamelogicFSM
        port map(
            clk => clk,
            B1 => B1Feed,
            B2 => B2Feed,
            B3 => B3Feed,
            B4 => B4Feed,
            B1F => B1Store,
            B2F => B2Store,
            B3F => B3Store,
            B4F => B4Store,
            operating => logicOperating,
            done => logicDone
        );
		
		
	storerMod : gameLogicStorer
		port map(
			playerMove => playerMoveIn,
			w_addr => writeAddressOut,
			writingBlock => writingBlockOut,
			clk => clk,
			B1Fin => B1Store,
			B2Fin => B2Store,
			B3Fin => B3Store,
			B4Fin => B4Store,
			operating => storeOperating,
			done => storeDone
		);
	


      blockFromRAM <= grabbedBlockIn;
      grabbingBlockOutAddr <= read_address;
      writeEnableOut <= write_enable;
   turnComplete <= outDoneSig;
    process(clk)
    begin
        if rising_edge(clk) then
		if(startMove = '0') then 
                turnCompleteSig <= '0';
		s <= feeding;
            elsif (startMove = '1' and turnCompleteSig = '0') then
                        
                case s is
                    when feeding =>
					
			outDoneSig <= '0';
                        feedOperating <= '1';
                        logicOperating <= '0';
                        storeOperating <= '0';
                        write_enable <= '0';

                       if feedDone = '1' then
                            s <= computing;
                        end if;

                when computing =>
                        feedOperating <= '0';
                        logicOperating <= '1';
                        storeOperating <= '0';
                        write_enable <= '0';
                        if logicDone = '1' then
                        	s <= storing;
                        end if;
		when storing => 
			feedOperating <= '0';
                        logicOperating <= '0';
                        storeOperating <= '1';
                        write_enable <= '1';
                           if storeDone = '1' then
                              s <= done;
                           end if;
						
                    when done =>
                        feedOperating <= '0';
                        logicOperating <= '0';
                        storeOperating <= '0';
                        write_enable <= '0';
						
			if iterationCount < 3 then 
				iterationCount <= iterationCount + 1;
				s <= feeding;
			else 
				iterationCount <= 0; 
				turnCompleteSig <= '1';
				outDoneSig <= '1';
			end if;
						
                end case;
                  
            end if;    
        end if;
    end process;


end synth;


