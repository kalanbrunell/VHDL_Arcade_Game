library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity blockgen is
port (
   clk : in std_logic;
   blockgen_enable : in std_logic; -- enable, should be set high when move is complete
   --complete : out std_logic := '0';

   blockGenr_addr : out unsigned(3 downto 0);
   blockGenr_data : in unsigned(3 downto 0);
   blockGenw_addr : out unsigned(3 downto 0);
   blockGenw_data : out unsigned(3 downto 0);
   blockGenw_enable : out std_logic
);
end;


architecture synth of blockgen is

   signal counter : unsigned(25 downto 0); 
   signal tempBlockGenr_addr : unsigned(3 downto 0) := "0000";
   signal tempBlockGenr_data : unsigned(3 downto 0);
   signal tempBlockGenw_addr : unsigned(3 downto 0);
   signal tempBlockGenw_data : unsigned(3 downto 0);
   signal tempBlockGenw_enable : std_logic := '1';
   signal complete : std_logic := '0';
   signal waiting : std_logic := '0';


begin
   process (clk) is begin
       if rising_edge(clk) then
           counter <= counter + 1;
           if counter(22) = '1' and complete = '0' and blockgen_enable = '1' then
               if waiting = '0' then
                   blockGenr_addr <= tempBlockGenr_addr;
                   blockGenw_enable <= '0';
               elsif waiting = '1' then
                   if blockGenr_data = "0000" then
                       blockGenw_addr <= tempBlockGenr_addr;
                       blockGenw_enable <= '1';
                       blockGenw_data <= "0001";
                       waiting <= '0';
                       complete <= '1';
                   else
                       waiting <= '0';
                       blockGenw_enable <= '0';
                       tempBlockGenr_addr <= tempBlockGenr_addr + 1;
                       complete <= '0';
                   end if;
               end if;
                  
           end if;
       end if;
   end process;

   --blockGenw_addr <= tempBlockGenw_addr;
   --blockGenw_data <= tempBlockGenw_data;
   --blockGenw_enable <= tempBlockGenw_enable;

end;
