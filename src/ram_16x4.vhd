library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ram_16x4 is
    generic (
        init_file : string := ""
    );

    port ( clk     : in  std_logic; -- clock 
           we      : in  std_logic; -- write enable
           addr    : in  std_logic_vector (3 downto 0); -- 4 bits de dirección para 16 palabras
           din     : in  std_logic_vector (3 downto 0); -- dato de entrada
           dout    : out std_logic_vector (3 downto 0)); -- dato de salida
end ram_16x4;

architecture arch of ram_16x4 is

    type ram_type is array (15 downto 0) of std_logic_vector (3 downto 0); -- 16 palabras de 4 bits cada una
    
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
                if addr_index > 15 then
                    exit;
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
            if we = '1' then -- write enable
                ram(to_integer(unsigned(addr))) <= din; --escribir dato en la dirección especificada
            end if;
            dout <= ram(to_integer(unsigned(addr))); --leer dato de la dirección especificada
        end if;
    end process;
end arch;