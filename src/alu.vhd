library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use ieee.math_real.all;

entity alu is
    generic (
        constant W : integer := 4  -- ancho de los operandos
    );
    port (
        A       : in  std_logic_vector(W-1 downto 0); -- operando A
        B       : in  std_logic_vector(W-1 downto 0); -- operando B
        sel_fn  : in  std_logic_vector(3 downto 0);   -- codigo de operacion
        Y       : out std_logic_vector(W-1 downto 0); -- resultado
        Z       : out std_logic                       -- bandera de cero
    );
end alu;

architecture arch of alu is
    constant cero : std_logic_vector(W-1 downto 0) := (others => '0');
    constant max  : integer := natural(ceil(log2(real(W))));
    signal SA, SB : signed(W-1 downto 0);
    signal UA, UB : unsigned(W-1 downto 0);
begin
    SA <= signed(A);
    SB <= signed(B);
    UA <= unsigned(A);
    UB <= unsigned(B);

    process(all)
    variable desplazamiento : integer;
    begin
        desplazamiento := to_integer(UB(max-1 downto 0)); -- cantidad de desplazamiento

        Y <= (others => '0');

        case sel_fn is

            when "0000" => -- suma
                Y  <= std_logic_vector(UA + UB);

            when "0001" => -- resta
                Y  <= std_logic_vector(UA - UB);

            when "0010" | "0011" => -- desplazamiento lógico a la izquierda
                Y  <= std_logic_vector(UA sll desplazamiento);

            when "0100" | "0101" => -- menor con signo
                if (SA < SB) then
                    Y  <= (others => '0'); 
                    Y (0) <= '1';
                else
                    Y  <= (others => '0');
                end if;

            when "0110" | "0111" => -- menor sin signo
                if (UA < UB) then
                    Y  <= (others => '0');
                    Y (0) <= '1';
                else
                    Y  <= (others => '0');
                end if;

            when "1000" | "1001" => -- XOR bit a bit
                Y  <= std_logic_vector(UA xor UB);

            when "1010" => -- desplazamiento lógico a la derecha
                Y  <= std_logic_vector( UA srl desplazamiento);

            when "1011" => -- desplazamiento aritmético a la derecha
                Y  <= std_logic_vector(shift_right(SA, desplazamiento));

            when "1100" | "1101" => -- OR bit a bit
                Y  <= std_logic_vector(UA or UB);

            when "1110" | "1111" => -- AND bit a bit
                Y  <= std_logic_vector(UA and UB);

            when others =>
                Y  <= (others => '0');
        end case;
    end process;
    
    -- Salida de resultados
    Z <= '1' when (Y  = cero) else '0';

end arch;
