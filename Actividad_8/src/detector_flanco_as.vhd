library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity detector_flanco_as is
    port (
        clk, signal_in : in  std_logic;
        flanco : out std_logic
    );
end detector_flanco_as;

architecture arch of detector_flanco_as is
    signal signal_in2, signal_in_sync : std_logic;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            signal_in2 <= signal_in;
            signal_in_sync <= signal_in2;
        end if;
    end process;

    flanco <= '1' when (signal_in_sync = '0' and signal_in2 = '1') else '0';

end arch;
