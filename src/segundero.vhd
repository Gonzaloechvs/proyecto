library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity segundero is
generic (
constant divisor : integer := 12000000
);
    port(
        nreset : in std_logic;
        clk : in std_logic;
        display : out std_logic_vector (7 downto 0)
    );
end segundero;

architecture arch of segundero is
    signal preload : std_logic_vector(23 downto 0);
    signal segundo, segundosig: unsigned (3 downto 0);
    signal limite, hab, reset_cuenta : std_logic;
begin
registro : process(clk)
begin
    if rising_edge(clk) then
            segundo <= segundosig;
            end if;
    end process;

    U1 : entity prescaler port map (clk => clk, nreset => nreset, preload => preload, tc => hab);

    preload <= std_logic_vector(to_unsigned(divisor-1,24));

        limite <= segundo ?= 9;
        reset_cuenta <= not nreset or (limite and hab);
        segungosig <= "0000" when reset_cuenta else
                segundo + 1 when hab else
                segundo;

U2: entity decod_7s port map(
a=> segundo;
y=> display(6 downto 0)
);
display(7) <= limite;
end arch;