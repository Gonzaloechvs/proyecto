library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_controller generic map (
    constant ram_addr_nbits => ram_addr_nbits,
    constant ram_base => ram_base
    ); port map (
        clk : in std_logic;
        bus_addr : in std_logic_vector (31 downto 0);
        bus_dms : in std_logic_vector (31 downto 0);
        bus_twidth : in std_logic_vector (2 downto 0);
        bus_tms  : in std_logic_vector (31 downto 0);
        bus_dsm  : in std_logic_vector (31 downto 0);
        bus_sact : in std_logic;
        we       : in std_logic;
        mask     : in std_logic_vector (3 downto 0);
        addr     : in std_logic_vector (31 downto 0);
        din      : in std_logic_vector (31 downto 0);
        dout     : in std_logic_vector (31 downto 0);
    );
end ram_controller;

architecture arch of ram_contoller is
    signal 
begin

end arch;