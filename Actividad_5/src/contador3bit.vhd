library ieee;
use ieee.std_logic_1164.all;

entity contador3bit is
    port(
        A : in std_logic_vector (3 downto 0);
        y : out std_logic_vector (2 downto 0)
    );
end contador3bit;

architecture arch of contador3bit is
begin
    with A select y <=
    "001" when "0000",
    "010" when "0001",
    "011" when "0010",
    "100" when "0011",
    "101" when "0100",
    "110" when "0101",
    "111" when "0110",
    "000" when others; -- "111"

    
end arch;
    