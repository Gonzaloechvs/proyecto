library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.all;

entity top is
    port (
        X : in std_logic_vector(7 downto 0);
        clk : in std_logic;
        display : out std_logic_vector(7 downto 0)
        );
end top;

architecture arch of top is
    signal we      : std_logic;
    signal addr    : std_logic_vector(3 downto 0);
    signal din     : std_logic_vector(3 downto 0);
    signal dout    : std_logic_vector(3 downto 0);
    signal A,B,C   : std_logic;
    signal Y       : std_logic_vector(3 downto 0);
    begin

    ram_inst : entity ram_16x4
        generic map (
            init_file => "../src/ram_16x4_tb_contenido.txt"
        ) port map (
            clk => clk,
            we => we,
            addr => addr,
            din => din,
            dout => dout
        );

    flanco_we : entity detector_flanco_as
        port map (
            clk => clk,
            signal_in => X(5),
            flanco => we
        );

    flanco_A : entity detector_flanco_as
        port map (
            clk => clk,
            signal_in => X(6),
            flanco => A
        );

process(all)
begin    
    if rising_edge(clk) then
        din <= X(3 downto 0);
        
        if A = '1' then
            addr <= X(3 downto 0);
        end if;
        
        if X(7) = '1' then
            Y <= addr;
        else 
            Y <= dout;
        end if; 
    end if;
    end process;

    deco_salida: entity decod_7s
        port map (
            A => Y,
            Y => display(6 downto 0)
        );
    display(7) <= X(7);

end arch;