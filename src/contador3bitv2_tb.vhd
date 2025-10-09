library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use work.all;

entity contador3bitv2_tb is
end contador3bitv2_tb;

architecture tb of contador3bitv2_tb is
    signal A : std_logic_vector (3 downto 0);
    signal y : std_logic_vector (2 downto 0);
begin
    DUT : entity contador3bitv2 port map (A => A, y => y);
    stim : process is
    begin
        A <= "0000";
        wait for 1 ns;
        A <= "0001";
        wait for 1 ns;
        A <= "0010";
        wait for 1 ns;
        A <= "0011";
        wait for 1 ns;
        A <= "0100";
        wait for 1 ns;
        A <= "0101";
        wait for 1 ns;
        A <= "0110";
        wait for 1 ns;
        A <= "0111";
        wait for 1 ns;
        A <= "1000";
        wait for 1 ns;
        A <= "1001";
        wait for 1 ns;
        A <= "1010";
        wait for 1 ns;
        A <= "1011";
        wait for 1 ns;
        A <= "1100";
        wait for 1 ns;
        A <= "1101";
        wait for 1 ns;
        A <= "1110";
        wait for 1 ns;
        A <= "1111";
        wait for 1 ns;
        wait for 1 ns; -- Punto adicional para que se vea bien la forma de onda
        finish;
    end process;
end tb;
