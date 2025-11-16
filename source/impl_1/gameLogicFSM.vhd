library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gameLogicFSM is 
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
end gameLogicFSM;

architecture synth of gameLogicFSM is
    type State is (S1D2, S1D3, S1D4, S2D3, S2D4, S3D4, rept);
    signal s : State := S1D2;
	signal doneSig : std_logic := '1';
	signal loadOnce : std_logic := '0';
    signal B1_sig, B2_sig, B3_sig, B4_sig : unsigned(3 downto 0);


begin


	
	
	process(clk) 
	begin
		if rising_edge(clk) then
			if(operating = '0') then
                doneSig <= '0';
      
            elsif(operating = '1' and doneSig = '0') then --- pertinent for move ordering!    
				if(loadOnce = '0') then 
					
					B1_sig <= B1;
					B2_sig <= B2;
					B3_sig <= B3;
					B4_sig <= B4;
					s <= S1D2;
					loadOnce <= '1';
				else
					

                case s is 
                    when S1D2 => 
                        if (B2_sig = 0) then -- case where no comparison
                            s <= S1D3;
                        elsif (B1_sig /= 0 and B2_sig /= B1_sig and B2_sig /= 0) then -- case where 2 different adjacent blocks
                            s <= S2D3;
						elsif(B1_sig = 0 and B2_sig /= 0) then -- case where move to empty, check over same again 
							B1_sig <= B2_sig;
							B2_sig <= (others => '0');
							s <= S1D2; -- ADDED CASE
                        elsif (B1_sig = B2_sig and B1_sig /= 0) then -- case where combine, move to next look at. 
                            B1_sig <= B1_sig + 1;
                            B2_sig <= (others => '0');
                            s <= S2D3;
                        end if;

                    when S1D3 => 
                        if (B3_Sig = 0) then -- case where empty comparison 
                            s <= S1D4;
                        elsif (B1_sig = 0 and B3_sig /= 0) then -- case where empty move, recompare. 
                            B1_sig <= B3_sig;
                            B3_sig <= (others => '0');
                            s <= S1D2; -- PAY ATTENTION TO THIS
						elsif(B1_sig /= 0 and B1_sig /= B3_sig) then -- added block repositin case!
							B2_sig <= B3_sig;
							B3_sig <= (others => '0');
							s <= S2D3;
                        elsif (B1_sig /= 0 and B1_sig = B3_sig) then
                            B1_sig <= B1_sig + 1;
                            B3_sig <= (others => '0');
                            s <= S2D3;
                        end if;

                    when S1D4 =>
                        if (B4_sig = 0) then 
                            s <= rept;
                        elsif (B1_sig = 0 and B4_sig /= 0) then
                            B1_sig <= B4_sig;
                            B4_sig <= (others => '0');
                            s <= S1D2;
						elsif(B1_sig /= 0 and B1_sig /= B4_sig) then -- added block repositin case!
							B2_sig <= B4_sig;
							B4_sig <= (others => '0');
							s <= rept;
                        elsif (B1_sig /= 0 and B1_sig = B4_sig) then 
                            B1_sig <= B1_sig + 1;
                            B4_sig <= (others => '0');
                            s <= rept;
                        end if;

                    when S2D3 => 
                        if (B3_sig = 0) then
                            s <= S2D4;
                        elsif (B2_sig /= 0 and B2_sig /= B3_sig and B3_sig /= 0) then -- case where 2 diffwrent blocks
                            s <= S3D4;
						elsif (B2_sig = 0 and B2_sig /= B3_sig) then
							B2_sig <= B3_sig;
							B3_sig <= (others => '0');
                            s <= S2D3;
                        elsif (B2_sig = B3_sig and B2_sig /= 0) then
                            B2_sig <= B2_sig + 1;
                            B3_sig <= (others => '0');
                            s <= S3D4;
                        end if;

                    when S2D4 => 
                        if (B4_sig = 0) then
                            s <= rept;
                        elsif (B2_sig = 0 and B4_sig /= 0) then 
                            B2_sig <= B4_sig;
                            B4_sig <= (others => '0');
                            s <= rept;
						elsif(B2_sig /= 0 and B2_sig /= B4_sig and B4_Sig /= 0) then -- added block repositin case!
							B3_sig <= B4_sig;
							B4_sig <= (others => '0');
							s <= rept;
                        elsif (B2_sig /= 0 and B2_sig = B4_sig) then
                            B2_sig <= B2_sig + 1;
                            B4_sig <= (others => '0');
                            s <= rept;
						elsif (B2_sig /= 0 and B4_Sig = 0) then
							s <= rept;
                        end if;

                    when S3D4 =>
                        if (B4_sig = 0) then
                            s <= rept;
                        elsif (B3_sig /= B4_sig and B3_sig /= 0) then
                            s <= rept;
						elsif (B3_sig = 0 and B4_sig /= 0) then
							B3_sig <= B4_sig;
							B4_sig <= (others => '0');
                            s <= rept;
                        elsif (B3_sig = B4_sig and B3_sig /= 0) then 
                            B3_sig <= B3_sig + 1; 
                            B4_sig <= (others => '0');
                            s <= rept;
                        end if;

                    when rept =>
						B1F <= B1_Sig;
						B2F <= B2_Sig;
						B3F <= B3_Sig;
						B4F <= B4_Sig;
                        doneSig <= '1';
						loadOnce <= '0';
						s <= S1D2;

                end case;
				end if;
			end if;
        end if;
    end process;
	
	
done <= doneSig;


end synth;




