library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gameLogicStorer is
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
end gameLogicStorer;

architecture synth of gameLogicStorer is

      signal currentRowCol : unsigned(1 downto 0) := "00"; -- reprents what row/col the logic is on.
      type State is (starting, stored1, stored2, stored3, stored4);
      signal s : State := starting;
      signal wait_counter : integer range 0 to 2 := 0;
      signal operatingSig : std_logic := '0';
      signal B1FinSig, B2FinSig, B3FinSig, B4FinSig : unsigned(3 downto 0);
      signal loadOnce : std_logic := '0';


      --testing signals
      signal doneSig : std_logic := '0'; -- done is an output and cannot be used in ifs below



begin




B1FinSig <= B1Fin when(playerMove = "00" or playerMove = "01") else B4Fin;
B2FinSig <= B2Fin when(playerMove = "00" or playerMove = "01") else B3Fin;
B3FinSig <= B3Fin when(playerMove = "00" or playerMove = "01") else B2Fin;
B4FinSig <= B4Fin when(playerMove = "00" or playerMove = "01") else B1Fin;
operatingSig <= operating;
process(clk) begin
      if rising_edge(clk) then
            if(operatingSig = '0') then
                  doneSig <= '0';                                                      
		s <= starting;

            elsif(operatingSig = '1' and doneSig = '0') then--- pertinent for move ordering!

                  -- case for if we are getting rows holder 1->4 goes left to right always
                if(playerMove = "00" or playerMove = "10") then
                              case s is
                              when starting =>
                                    w_addr <= "00" & currentRowCol;
                                    writingBlock <= B1FinSig;
                                if wait_counter < 2 then
                                        wait_counter <= wait_counter + 1;
                                else
                                        wait_counter <= 0; -- reset counter
                                        s <= stored1;         -- move to next state after 2 cycles
                                end if;
                              when stored1 =>
                                    w_addr <= "01" & currentRowCol;
                                    writingBlock <= B2FinSig;
                                if wait_counter < 2 then
                                        wait_counter <= wait_counter + 1;
                                else
                                        wait_counter <= 0; -- reset counter
                                        s <= stored2;         -- move to next state after 2 cycles
                                end if;
                              when stored2 =>
                                    w_addr <= "10" & currentRowCol;
                                    writingBlock <= B3FinSig;
                                if wait_counter < 2 then
                                         wait_counter <= wait_counter + 1;
                                else
                                        wait_counter <= 0; -- reset counter
                                        s <= stored3;         -- move to next state after 2 cycles
                                end if;
                              when stored3 =>
                                    w_addr <= "11" & currentRowCol;
                                    writingBlock <= B4FinSig;
                                if wait_counter < 2 then
                                        wait_counter <= wait_counter + 1;
                                else
                                        wait_counter <= 0; -- reset counter
                                        s <= stored4;         -- move to next state after 2 cycles
                                end if;
                              when stored4 =>
                                    currentRowCol <= currentRowCol + 1;
                                         doneSig <= '1';

                        end case;
				else
				case s is
                              when starting =>
                                    w_addr <= currentRowCol & "00";
                                    writingBlock <= B1FinSig;
                                if wait_counter < 2 then
                                        wait_counter <= wait_counter + 1;
                                else
                                        wait_counter <= 0; -- reset counter
                                	s <= stored1;         -- move to next state after 2 cycles
                                end if;
                              when stored1 =>
                                    w_addr <= currentRowCol & "01";
                                    writingBlock <= B2FinSig;
                                if wait_counter < 2 then
                                        wait_counter <= wait_counter + 1;
                                else
                                        wait_counter <= 0; -- reset counter
                                        s <= stored2;         -- move to next state after 2 cycles
                                end if;
                              when stored2 =>
                                    w_addr <= currentRowCol & "10";
                                    writingBlock <= B3FinSig;
                                if wait_counter < 2 then
                                         wait_counter <= wait_counter + 1;
                                else
                                        wait_counter <= 0; -- reset counter
                                        s <= stored3;         -- move to next state after 2 cycles
                                end if;
                              when stored3 =>
                                    w_addr <= currentRowCol& "11";
                                    writingBlock <= B4FinSig;
                                if wait_counter < 2 then
                                        wait_counter <= wait_counter + 1;
                                else
                                        wait_counter <= 0; -- reset counter
                                        s <= stored4;         -- move to next state after 2 cycles
                                end if;
                              when stored4 =>
                                    currentRowCol <= currentRowCol + 1;
                                         doneSig <= '1';
                        end case;
		end if;
            end if;
      end if;
end process;

done <= doneSig;



end synth;
