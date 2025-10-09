library ieee;
use ieee.std_logic_1164.all;

entity contador3bitv2 is
    port(
        A : in std_logic_vector (3 downto 0);
        y : out std_logic_vector (2 downto 0)
    );
end contador3bitv2;

architecture arch of contador3bitv2 is
begin
    --Q*2 = RST'Q2Q1’ + RST'Q2Q0’ + RST'Q2'Q1Q0 = RST'Q2(Q1’ + Q0’) + RST'Q2'Q1Q0
    y(2) <= (not A(3) and A(2) and(not A(1) or not A(0))) or (not A(3) and not A(2) and A(1) and A(0));
    --Q*1 = RST'Q1'Q0 + RST'Q1Q0’ = RST’(Q1 XOR Q0)
    y(1) <= (not A(3) and(A(1) xor A(0)));
    --Q*0 = RST'Q0’
    y(0) <= (not A(3) and not A(0));
end arch;
    