-- Basic dual-ported RAM module from ES4 course website
-- Modified for final project

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ramdp is
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
end;

architecture synth of ramdp is

type ramtype is array(N_WORDS - 1 downto 0) of
    unsigned(WORD_SIZE - 1 downto 0);
signal mem : ramtype;

begin
  process (clk) begin
	if rising_edge(clk) then
    -- Write into the memory if write enabled
  	if w_enable = '1' then
    		mem(to_integer(unsigned(w_addr))) <= w_data;
  	end if;
    -- Always read from the memory
    r_data <= mem(to_integer(unsigned(r_addr)));
	end if;
  end process;
end;
