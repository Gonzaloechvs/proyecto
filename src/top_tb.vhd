library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use std.env.finish;


entity top_tb is
end top_tb;

architecture sim of top_tb is
    
    signal clk         : std_logic := '0';
    signal nreset      : std_logic := '0';
    signal display_out : std_logic_vector(7 downto 0);

    -- El periodo es T = 1 / 12 MHz = 83.333 ns
    constant periodo : time := 83.333 ns;

begin

    DUT: entity top
        port map (
            clk         => clk,
            nreset      => nreset,
            display_out => display_out
        );

    -- Proceso que genera el Reloj de 12 MHz
    clk_process : process
    begin
        clk <= '0';
        wait for periodo / 2;
        clk <= '1';
        wait for periodo / 2;
    end process;
    
       control_sim : process
    begin
        nreset <= '0';
        wait until rising_edge(clk);
        wait for 5*periodo;
        wait for periodo/4;
        nreset <= '1';
        wait for 2000 * periodo;
        finish;
    end process;

end sim;