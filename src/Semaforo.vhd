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
    
    type estado_t is (
    VERDE_A, VERDE_A_AD, AMARILLO_A,
    VERDE_B, VERDE_B_AD, AMARILLO_B,
    EMERG_A, EMERG_B, CANCEL_VERDE_A, CANCEL_VERDE_B
);
    signal est_act, est_sig : estado_t;

    constant verde : std_logic_vector(1 downto 0):= "01";
    constant amarillo : std_logic_vector(1 downto 0):= "11";
    constant rojo : std_logic_vector(1 downto 0):= "10";

    signal recarga  : std_logic_vector(N_TIMER-1 downto 0);
    signal hab_timer, listo, cero : std_logic;
    signal rst_timer : std_logic := '0';

    signal emer_a_pend, emer_b_pend : std_logic := '0';
begin
    
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
        reset => rst_timer,
        hab => hab_timer,
        preload => recarga,
        T => listo,
        Z => cero
    );

--registro/memoria de estado
memoria_estado : process(clk, nreset)
    begin
        if nreset = '0' then
            rst_timer <= '1';
            est_act <=  VERDE_A; -- estado inicial
        elsif rising_edge(clk) then
                est_act <= est_sig;
                rst_timer <= '0';
        end if;
    end process;

--memoria de pedido peatonal
pedido_peatonal : process(clk, nreset)
    begin
        if nreset = '0' then
            confirmacion_peaton_a <= '0';
            confirmacion_peaton_b <= '0';
        elsif rising_edge(clk) then
            if solicitud_peaton_a and not peaton_a then
                confirmacion_peaton_a <= '1';
                    elsif peaton_a then
                    confirmacion_peaton_a <= '0';
            end if;
            if solicitud_peaton_b and not peaton_b then
                    confirmacion_peaton_b <= '1';
                elsif peaton_b then
                    confirmacion_peaton_b <= '0';
            end if;
        end if;
    end process;

--modo emergencia
modo_emergencia : process(clk, nreset)
begin
    if nreset = '0' then
        confirmacion_emergencia_a <= '0';
        confirmacion_emergencia_b <= '0';
        emer_a_pend <= '0';
        emer_b_pend <= '0';
    elsif rising_edge(clk) then
        -- Registrar emergencia pendiente si aparece la solicitud
        if solicitud_emergencia_a and not solicitud_emergencia_b then
            emer_a_pend <= '1';
            confirmacion_emergencia_a <= '1';
        elsif est_act = EMERG_A then
            emer_a_pend <= '0';  -- Se procesó al entrar a EMERG_A
        else 
            confirmacion_emergencia_a <= '0';
        end if;

        if solicitud_emergencia_b and not solicitud_emergencia_a then
            emer_b_pend <= '1';
            confirmacion_emergencia_b <= '1';
        elsif est_act = EMERG_B then
            emer_b_pend <= '0';  -- Se procesó al entrar a EMERG_B
        else
            confirmacion_emergencia_b <= '0';
        end if;
    end if;
end process;

--maquina de estados
maquina_estados : process(all)
    begin
        est_sig <= est_act;
        case est_act is
            when VERDE_A =>
                if emer_a_pend then
                    est_sig <= EMERG_A;  -- Emergencia propia
                elsif emer_b_pend then
                    est_sig <= EMERG_B; -- Interrumpe verde A, da prioridad a B
                elsif listo and hab_timer then
                    if confirmacion_peaton_a then
                        est_sig <= VERDE_A_AD;
                    else
                        est_sig <= AMARILLO_A;
                    end if;
                end if;
            when VERDE_A_AD => -- verde A adicional para peatonal
                if listo and hab_timer then
                    est_sig <= AMARILLO_A; -- pasar a amarillo A
                end if;
            when AMARILLO_A => -- amarillo A
                if emer_a_pend and not emer_b_pend then
                    est_sig <= EMERG_A;
                elsif listo and hab_timer then
                        est_sig <= VERDE_B; -- pasar a verde B
                end if;
            when VERDE_B =>
                if emer_b_pend then
                    est_sig <= EMERG_B;  -- Emergencia propia
                elsif emer_a_pend then
                    est_sig <= EMERG_A;  -- Interrumpe verde B, da prioridad a A
                elsif listo and hab_timer then
                    if confirmacion_peaton_b then
                        est_sig <= VERDE_B_AD;
                    else
                        est_sig <= AMARILLO_B;
                    end if;
                end if;
            when VERDE_B_AD => -- verde B adicional con peatonal
                if listo and hab_timer then
                    est_sig <= AMARILLO_B; -- pasar a amarillo B
                end if;
            when AMARILLO_B => -- amarillo B
                if emer_b_pend and not emer_a_pend then
                    est_sig <= EMERG_B;
                elsif listo and hab_timer then
                    est_sig <= VERDE_A; -- pasar a verde A
                end if;
            when EMERG_A =>
                if (listo or cero) and not solicitud_emergencia_a then
                    est_sig <= AMARILLO_A;
                end if;
            when EMERG_B =>
                if (listo or cero) and not solicitud_emergencia_b then
                    est_sig <= AMARILLO_B;
                end if;
            when others =>
                est_sig <= VERDE_A; -- estado inicial
        end case;
    end process;

--Salidas
salida : process(all)
    begin
    peaton_a  <= '0';
    peaton_b  <= '0';
    transito_a <= rojo;
    transito_b <= rojo;
    recarga <= std_logic_vector(to_unsigned(0, N_TIMER));
        case est_act is
            when VERDE_A => -- verde A
                transito_a <= verde;
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_VERDE-1, N_TIMER));
            when AMARILLO_A => -- amarillo A
                transito_a <= amarillo;
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
            when VERDE_B => -- verde B
                transito_a <= rojo;
                transito_b <= verde;
                recarga <= std_logic_vector(to_unsigned(T_VERDE-1, N_TIMER));
            when AMARILLO_B => -- amarillo B
                transito_a <= rojo;    
                transito_b <= amarillo;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
            when VERDE_A_AD => -- verde A con peatonal
                transito_a <= verde;
                transito_b <= rojo;
                peaton_a  <= '1';
                recarga <= std_logic_vector(to_unsigned(T_PEATON-1, N_TIMER));
            when VERDE_B_AD => -- verde B con peatonal
                transito_a <= rojo;
                transito_b <= verde;
                peaton_b  <= '1';
                recarga <= std_logic_vector(to_unsigned(T_PEATON-1, N_TIMER));
            when EMERG_A =>
                transito_a <= verde;
                transito_b <= rojo;
            when EMERG_B =>
                transito_b <= verde;
                transito_a <= rojo;
            when CANCEL_VERDE_A => 
                transito_a <= amarillo; 
                transito_b <= rojo;
            when CANCEL_VERDE_B => 
                transito_a <= rojo;
                transito_b <= amarillo;
            when others => 
                transito_a <= verde; 
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
        end case;
    end process;

end arch;