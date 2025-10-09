library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use work.all;

entity timer_tb is
end timer_tb;

architecture tb of timer_tb is
    constant periodo: time := 1 ms;
    signal nreset, clk :std_logic;
    signal listo : std_logic;
    signal recarga : std_logic_vector (5 downto 0);
begin
    dut : entity timer port map(clk => clk, nreset => nreset,listo => listo, recarga => recarga);

    gen_clk : process
    begin
        clk <= '1';
        wait for periodo/2;
        clk <= '0';
        wait for periodo/2;
    end process;

    estimulo: process
    begin
        nreset <= '0';
        wait until rising_edge(clk);
        wait for periodo/4;
        nreset <= '1';
        wait;
    end process;

    evaluacion: process
    begin
        wait until rising_edge(clk);
        wait for periodo/4;
        nreset <= '0';
        
        wait for 3*periodo;
        nreset <= '1';
        
        wait for 15*periodo;


        finish;
        end process;
end tb;
