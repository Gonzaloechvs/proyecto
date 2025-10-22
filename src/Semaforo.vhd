library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

--Diseñar un control de semáforo para una intersección de calles. La secuencia normal del
--semáforo será rojo durante 60 s, verde durante 50 s y amarillo durante 10 s. Cuando una
--calle está en verde o amarillo la otra calle estará en rojo. Cada dirección tiene un semáforo
--detector de servicios de emergencia y un pulsador de cruce peatonal.

entity semaforo is
    generic (
        constant N_PRE      : integer; -- numero de bits del prescaler
        constant C_PRE      : unsigned(N_PRE-1 downto 0); -- valor de precarga para 1 segundo
        constant N_TIMER    : integer:= 6; -- numero de bits del timer
        constant T_VERDE    : integer:= 50; -- tiempo en verde
        constant T_AMARILLO : integer:= 10; -- tiempo en amarillo
        constant T_PEATON   : integer:= 50); -- tiempo extra verde peatonal
    port (
        clk : in std_logic;
        nreset : in std_logic;
        
        solicitud_peaton_a : in std_logic;
        solicitud_peaton_b : in std_logic;
        solicitud_emergencia_a : in std_logic;
        solicitud_emergencia_b : in std_logic;
        confirmacion_peaton_a : out std_logic;
        confirmacion_peaton_b : out std_logic;
        confirmacion_emergencia_a : out std_logic;
        confirmacion_emergencia_b : out std_logic;

        transito_a : out std_logic_vector (1 downto 0);
        peaton_a : out std_logic; -- habilitacion tiempo extra peatonal A
        transito_b : out std_logic_vector (1 downto 0);
        peaton_b : out std_logic); -- habilitacion tiempo extra peatonal B
end semaforo;

architecture arch of semaforo is
    signal recarga : std_logic_vector(N_TIMER-1 downto 0);
    signal listo : std_logic;
    signal rst_timer : std_logic := '0';
    signal hab_timer : std_logic;
    signal cero : std_logic;
    signal verde : std_logic_vector(1 downto 0):= "01";
    signal amarillo : std_logic_vector(1 downto 0):= "11";
    signal rojo : std_logic_vector(1 downto 0):= "10";
    signal est_act, est_sig: std_logic_vector(2 downto 0);

begin
    
  --registro/memoria de estado
memoria_estado : process(clk)
begin
    if rising_edge(clk) then
        if nreset = '0' then
            est_act <= "000"; -- estado inicial
        else
            est_act <= est_sig;
        end if;
    end if;
end process;

    --prescaler
p1 :entity prescaler port map(
        nreset => nreset, -- sincrónico
        clk    => clk,
        preload => std_logic_vector(C_PRE),
        tc     => hab_timer
    );

        --timer
t1: entity timer port map(
    clk => clk,
    reset => not nreset,
    hab => hab_timer,
    preload => recarga,
    T => listo,
    Z => cero
    );

--maquina de estados
maquina_estados : process(all)
    begin
        est_sig <= est_act;
        case est_act is
            when "000" => -- verde A
                if listo and hab_timer then
                    est_sig <= "001"; -- pasar a amarillo A
                end if;
            when "001" => -- amarillo A
                if listo and hab_timer then
                    est_sig <= "010"; -- pasar a verde B
                end if;
            when "010" => -- verde B
                if listo and hab_timer then
                    est_sig <= "011"; -- pasar a amarillo B
                end if;
            when "011" => -- amarillo B
                if listo and hab_timer then
                    est_sig <= "000"; -- pasar a verde A
                end if;
            when others =>
                est_sig <= "000"; -- estado inicial
        end case;
    end process;

--Salidas
salida : process(all)
    begin
    peaton_a <= '0';
    peaton_b <= '0';
        case est_act is
            when "000" => -- verde A
                transito_a <= verde;
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
            when "001" => -- amarillo A
                transito_a <= amarillo;
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_VERDE-1, N_TIMER));
            when "010" => -- verde B
                transito_a <= rojo;
                transito_b <= verde;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
            when "011" => -- amarillo B
                transito_a <= rojo;    
                transito_b <= amarillo;
                recarga <= std_logic_vector(to_unsigned(T_VERDE-1, N_TIMER));
            when others =>
                transito_a <= verde; 
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
        end case;
    end process;
    -- confirmaciones siempre en 0 (no implementado)
    confirmacion_peaton_a  <= '0';
    confirmacion_peaton_b  <= '0';
    confirmacion_emergencia_a  <= '0';
    confirmacion_emergencia_b  <= '0';
end arch;