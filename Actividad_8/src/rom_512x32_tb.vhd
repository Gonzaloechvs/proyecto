library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.all;

entity rom_512x32_tb is
end rom_512x32_tb;

architecture tb of rom_512x32_tb is
    signal clk     : std_logic;
    signal addr    : std_logic_vector(8 downto 0);
    signal dout    : std_logic_vector(31 downto 0);

    constant periodo :time := 10 ns;
begin
    dut : entity rom_512x32 generic map (
        init_file => "../src/rom_512x32_tb_contenido.txt"
    ) port map(
        clk => clk,
        addr => addr,
        dout => dout
    );

    reloj : process
    begin
        clk <= '0';
        wait for periodo/2;
        clk <= '1';
        wait for periodo/2;
    end process;

    estimulo_y_evaluacion : process
    begin
        addr <= 9x"0";
        wait until rising_edge(clk);
        wait for periodo/4;
        addr <= "000000001";
        wait for periodo*2;
        assert dout = x"6611"
            report "Valor inicial distinto al esperado" severity error;
        addr <= 9x"1FF";
        wait for periodo*2;
        assert dout = x"DEADBEEF"
            report "Valor inicial distinto al esperado" severity error;
        finish;
    end process;

end tb;