library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity registro_32x32 is
    port (
        clk     : in  std_logic; -- clock
        we      : in  std_logic_vector(3 downto 0); -- write enable cada bloque de 8 bits (byte)
        addr_r1 : in  std_logic_vector(4 downto 0); -- 5 bits de dirección para 32 palabras puerto de lectura 1
        addr_r2 : in  std_logic_vector(4 downto 0); -- 5 bits de dirección para 32 palabras puerto de lectura 2
        addr_w  : in  std_logic_vector(4 downto 0); -- 5 bits de dirección para 32 palabras puerto de escritura
        din     : in  std_logic_vector(31 downto 0); -- dato de entrada
        dout_1  : out std_logic_vector(31 downto 0); -- dato de salida puerto de lectura 1
        dout_2  : out std_logic_vector(31 downto 0) -- dato de salida puerto de lectura 2
    );
end entity registro_32x32;

architecture behavioral of registro_32x32 is
    type ram_type is array (31 downto 0) of std_logic_vector(31 downto 0); -- 32 palabras de 32 bits cada una

    signal ram : ram_type := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Escritura condicional por bytes
            if we(0) = '1' then
                ram(to_integer(unsigned(addr_w)))(7 downto 0) <= din(7 downto 0);
            end if;
            if we(1) = '1' then
                ram(to_integer(unsigned(addr_w)))(15 downto 8) <= din(15 downto 8);
            end if;
            if we(2) = '1' then
                ram(to_integer(unsigned(addr_w)))(23 downto 16) <= din(23 downto 16);
            end if;
            if we(3) = '1' then
                ram(to_integer(unsigned(addr_w)))(31 downto 24) <= din(31 downto 24);
            end if;

            -- Lectura
            dout_1 <= ram(to_integer(unsigned(addr_r1)));
            dout_2 <= ram(to_integer(unsigned(addr_r2)));
        end if;
    end process;
end architecture behavioral;
