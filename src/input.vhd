library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity input is
    port(
    clk        : in std_logic;
    nreset     : in std_logic;
    addr       : in std_logic_vector(31 downto 0);
    dout       : out std_logic_vector(31 downto 0);
    re         : out std_logic;
    bus_addr   : in std_logic_vector(31 downto 0);
    din        : in std_logic_vector(31 downto 0);
    bus_sact   : out std_logic;
    bus_tsm    : in std_logic
    );
end input;

architecture arch of input is

signal bus_act : std_logic;

begin

    registros : process (clk)
    begin
        if rising_edge(clk) then
            if not nreset then
                bus_sact <= '0';
            else
                bus_sact <= bus_act;
            end if;
            if bus_act then
                bus_sdm <= din;
            end if;
        end if;
    end process;
    
    --salidas
    bus_act <= bus_tsm and (bus_addr ?= addr);
    re <= bus_act;
    bus_dsm <= dout;

end arch ; -- arch

