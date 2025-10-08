library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador4bit is
    port(
        RST : in std_logic;
        Carga : in std_logic;
        Valor : out unsigned (3 downto 0);
        Hab : in std_logic;
        A : out unsigned (3 downto 0):= "0000";
        B : out unsigned (3 downto 0);
        y : out unsigned (3 downto 0)
    );
end contador4bit;

architecture arch of contador4bit is
begin
    -- hago sintesis por el metodo de datapath
    Valor <= "1100";

    B <= "0000" when RST else
        Valor when Carga else
        (A + 1) when Hab else
        A;
    
    y <= B;
    A <= Y;
end arch;
    