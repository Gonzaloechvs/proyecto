library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- genera un pulso cada preload + 1 ciclos de reloj
entity prescaler is
    port(
        nreset : in std_logic; -- sincronico
        clk : in std_logic;
        preload : in std_logic_vector (23 downto 0);
        tc : out std_logic
    );
end prescaler;

architecture arch of prescaler is
    signal cuentasig : unsigned (23 downto 0); -- nodos internos
    signal cuenta : unsigned (23 downto 0); 
    signal cero : std_logic;
    signal carga : std_logic;

begin
    registro : process (clk)
    begin
        if rising_edge(clk) then -- flip flop tipo D, determinar un registro de memmoria
            cuenta <= cuentasig;
            end if;
        end process;
        
        tc <= cero;
        cero <= cuenta ?= 0;-- ?= comparador  que devuelve un std_logic, = devuelve un booleanp(que no nos sirve)
        carga <= not nreset or cero;
        cuentasig <= unsigned(preload) when carga else
                    cuenta - 1;
        
    end arch;
