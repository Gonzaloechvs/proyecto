library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decod_7s is
    port(
        A : in std_logic_vector (3 downto 0);
        y : out std_logic_vector (6 downto 0)
    );
end decod_7s;

architecture arch of decod_7s is
begin
    with A select y <=

    "0111111" when "0000",
    "0000110" when "0001",
    "1011011" when "0010",
    "1001111" when "0011",
    "1100110" when "0100",
    "1101101" when "0101",
    "1111101" when "0110",
    "0000111" when "0111",
    "1111111" when "1000",
    "1101111" when "1001",
    "-------"  when others;
end arch;
