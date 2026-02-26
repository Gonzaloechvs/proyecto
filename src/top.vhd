library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.tipos.all;
use work.all;

entity top is
    port(
        clk         : in std_logic;
        nreset      : in std_logic;
        display_out : out std_logic_vector(7 downto 0) 
    );
end top;

architecture arch of top is

    signal cpu_bus_addr   : std_logic_vector(31 downto 0);
    signal cpu_bus_dms    : std_logic_vector(31 downto 0);
    signal cpu_bus_twidth : std_logic_vector(2 downto 0);
    signal cpu_bus_tms    : std_logic;
    signal cpu_bus_dsm    : std_logic_vector(31 downto 0);

    signal slv_bus_addr   : std_logic_vector(31 downto 0);
    signal slv_bus_dms    : std_logic_vector(31 downto 0);
    signal slv_bus_twidth : std_logic_vector(2 downto 0);
    signal slv_bus_tms    : std_logic;

    signal bus_sact_array : std_logic_vector(1 downto 0);
    signal bus_sdsm_array : word_array(1 downto 0);

    signal ram_we         : std_logic;
    signal ram_mask       : std_logic_vector(3 downto 0);
    signal ram_addr       : std_logic_vector(8 downto 0); -- 9 bits = 512 palabras
    signal ram_din        : std_logic_vector(31 downto 0);
    signal ram_dout       : std_logic_vector(31 downto 0);

    signal perif_dout     : std_logic_vector(31 downto 0);
    signal perif_we       : std_logic; 

    signal nreset_sync    : std_logic;

begin
    --reset
    u_reset: entity reset_al_inicializar_fpga
        port map (
            clk        => clk,
            nreset_in  => nreset,
            nreset_out => nreset_sync
        );

    -- Maestro CPU
    u_cpu: entity cpu 
        port map (
            clk        => clk,
            nreset     => nreset_sync,
            bus_twidth => cpu_bus_twidth,
            bus_addr   => cpu_bus_addr,
            bus_dms    => cpu_bus_dms,
            bus_tms    => cpu_bus_tms,
            bus_dsm    => cpu_bus_dsm
        );

    -- Crossbar
    u_crossbar: entity crossbar
        generic map (
            num_slaves => 2
        )
        port map (
            bus_maddr   => cpu_bus_addr,
            bus_mdms    => cpu_bus_dms,
            bus_mtwidth => cpu_bus_twidth,
            bus_mtms    => cpu_bus_tms,
            bus_mdsm    => cpu_bus_dsm,
            bus_sact    => bus_sact_array,
            bus_sdsm    => bus_sdsm_array,
            bus_saddr   => slv_bus_addr,
            bus_sdms    => slv_bus_dms,
            bus_stwidth => slv_bus_twidth,
            bus_stms    => slv_bus_tms
        );
    --ram controller
    u_ram_ctrl: entity ram_controller
        generic map (
            ram_addr_nbits => 9,               -- 9 bits para 512 palabras
            ram_base       => x"00000000"      -- Dirección base de la RAM
        )
        port map (
            clk        => clk,
            bus_addr   => slv_bus_addr,
            bus_dms    => slv_bus_dms,
            bus_twidth => slv_bus_twidth,
            bus_tms    => slv_bus_tms,
            bus_sact   => bus_sact_array(0),
            bus_dsm    => bus_sdsm_array(0),
            ram_we     => ram_we,
            ram_mask   => ram_mask,
            ram_addr   => ram_addr,
            ram_din    => ram_din,
            ram_dout   => ram_dout
        );
    -- ram512x32, 512 palabras de 32 bytes cada una
    u_ram_512x32: entity ram512x32
    generic map(
        -- cambiar a rapido si es tb y nada si es para probar en la FPGA
        archivo_init => "../src/cuenta_en_display.txt"
    )
        port map (
            clk   => clk,
            we    => ram_we,
            mask  => ram_mask,
            addr  => ram_addr,
            din   => ram_din,
            dout  => ram_dout
        );

    u_display_salida: entity salida
        generic map (
            addr_base => x"80000000"
        )
        port map (
            clk        => clk,
            nreset     => nreset_sync,
            bus_addr   => slv_bus_addr,
            bus_dms    => slv_bus_dms,
            bus_tms    => slv_bus_tms,
            bus_sact   => bus_sact_array(1),   
            bus_dsm    => bus_sdsm_array(1),
            dout       => perif_dout,
            we         => perif_we
        );

    display_out <= perif_dout(7 downto 0);

end architecture arch;