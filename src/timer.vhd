library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- genera un pulso cada recarga + 1 ciclos de reloj
entity timer is
    port(
        nreset, clk: in std_logic; -- sincronico
        recarga : in std_logic_vector (5 downto 0);
        listo: out std_logic -- pulso de salida
    );
end timer;

architecture arch of timer is
    signal est_act, est_sig: std_logic_vector (5 downto 0); -- nodos internos
begin
    registro : process (clk)
    begin
        if rising_edge(clk) then -- flip flop tipo D, determinar un registro de memmoria
            est_act <= est_sig;
            end if;
        end process;
        --datapath
    listo <= '1' when est_act = "000001" else 
            '0';
    est_sig <= (others => '0') when not nreset else
                    recarga when est_act = "000000" else
                    std_logic_vector(unsigned(est_act) - 1);

    end arch;

