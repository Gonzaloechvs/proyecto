library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use work.all;

entity contador3bit is
    port(
        A : in std_logic_vector (3 downto 0);
        y : out std_logic_vector (2 downto 0)
    );
end contador3bit;

architecture tb of contador3bit_tb is
    signal A : std_logic_vector (3 downto 0);
    signal y : std_logic_vector (2 downto 0);
begin
    DUT : entity contador3bit port map (A => A, y => y);
    stim : process is
    begin
        A[0] <= '0';
        A[1] <= '0';
        A[2] <= '0';
        A[3] <= '0';
        wait for 1 ns;
        A[0] <= '1';
        wait for 1 ns;
        A[1] <= '1';
        wait for 1 ns;
        A[0] <= '0';
        wait for 1 ns;
        A[2] <= '1';
        A[1] <= '0';
        wait for 1 ns;
        A[0] <= '1';
        wait for 1 ns;
        A[1] <= '1';
        wait for 1 ns;
        A[0] <= '0';
        wait for 1 ns;
        A[3] <= '1';
        A[2] <= '0';
        A[1] <= '0';
        A[0] <= '0';
        wait for 1 ns;
        A[0] <= '1';
        wait for 1 ns;
        A[1] <= '1';
        wait for 1 ns;
        A[0] <= '0';
        wait for 1 ns;
        A[2] <= '1';
        A[1] <= '0';
        wait for 1 ns;
        A[0] <= '1';
        wait for 1 ns;
        A[1] <= '1';
        wait for 1 ns;
        A[0] <= '0';
        wait for 1 ns;
        wait for 1 ns; -- Punto adicional para que se vea bien la forma de onda
        finish;
    end process;
end tb;
