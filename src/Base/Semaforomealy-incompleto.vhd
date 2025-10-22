library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

--Diseñar un control de semáforo para una intersección de calles. La secuencia normal del
--semáforo será rojo durante 60 s, verde durante 50 s y amarillo durante 10 s. Cuando una
--calle está en verde o amarillo la otra calle estará en rojo. Cada dirección tiene un semergencia_2or
--detector de servicios de emergencia y un pulsador de cruce peatonal.


entity mef_maestra_semaforo is
    port(
    clk, rst, rst_timer: in std_logic;
    emergencia_1, emergencia_2, peatonal_1, peatonal_2: in std_logic;
    --emergencia_1 emergencia este-oeste
    --emergencia_2 emergencia norte-sur
    --peatonal_1 peatonal este-oeste
    --peatonal_2 peatonal norte-sur
    --rst: sincrono
    listo: in std_logic;
    peor, pnsr: out std_logic;
    recarga: out std_logic_vector(5 downto 0);
    luz_eo, luz_ns: out std_logic_vector(2 downto 0)
    );
end mef_maestra_semaforo;

--codificador de prioridad entradas
prioridad : process(all)
begin
eeo <= emergencia_1;
ens <= emergencia_2 and not emergencia_1;
peo <= peatonal_1 and not emergencia_1 and not emergencia_2;
pns <= peatonal_2 and not emergencia_1 and not emergencia_2 and not peatonal_1;
end process;

architecture arch of mef_maestra_semaforo is
constant S_INICIO: std_logic_vector(2 downto 0) := "000";
-- S_CV_EO: semaforo este-oeste en verde
constant S_CV_EO: std_logic_vector(2 downto 0) := "001";
-- S_T_EONS: semaforo este-oeste amarillo
constant S_T_EONS: std_logic_vector(2 downto 0) := "010";
-- S_CVA_EO: semaforo este-oeste Adicional
constant S_CVA_EO: std_logic_vector(2 downto 0) := "011";
-- S_CV_NS: semaforo norte-sur en verde
constant S_CV_NS: std_logic_vector(2 downto 0) := "100";
-- S_T_NSEO: semaforo norte-sur amarillo
constant S_T_NSEO: std_logic_vector(2 downto 0) := "101";
-- S_CVA_NS: semaforo norte-sur Adicional
constant S_CVA_NS: std_logic_vector(2 downto 0) := "110";
constant L_VERDE: std_logic_vector(2 downto 0) := "100";
constant L_AMARILLO: std_logic_vector(2 downto 0) := "010";
constant L_ROJO: std_logic_vector(2 downto 0) := "001";
constant T_50S: std_logic_vector(5 downto 0) := "110010"; -- 50
constant T_10S: std_logic_vector(5 downto 0) := "001010"; -- 10
signal est_act, est_sig, est_sig1: std_logic_vector(2 downto 0);
signal peo_k, pns_k, peo_act, pns_act: std_logic;

begin
    --registro/memoria de estado
    memoria_estado : process(clk)
    begin
        if rising_edge(clk) then
            est_act <= est_sig;
        end if;
    end process;

    est_act <= S_INICIO when rst else
                est_sig;


t1: entity timer port map(clk => clk, rst => rst_timer, hab => hab, recarga => recarga, listo => listo);

    -- LES(convinacional)
les: process(all)
est_sig <= est_act;
begin
case est_act is
    when S_INICIO =>
        if listo then
                est_sig <= S_CV_EO;
        end if;
    when S_CV_EO =>
        if eeo then
            est_sig <= S_CV_EO; 
            elsif ens or (listo and not pns_act) then
            est_sig <= S_T_EONS;
            elsif pns_act and listo then
            est_sig <= S_CVA_EO;
        end if;
    when S_T_EONS =>
        if eeo and listo then
            est_sig <= S_CV_EO;
            elsif listo then
            est_sig <= S_CV_NS;
        end if;
    when S_CVA_EO =>
        if eeo then
            est_sig <= S_CV_EO;
            elsif listo then
            est_sig <= S_T_EONS;
        end if;
    when S_CV_NS =>
        if ens then
            est_sig <= S_CV_NS;
            elsif eeo or (listo and not peo_act) then
            est_sig <= S_T_NSEO;
            elsif peo_act and listo then
            est_sig <= S_CVA_NS;
        end if;
    when S_T_NSEO =>
        if ens and listo then
            est_sig <= S_CV_NS;
            elsif listo then
            est_sig <= S_CV_EO;
        end if;
    when S_CVA_NS =>
        if ens then
            est_sig <= S_CV_NS;
            elsif listo then
            est_sig <= S_T_NSEO;
        end if;
    when others =>
        est_sig <= est_act;
    end case;
end process;

-- LE(salida)
le: process(all)
peo_k <= '0';
pns_k <= '0';
begin
    case est_act is
        when S_INICIO =>
            luz_eo <= L_ROJO;
            luz_ns <= L_ROJO;
            recarga <= T_10S; -- 10 segundos
        when S_CV_EO =>
            luz_eo <= L_VERDE;
            luz_ns <= L_ROJO;
            recarga <= T_50S; -- 50 segundos
        when S_CVA_EO =>
            luz_eo <= L_VERDE;
            luz_ns <= L_ROJO;
            recarga <= T_50S; -- 50 segundos
            peo_k <= '1';
        when S_T_EONS =>
            luz_eo <= L_AMARILLO;
            luz_ns <= L_ROJO;
            recarga <= T_10S; -- 10 segundos
        when S_CV_NS =>
            luz_eo <= L_ROJO;
            luz_ns <= L_VERDE;
            recarga <= T_50S; -- 50 segundos    
        when S_CVA_NS =>
            luz_eo <= L_ROJO;
            luz_ns <= L_VERDE;
            recarga <= T_50S; -- 50 segundos
            pns_k <= '1';  
        when S_T_NSEO =>
            luz_eo <= L_ROJO;
            luz_ns <= L_AMARILLO;
            recarga <= T_10S; -- 10 segundos
    end case;
end process;

rst_timer <= '1' when rst else
            '1' when est_act /= est_sig else
            '0'; -- reinicia el timer cuando cambia de estado
peatonal_1 <= peo_act;
peatonal_2 <= pns_act;
peo_act <= peo_k when rst = '0' else
            peo_act and not peo_k; -- flanco de bajada
pns_act <= pns_k when rst = '0' else
            pns_act and not pns_k; -- flanco de bajada
peor <= eeo or peo_act;
pnsr <= ens or pns_act;

display(0) <= luz_eo;
display(1) <= luz_eo;
display(2) <= luz_eo;
display(3) <= luz_eo;
display(4) <= luz_eo;
display(5) <= luz_eo;
display(6) <= luz_eo;
display(7) <= luz_eo;

end arch;
