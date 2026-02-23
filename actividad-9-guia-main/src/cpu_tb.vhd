library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use work.all;

entity cpu_tb is
end cpu_tb ;

architecture tb of cpu_tb is
    constant num_slaves : positive := 1;
    constant ram_addr_nbits : positive := 9;
    constant ram_base : std_logic_vector (31 downto 0) := 32x"0";
    type dsm_t is array (num_slaves - 1 downto 0) of std_logic_vector (31 downto 0);
    signal clk        : std_logic;
    signal nreset     : std_logic;
    -- Crossbar
    signal bus_mdsm    : std_logic_vector (31 downto 0);
    signal bus_maddr   : std_logic_vector (31 downto 0);
    signal bus_mdms    : std_logic_vector (31 downto 0);
    signal bus_mtwidth : std_logic_vector (2 downto 0);
    signal bus_mtms    : std_logic;
    signal bus_saddr   : std_logic;
    signal bus_sdms    : std_logic_vector (31 downto 0);
    signal bus_stwidth : std_logic_vector (2 downto 0);
    signal bus_stms    : std_logic;
    signal bus_sdsm    : dsm_t;
    signal bus_sact    : std_logic_vector (num_slaves - 1 downto 0);
    -- Ram
    signal ram_we      : std_logic;
    signal ram_mask    : std_logic_vector(3 downto 0);
    signal ram_addr    : std_logic_vector(8 downto 0);
    signal ram_din     : std_logic_vector(31 downto 0);
    signal ram_dout    : std_logic_vector(31 downto 0);
begin

    U_CPU : entity cpu port map (
        clk => clk,
        nreset => nreset,
        bus_dsm    => bus_mdsm,
        bus_addr   => bus_maddr,
        bus_dms    => bus_mdms,
        bus_twidth => bus_mtwidth,
        bus_tms    => bus_mtms
    );

    U_CROSSBAR : entity crossbar generic map (
        dsm_t => dsm_t
    ) port map (
        bus_maddr => bus_maddr,
        bus_mdms => bus_mdms,
        bus_mtwidth => bus_mtwidth,
        bus_mtms => bus_mtms,
        bus_mdsm => bus_mdsm,
        bus_saddr => bus_saddr,
        bus_sdms => bus_sdms,
        bus_stwidth => bus_stwidth,
        bus_stms => bus_stms,
        bus_sdsm => bus_sdsm,
        bus_sact => bus_sact
    );

    U_RAM_CONTROLLER : entity ram_controller generic map (
        ram_addr_nbits => ram_addr_nbits,
        ram_base => ram_base
    ) port map (
        clk => clk,
        bus_addr => bus_saddr,
        bus_dms => bus_sdms,
        bus_twidth => bus_stwidth,
        bus_tms  => bus_stms,
        bus_dsm  => bus_sdsm(0),
        bus_sact => bus_sact(0),
        we       => ram_we,
        mask     => ram_mask,
        addr     => ram_addr,
        din      => ram_din,
        dout     => ram_dout
    );

    U_RAM : entity ram512x32 generic map (
        archivo_init => "../src/programa"
    ) port map (
        clk  => clk,
        we   => ram_we,
        mask => ram_mask,
        addr => ram_addr,
        din  => ram_din,
        dout => ram_dout
    );


end architecture ; -- tb