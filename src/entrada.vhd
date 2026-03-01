library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity entrada is
    generic (
        addr_base : in std_logic_vector(31 downto 0) := x"80000004" -- Dirección distinta a la salida
    );
    port(
        clk       : in std_logic;
        nreset    : in std_logic;
        bus_addr  : in std_logic_vector(31 downto 0);
        bus_sact  : out std_logic;
        bus_dsm   : out std_logic_vector(31 downto 0);
        din       : in std_logic_vector(7 downto 0)
    );
end entrada;

architecture arch of entrada is
    signal match    : std_logic;
    signal din_sync : std_logic_vector(7 downto 0);
begin

    match <= '1' when bus_addr = addr_base else '0';
    
    registros : process (clk)
    begin
        if rising_edge(clk) then
            if nreset = '0' then
                din_sync <= (others => '0');
                bus_sact <= '0';
                bus_dsm  <= (others => '0');
            else
                din_sync <= din; 
                
                if match = '1' then
                    bus_sact <= '1';
                    -- Rellenamos con 24 ceros y ponemos los 8 bits de entrada
                    bus_dsm  <= x"000000" & din_sync; 
                else
                    bus_sact <= '0';
                    bus_dsm  <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end arch;