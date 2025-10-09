library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


entity mef_maestra_semaforo is
    port(
    clk, rst: in std_logic;
    eeo, ens, peo, pns: in std_logic;
    listo: in std_logic;
    peor, pnsr: out std_logic;
    recarga: out std_logic_vector(5 downto 0);
    luz_eo, luz_ns: out std_logic_vector(2 downto 0)
    );
end mef_maestra_semaforo;

architecture arch of mef_maestra_semaforo is
constant inicio: std_logic_vector(2 downto 0) := "000";
constant S_CV_EO: std_logic_vector(2 downto 0) := "001";
constant S_T_EONS: std_logic_vector(2 downto 0) := "010";
constant S_CVA_EO: std_logic_vector(2 downto 0) := "011";
constant S_CV_NS: std_logic_vector(2 downto 0) := "100";
constant S_T_EONS: std_logic_vector(2 downto 0) := "101";
constant S_CVA_NS: std_logic_vector(2 downto 0) := "110";
constant L_VERDE: std_logic_vector(2 downto 0) := "100";
constant L_AMARILLO: std_logic_vector(2 downto 0) := "010";
constant L_ROJO: std_logic_vector(2 downto 0) := "001";
constant T_50S: std_logic_vector(5 downto 0) := "110010"; -- 50
constant T_10S: std_logic_vector(5 downto 0) := "001010"; -- 10
signal est_act, est_sig: std_logic_vector(2 downto 0);

begin
    --registro/memoria de estado
    memoria_estado : process(clk)
    begin
        if rising_edge(clk) then
            est_act <= est_sig;
        end if;
    end process;

    -- LES(convinacional)
les: process(all)
begin
case est_act is
    when S_INICIO =>
        if rst = '0' then
            est_sig <= S_CV_EO;
        else
            est_sig <= inicio;
        end if;
    when S_CV_EO =>
        if eeo = '1' then
            est_sig <= S_T_EONS;
        else
            est_sig <= S_CV_EO;
        end if;
    when S_T_EONS =>
        if listo = '1' then
            est_sig <= S_CVA_EO;
        else
            est_sig <= S_T_EONS;
        end if;
    when S_CVA_EO =>
        if peo = '1' then
            est_sig <= S_CV_NS;
        else
            est_sig <= S_CVA_EO;
        end if;
    when S_CV_NS =>
        if ens = '1' then
            est_sig <= S_T_EONS;
        else
            est_sig <= S_CV_NS;
        end if;
    when S_T_EONS =>
        if listo = '1' then
            est_sig <= S_CVA_NS;
        else
            est_sig <= S_T_EONS;
        end if;
    when S_CVA_NS =>
        if pns = '1' then
            est_sig <= S_CV_EO;
        else
            est_sig <= S_CVA_NS;
        end if;
    when others =>
        est_sig <= inicio;

end process;
    -- LE(salida)

end arch;
