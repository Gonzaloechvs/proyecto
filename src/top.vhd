library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity top is
    port (
        clk     : in  std_logic;                    -- reloj
        X       : in  std_logic_vector(7 downto 0); -- switches
        display : out std_logic_vector(7 downto 0)  -- resultado
    );

end top;

architecture arch of top is

    signal A, B, C, Y, sel_fn: std_logic_vector(3 downto 0);
    signal flanco_A, flanco_B, flanco_fn : std_logic;
    signal Z : std_logic;
begin
    
    alu_1: entity alu
    port map (
        A => A,
        B => B,
        sel_fn => sel_fn,
        Y => Y,
        Z => Z
    );

    detector_x4: entity detector_flanco_as
    port map (
        clk => clk,
        signal_in => X(4),
        flanco => flanco_A
    );

    detector_x5: entity detector_flanco_as
    port map (
        clk => clk,
        signal_in => X(5),
        flanco => flanco_B
    );

    detector_x6: entity detector_flanco_as
    port map (
        clk => clk,
        signal_in => X(6),
        flanco => flanco_fn
    );

    process(all)
    begin
        if rising_edge(clk) then
            sel_fn <= X(3 downto 0);
            if flanco_B = '1' then
                B <= X(3 downto 0);
            else 
            B <= B;
            end if;    
            if flanco_A = '1' or flanco_fn = '1' then
                if flanco_fn = '1' then
                    A <= Y;
                    sel_fn <= X(3 downto 0);
                else
                    A <= X(3 downto 0);
                end if;
            else
                A <= A;
            end if;
            if X(7) = '1' then
                C <= B;
            else
                C <= A;
            end if;
            sel_fn <= X(3 downto 0);
        end if;
    end process;

    U1: entity decod_7s port map(
        A => C,
        Y => display(6 downto 0)
    );
    display(7) <= Z;
end arch;