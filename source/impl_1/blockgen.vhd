-- new block generation logic, may need to be modified
-- needs some sort of "move complete" input and outputs a random address of an
-- empty block and a value

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity blockgen is
port (
    clk : in std_logic;
    move_complete : in std_logic;
    newblock_addr : out unsigned(3 downto 0);
    newblock_val : out unsigned(3 downto 0) -- 2 or 4
);
end;


architecture synth of blockgen is

-- RAM module
component ramdp is
generic (
	WORD_SIZE : natural := 4; -- Bits per word (read/write block size)
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


signal counter : unsigned(9 downto 0); -- Random value (10-bit, range 0-1023)
signal new_addr : unsigned(3 downto 0);
signal new_val : unsigned(3 downto 0);


begin

ram : ramdp 
port map(
    clk => clk,
    r_addr => new_addr,
    r_data => newblock_val,
    w_addr => newblock_addr,
    w_data => newblock_val,
    w_enable => move_complete
);


process (clk) is begin
    if rising_edge(clk) then
        counter <= counter + 1;
        if move_complete = '1' then
            new_addr <= counter(3 downto 0);

            while newblock_val /= 4d"0" loop
                new_addr <= new_addr + 1; -- goes to next free space
            end loop;

            new_val <= 4d"1" when counter < 10d"921" else 4d"2";

        end if;
    end if;
end process;

newblock_addr <= new_addr;
newblock_val <= new_val;

end;