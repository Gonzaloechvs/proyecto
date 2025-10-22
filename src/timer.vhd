library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    generic (
        N : integer := 6); -- numero de bits del timer
    port (
        clk : in std_logic;
        hab : in std_logic;
        reset : in std_logic;
        preload : in std_logic_vector (N-1 downto 0);
        Z : out std_logic;-- cuenta cero
        T : out std_logic);-- fin de temporización
end timer;

architecture arch of timer is
    signal D, D_sig : unsigned (N-1 downto 0);
begin

    memoria : process (clk)
    begin
        if rising_edge(clk) then
            D <= D_sig;
        end if;
    end process;

    D_sig <= (others=>'0') when reset else
             D when not hab else
             unsigned(preload) when Z else
             D - 1;
    Z <= D ?= 0;
    T <= D ?= 1;
end arch;