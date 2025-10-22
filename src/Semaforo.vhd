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
    constant EST_VERDE_A     : std_logic_vector(2 downto 0) := "000";
    constant EST_VERDE_A_AD  : std_logic_vector(2 downto 0) := "100";
    constant EST_AMARILLO_A  : std_logic_vector(2 downto 0) := "001";
    constant EST_VERDE_B     : std_logic_vector(2 downto 0) := "010";
    constant EST_VERDE_B_AD  : std_logic_vector(2 downto 0) := "110";
    constant EST_AMARILLO_B  : std_logic_vector(2 downto 0) := "011";

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
            est_act <= EST_VERDE_A; -- estado inicial
        else
            est_act <= est_sig;
        end if;
    end if;
end process;

--memoria de pedido peatonal
pedido_peatonal : process(all)
begin
    if rising_edge(clk) then
        if nreset = '0' then
            peaton_a <= '0';
            peaton_b <= '0';
        else
            if solicitud_peaton_a and not confirmacion_peaton_a then
                peaton_a <= '1';
                elsif confirmacion_peaton_a then
                    peaton_a <= '0';
            end if;
            if solicitud_peaton_b and not confirmacion_peaton_b then
                peaton_b <= '1';
                elsif confirmacion_peaton_b then
                    peaton_b <= '0';
            end if;
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
            when EST_VERDE_A => -- verde A
                if listo and hab_timer then
                    if peaton_a then
                        est_sig <= EST_VERDE_A_AD; -- pasar a verde A adicional
                    else
                        est_sig <= EST_AMARILLO_A; -- pasar a amarillo A
                    end if;
                end if;
            when EST_VERDE_A_AD => -- verde A adicional para peatonal
                if listo and hab_timer then
                    est_sig <= EST_AMARILLO_A; -- pasar a amarillo A
                end if;
            when EST_AMARILLO_A => -- amarillo A
                if listo and hab_timer then
                    est_sig <= EST_VERDE_B; -- pasar a verde B
                end if;
            when EST_VERDE_B => -- verde B
                if listo and hab_timer then
                    if peaton_b then
                        est_sig <= EST_VERDE_B_AD; -- pasar a verde B adicional
                    else
                        est_sig <= EST_AMARILLO_B; -- pasar a amarillo B
                    end if;
                end if;
            when EST_VERDE_B_AD => -- verde B adicional con peatonal
                if listo and hab_timer then
                    est_sig <= EST_AMARILLO_B; -- pasar a amarillo B
                end if;
            when EST_AMARILLO_B => -- amarillo B
                if listo and hab_timer then
                    est_sig <= EST_VERDE_A; -- pasar a verde A
                end if;
            when others =>
                est_sig <= EST_VERDE_A; -- estado inicial
        end case;
    end process;

--Salidas
salida : process(all)
    begin
    confirmacion_peaton_a  <= '0';
    confirmacion_peaton_b  <= '0';
        case est_act is
            when EST_VERDE_A => -- verde A
                transito_a <= verde;
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_VERDE-1, N_TIMER));
            when EST_AMARILLO_A => -- amarillo A
                transito_a <= amarillo;
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
            when EST_VERDE_B => -- verde B
                transito_a <= rojo;
                transito_b <= verde;
                recarga <= std_logic_vector(to_unsigned(T_VERDE-1, N_TIMER));
            when EST_AMARILLO_B => -- amarillo B
                transito_a <= rojo;    
                transito_b <= amarillo;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
            when EST_VERDE_A_AD => -- verde A con peatonal
                transito_a <= verde;
                transito_b <= rojo;
                confirmacion_peaton_a  <= '1';
                recarga <= std_logic_vector(to_unsigned(T_PEATON-1, N_TIMER));
            when EST_VERDE_B_AD => -- verde B con peatonal
                transito_a <= rojo;
                transito_b <= verde;
                confirmacion_peaton_b  <= '1';
                recarga <= std_logic_vector(to_unsigned(T_PEATON-1, N_TIMER));
            when others =>
                transito_a <= verde; 
                transito_b <= rojo;
                recarga <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));
        end case;
    end process;

    -- emergencia siempre en 0 (no implementado)
    confirmacion_emergencia_a  <= '0';
    confirmacion_emergencia_b  <= '0';
end arch;