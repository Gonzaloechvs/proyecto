library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use math_real.all;

UA sll UB(Ws-1 downro 0) when "0000"| "0001"
Ws =integer (ceil(log2(real(W))));
shift_right(SA, integer(UB(Ws-1 downto 0)));  -- desp aritmetico
UA srl UB(Ws-a downto 0);
