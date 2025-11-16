
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gameLogicFeeder is
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
        done : out std_logic := '0'
    );
end gameLogicFeeder;

architecture synth of gameLogicFeeder is

signal currentRowCol : unsigned(1 downto 0) := "00"; -- reprents what row/col the logic is on.
type State is (WAITING, got1, got2, got3, resting);
signal s : State := WAITING;
signal doneSig  : std_logic := '0';
signal holder1 : unsigned(3 downto 0);
signal holder2 : unsigned(3 downto 0);    
signal holder3 : unsigned(3 downto 0);
signal holder4 : unsigned(3 downto 0);
signal B1OutS,B2OutS,B3OutS,B4OutS : unsigned(3 downto 0);

signal wait_counter : integer range 0 to 2 := 0;




signal operatingSig : std_logic;
begin

operatingSig <= operating;



process(clk) begin
      if rising_edge(clk) then
            if(operatingSig = '0') then
                doneSig <= '0';
				s <= WAITING;
      
            elsif(operatingSig = '1' and doneSig = '0') then --- pertinent for move ordering!       
				
                  -- case for if we are getting rows holder 1->4 goes left to right always
                if(playerMove = "00" or playerMove = "10") then
                        
                        case s is
						when WAITING =>
							r_addr <= "00" & currentRowCol;
							holder1 <= grabbedBlock;
							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got1;         -- move to next state after 2 cycles
							end if;
									
						when got1 =>
							holder2 <= grabbedBlock;
							r_addr <= "01" & currentRowCol;

							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got2;         -- move to next state after 2 cycles
							end if;
										
						when got2 =>
							holder3 <= grabbedBlock;
							r_addr <= "10" & currentRowCol;
							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got3;         -- move to next state after 2 cycles
							end if;
										
						when got3 =>
							holder4 <= grabbedBlock;
							r_addr <= "11" & currentRowCol;
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
							currentRowCol <= currentRowCol + 1;
							doneSig <= '1';
                        end case;
						
            
                  else
					case s is
						when WAITING =>
							r_addr <= currentRowCol & "00";
							holder1 <= grabbedBlock;
							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got1;         -- move to next state after 2 cycles
							end if;
									
						when got1 =>
							holder2 <= grabbedBlock;
							r_addr <= currentRowCol & "01";

							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got2;         -- move to next state after 2 cycles
							end if;
										
						when got2 =>
							holder3 <= grabbedBlock;
							r_addr <= currentRowCol & "10";
							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= got3;         -- move to next state after 2 cycles
							end if;
										
						when got3 =>
							holder4 <= grabbedBlock;
							r_addr <= currentRowCol & "11";
							 if wait_counter < 2 then
								wait_counter <= wait_counter + 1;
							else
								wait_counter <= 0; -- reset counter
								s <= resting;         -- move to next state after 2 cycles
							end if;
										
                        when resting =>
							B1Out <= holder1 when(playerMove = "00" or playerMove = "01") else holder4;
							B2Out <= holder2 when(playerMove = "00" or playerMove = "01") else holder3;
							B3Out <= holder3 when(playerMove = "00" or playerMove = "01") else holder2;
							B4Out <= holder4 when(playerMove = "00" or playerMove = "01") else holder1;
							currentRowCol <= currentRowCol + 1;
							doneSig <= '1';
						end case;		
					end if;
            end if;
      end if;
end process;

done <= doneSig;







end synth;
