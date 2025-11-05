library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.all;

entity detector_flanco_as_tb is
end detector_flanco_as_tb;

architecture tb of detector_flanco_as_tb is

    -- Base de tiempo
    constant periodo : time := 10 ns;

    signal clk : std_logic := '0';
    signal signal_in : std_logic := '0';
    signal rising_edge_out : std_logic;
begin

    dut : entity detector_flanco_as port map (
        clk => clk,
        signal_in => signal_in,
        flanco => rising_edge_out
    );

    gen_clk : process
    begin
        clk <= '0';
        wait for periodo/2;
        clk <= '1';
        wait for periodo/2;
    end process;
    
    estimulo: process
    begin
        -- Caso 1: No hay flanco
        signal_in <= '0';
        wait for periodo * 3;
        
        -- Caso 2: Flanco de subida
        signal_in <= '1';
        wait for periodo;
        
        -- Caso 3: No hay flanco
        signal_in <= '1';
        wait for periodo * 2;
        
        -- Caso 4: Flanco de bajada
        signal_in <= '0';
        wait for periodo;
        
        -- Caso 5: Flanco de subida
        signal_in <= '1';
        wait for periodo * 2;
        
        -- Caso 6: No hay flanco
        signal_in <= '0';
        wait for periodo * 2;

        -- Finalizar la simulación
        wait for periodo * 2;
        finish;
    end process;
    
    evaluacion: process
    begin
        -- Caso 1: No hay flanco
        wait for periodo * 3;
        assert rising_edge_out = '0'
            report "Error en Caso 1: No hay flanco" severity error;
        
        -- Caso 2: Flanco de subida
        wait for periodo;
        assert rising_edge_out = '1'
            report "Error en Caso 2: Flanco de subida no detectado" severity error;
        
        -- Caso 3: No hay flanco
        wait for periodo * 2;
        assert rising_edge_out = '0'
            report "Error en Caso 3: No hay flanco" severity error;
        
        -- Caso 4: Flanco de bajada
        wait for periodo;
        assert rising_edge_out = '0'
            report "Error en Caso 4: Flanco de bajada incorrectamente detectado" severity error;
        
        -- Caso 5: Flanco de subida
        wait for periodo;
        assert rising_edge_out = '1'
            report "Error en Caso 5: Flanco de subida no detectado" severity error;
        
    end process;
end tb;