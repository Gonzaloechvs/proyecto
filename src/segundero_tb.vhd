library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use work.all;

-- Para trabajar conarchivos de texto
use std.textio.all;-- Para leer y escribir archivos de texto
--tipo text, tipo line, tipo read_line
use ieee.std_logic_textio.all;-- leer y escribir std_logic y std_logic_vector
-- funcion read(linea, vector, correcto)

entity segundero_tb is
end segundero_tb;

architecture tb of segundero_tb is
    constant divisor: integer := 10;
    constant periodo: time := 1 sec/divisor;
    signal nreset,clk :std_logic;
    signal display :std_logic_vector (7 downto 0);

begin
    dut : entity segundero generic map (divisor => divisor)
    port map(clk => clk, nreset => nreset, display => display);

    gen_clk : process
    begin
        clk <= '0';
        wait for periodo/2;
        clk <= '1';
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
        file archivo_patron : text open read_mode is "../src/segundero_tb_patron.txt";
        variable linea_patron: line;
        variable patron : std_logic_vector (7 downto 0);
        variable lectura_correcta : boolean;
        variable nr_linea : integer := 0;
    begin
        --sincronizar con liberacion de reset
        wait until rising_edge(nreset);
        while not endfile(archivo_patron) loop
            nr_linea := nr_linea + 1;
            readline(archivo_patron,linea_patron);
            read(linea_patron, patron, lectura_correcta);
            if not lectura_correcta then
                report "Línea " & integer'image(nr_linea) & " ignorada" severity note;
                next;
            end if;
            assert patron = display
                report "Salida  Display incorrecta, esperado"
                & to_string(patron) & " obtenido "
                & to_string(display) & " (linea" 
                & integer'image(nr_linea) & " del patron)"
                severity error;
            wait for 1 sec;
        end loop;
        finish;
    end process;
end tb;
