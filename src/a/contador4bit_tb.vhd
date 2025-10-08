library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use work.all;
use ieee.numeric_std.all;

entity contador4bit_tb is
end contador4bit_tb;

architecture tb of contador4bit_tb is
    signal A : unsigned (3 downto 0) := "0000";
    signal y : unsigned (3 downto 0);
    signal RST : std_logic;
    signal Carga : std_logic;
    signal Valor : unsigned (3 downto 0);
    signal Hab : std_logic;
    signal B : unsigned (3 downto 0);
begin
    DUT : entity contador4bit port map 
    (A => A, B=> B, y => y, Hab => Hab,Valor => Valor,Carga => Carga,RST => RST);
    stim : process is
    begin
        A <= "0000";
        B <= "0000";
        RST <= '0';
        Carga <= '0';
        Hab <= '0';
        wait for 1 ns;
        RST <= '1';
        Hab <= '1';
        wait for 1 ns;
        wait for 1 ns;
        Carga <= '1';
        wait for 1 ns;
        Carga <= '0';
        wait for 1 ns;
        wait for 1 ns;
        RST <= '0';
        wait for 1 ns;
        wait for 1 ns;
        wait for 1 ns;
        RST <= '1';
        wait for 1 ns;
        wait for 1 ns;
        RST <= '0';
        wait for 1 ns;
        wait for 1 ns;
        wait for 1 ns;
        wait for 1 ns;
        wait for 1 ns;
        wait for 1 ns;
        wait for 1 ns;
        Carga <= '1';
        wait for 1 ns;
        Carga <= '0';
        wait for 1 ns;
        wait for 1 ns; -- Punto adicional para que se vea bien la forma de onda
        finish;
    end process;
end tb;
