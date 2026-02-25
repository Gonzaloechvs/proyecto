library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity top_tb is
end top_tb;

architecture sim of top_tb is
    
    signal clk         : std_logic := '0';
    signal nreset      : std_logic := '0';
    signal display_out : std_logic_vector(7 downto 0);

    -- El periodo es T = 1 / 12 MHz = 83.333 ns
    constant CLK_PERIOD : time := 83.333 ns;

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
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_process : process
    begin
        -- Mantenemos el reset presionado (activo en bajo) al inicio
        nreset <= '0';
        
        -- Esperamos 10 ciclos de reloj para que todo se estabilice
        wait for CLK_PERIOD * 10;
        
        -- Liberamos el botón de reset
        nreset <= '1';

        -- A partir de este momento, tu CPU empezará a hacer Fetch de las 
        -- instrucciones desde la RAM, a decodificarlas y a ejecutarlas.
        
        -- Suspendemos este proceso indefinidamente para que el reloj siga corriendo
        wait;
    end process;

end sim;