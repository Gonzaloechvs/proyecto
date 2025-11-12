library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity rom_512x32 is
    generic (
        constant init_file : string := ""
    );
    port (
        clk     : in  std_logic; -- clock
        addr    : in  std_logic_vector(8 downto 0); -- 9 bits de dirección para 512 palabras
        dout    : out std_logic_vector(31 downto 0) -- dato de salida
    );
end entity rom_512x32;

architecture behavioral of rom_512x32 is
    type rom_type is array (511 downto 0) of std_logic_vector(31 downto 0); -- 512 palabras de 32 bits cada una

    -- Funcion para inicializar la ROM desde un archivo
    impure function init_rom return rom_type is
        variable rom_data : rom_type := (others => (others => '0'));
        file rom_file     : text;
        variable line_content : line;
        variable addr_index : integer := 0;
        variable valido : boolean;
        variable status : file_open_status;
    begin
        file_open(status, rom_file, init_file, read_mode);
        if status = open_ok then
            while not endfile(rom_file) loop
                readline(rom_file, line_content);
                hread(line_content, rom_data(addr_index), valido);
                if valido then
                    addr_index := addr_index + 1;
                end if;
            end loop;
        end if;
        return rom_data;
    end function init_rom;

    signal rom : rom_type := init_rom;
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            dout <= rom(to_integer(unsigned(addr))); --leer dato de la dirección especificada
        end if;
    end process;
end behavioral;