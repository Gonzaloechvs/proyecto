library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.all;

entity ram_512x32_dualport_tb is
end ram_512x32_dualport_tb;

architecture tb of ram_512x32_dualport_tb is
    signal clk     : std_logic;
    signal we      : std_logic_vector(3 downto 0);
    signal addr_r  : std_logic_vector(8 downto 0);
    signal addr_w  : std_logic_vector(8 downto 0);
    signal din     : std_logic_vector(31 downto 0);
    signal dout    : std_logic_vector(31 downto 0);

    constant periodo :time := 10 ns;
begin
    dut : entity ram_512x32 generic map (
        init_file => "../src/ram_512x32_dualport_tb_contenido.txt"
    ) port map(
        clk => clk,
        we => we,
        addr_r => addr_r,
        addr_w => addr_w,
        din => din,
        dout => dout
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
        -- Lectura de la dirección 1
        addr_r <= (others => '1');
        we <= (others => '0');
        wait until rising_edge(clk);
        wait for periodo / 4;
        assert dout = x"12345678"
            report "Valor inicial en dirección 0 distinto al esperado" severity error;
        wait for periodo*2;

        -- Escritura en la dirección 10
        addr_w <= std_logic_vector(to_unsigned(10, 9));
        din <= x"DEADBEEF";
        we <= "1111"; -- Habilitar escritura completa
        wait until rising_edge(clk);
        wait for periodo*2;

        -- Lectura de la dirección 10
        addr_r <= std_logic_vector(to_unsigned(10, 9));
        we <= (others => '0');
        wait until rising_edge(clk);
        wait for periodo / 4;
        assert dout = x"DEADBEEF"
            report "Valor leído en dirección 10 distinto al esperado" severity error;
        wait for periodo*2;
        finish;
    end process;
end tb;