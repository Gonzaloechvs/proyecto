library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.all;

entity registro_32x32_tb is
end registro_32x32_tb; 

architecture tb of registro_32x32_tb is
    signal clk     : std_logic; 
    signal we      : std_logic_vector(3 downto 0); 
    signal addr_r1 : std_logic_vector(4 downto 0); 
    signal addr_r2 : std_logic_vector(4 downto 0); 
    signal addr_w  : std_logic_vector(4 downto 0); 
    signal din     : std_logic_vector(31 downto 0);
    signal dout_1  : std_logic_vector(31 downto 0);
    signal dout_2  : std_logic_vector(31 downto 0);   

    constant periodo : time := 10 ns;
begin
    
    dut: entity registro_32x32 
    port map(
        clk => clk,
        we => we,
        addr_r1 => addr_r1,
        addr_r2 => addr_r2,
        addr_w => addr_w,
        din => din,
        dout_1 => dout_1,
        dout_2 => dout_2
    );

    clk_process : process
    begin
        clk <= '0';
        wait for periodo / 2;
        clk <= '1';
        wait for periodo / 2;
    end process;

    estimulo_y_evaluacion : process
    begin
         -- Lectura de la dirección (todos 0)
        addr_r1 <= (others => '0');
        addr_r2(4 downto 1) <= (others => '0');
        addr_r2 (0)<= '1';
        we <= (others => '0');
        wait until rising_edge(clk);
        wait for periodo / 4;
        assert dout_1 = x"12345678"
            report "Valor inicial en dirección 0 distinto al esperado" severity error;
        assert dout_2 = x"12345678"
            report "Valor inicial en dirección 1 distinto al esperado" severity error;
        wait for periodo*2;

        -- Escritura en la dirección 10
        addr_w <= std_logic_vector(to_unsigned(10, 5));
        din <= x"DEADBEEF";
        we <= "1111"; -- Habilitar escritura completa
        wait until rising_edge(clk);
        wait for periodo*2;

        -- Lectura de la dirección 10
        addr_r1 <= std_logic_vector(to_unsigned(10, 5));
        addr_r2 <= std_logic_vector(to_unsigned(9, 5)); 
        we <= (others => '0');
        wait until rising_edge(clk);
        wait for periodo / 4;
        assert dout_1 = x"DEADBEEF"
            report "Valor leído en dirección 10 distinto al esperado" severity error;
        assert dout_2 = x"DEADBEEF"
            report "Valor leído en dirección 10 distinto al esperado" severity error;
        wait for periodo*2;
        finish;
    end process;
end tb ; -- tb