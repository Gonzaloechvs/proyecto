library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ram_512x32 is
    generic (
        constant init_file : string := ""
    );
    port (
        clk     : in  std_logic; -- clock
        we      : in  std_logic_vector(3 downto 0); -- write enable cada bloque de 8 bits (byte)
        addr_r  : in  std_logic_vector(8 downto 0); -- 9 bits de dirección para 512 palabras puerto de lectura
        addr_w  : in  std_logic_vector(8 downto 0); -- 9 bits de dirección para 512 palabras puerto de escritura
        din     : in  std_logic_vector(31 downto 0); -- dato de entrada
        dout    : out std_logic_vector(31 downto 0) -- dato de salida
    );
end entity ram_512x32;

architecture behavioral of ram_512x32 is
    type ram_type is array (511 downto 0) of std_logic_vector(31 downto 0); -- 512 palabras de 32 bits cada una

    -- Funcion para inicializar la RAM desde un archivo
    impure function init_ram return ram_type is
        variable ram_data : ram_type := (others => (others => '0'));
        file ram_file     : text;
        variable line_content : line;
        variable addr_index : integer := 0;
        variable valido : boolean;
        variable status : file_open_status;
    begin
        file_open(status, ram_file, init_file, read_mode);
        if status = open_ok then
            while not endfile(ram_file) loop
                readline(ram_file, line_content);
                hread(line_content, ram_data(addr_index), valido);
                if valido then
                    addr_index := addr_index + 1;
                end if;
            end loop;
        end if;
        return ram_data;
    end function init_ram;

    signal ram : ram_type := init_ram;

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
            dout <= ram(to_integer(unsigned(addr_r))); --leer dato de la dirección especificada
        end if;
    end process;
end behavioral;
