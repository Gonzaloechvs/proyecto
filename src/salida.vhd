library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity salida is
generic (
        addr_base : in std_logic_vector(31 downto 0)

);
    port(
        clk       : in std_logic;
        nreset    : in std_logic;
        -- Puertos del bus del crossbar
        bus_addr  : in std_logic_vector(31 downto 0);
        bus_dms   : in std_logic_vector(31 downto 0);
        bus_act   : in std_logic;
        bus_tms   : in std_logic;
        -- Respuesta del esclavo
        bus_sact  : out std_logic;
        bus_dsm   : out std_logic_vector(31 downto 0);
        -- Salida física hacia el display
        dout      : out std_logic_vector(31 downto 0);
        we        : out std_logic
    );
end salida;

architecture arch of salida is
    signal reg_data : std_logic_vector(31 downto 0);
    signal match    : std_logic;
begin

    match <= '1' when bus_addr = addr_base else '0';
    
    registros : process (clk)
    begin
        if rising_edge(clk) then
            if not nreset then
                reg_data <= (others => '0');
                we <= '0';
            else
                if (match = '1' and bus_act = '1' and bus_tms = '1') then
                    reg_data <= bus_dms;
                    we <= '1';
                else
                    we <= '0';
                end if;
            end if;
        end if;
    end process;
    
    bus_sact <= we;
    dout <= reg_data;
    bus_dsm <= dout;
end arch;