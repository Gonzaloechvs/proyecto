library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.all;

entity alu_tb is
end alu_tb;

architecture tb of alu_tb is

    -- Base de tiempo
    constant periodo : time := 10 ns;
    -- Ancho de palabra
    constant W : integer := 32;

    signal A,B,Y : std_logic_vector(W-1 downto 0);
    signal sel_fn : std_logic_vector (3 downto 0);
    signal Z : std_logic;
begin

    dut : entity alu generic map (
        W   => W
    ) port map (
        A => A,
        B => B,
        sel_fn => sel_fn,
        Y => Y,
        Z => Z
    );

    prueba : process
        file archivo_estimulo : text open read_mode is "../src/alu_tb_datos.txt";
        variable linea_estimulo : line;
        -- solicitud_peaton_a&solicitud_peaton_b
        -- &solicitud_emergencia_a&solicitud_emergencia_b
        variable estimulo_A : std_logic_vector (W-1 downto 0);
        variable estimulo_B : std_logic_vector (W-1 downto 0);
        variable estimulo_sel_fn : std_logic_vector (3 downto 0);
        variable esperado_Y : std_logic_vector (W-1 downto 0);
        variable esperado_Z : std_logic;
        variable lectura_correcta : boolean;
        variable nr_procesadas,nr_ignoradas : integer := 0;
    begin
        while not endfile(archivo_estimulo) loop
            readline(archivo_estimulo,linea_estimulo);
            hread(linea_estimulo,estimulo_A,lectura_correcta);
            if lectura_correcta then
                hread(linea_estimulo,estimulo_B,lectura_correcta);
            end if;
            if lectura_correcta then
                hread(linea_estimulo,estimulo_sel_fn,lectura_correcta);
            end if;
            if lectura_correcta then
                hread(linea_estimulo,esperado_Y,lectura_correcta);
            end if;
            if lectura_correcta then
                read(linea_estimulo,esperado_Z,lectura_correcta);
            end if;
            if not lectura_correcta then
                nr_ignoradas := nr_ignoradas + 1;
                next;
            end if;
            nr_procesadas := nr_procesadas + 1;
            A <= estimulo_A;
            B <= estimulo_B;
            sel_fn <= estimulo_sel_fn;
            wait for periodo/2;
            assert Y = esperado_Y
                report "Resultado distinto al esperado"
                severity error;
            assert Z = esperado_Z
                report "Indicador de cero distinto al esperado"
                severity error;
            wait for periodo/2;
        end loop;
        report "Fin de pruebas, "&integer'image(nr_procesadas)
                &" líneas procesadas y "&integer'image(nr_ignoradas)
                &" ignoradas."
        severity note;
        finish;
    end process;

end tb ; -- tb