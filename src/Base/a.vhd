library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity semaforo is
    generic (
        N_PRE      : integer;
        C_PRE      : unsigned(N_PRE-1 downto 0);
        N_TIMER    : integer := 6;
        T_VERDE    : integer := 50;
        T_AMARILLO : integer := 10;
        T_PEATON   : integer := 50
    );
    port (
        clk, nreset                : in std_logic;

        solicitud_peaton_a         : in std_logic;
        solicitud_peaton_b         : in std_logic;
        solicitud_emergencia_a     : in std_logic;
        solicitud_emergencia_b     : in std_logic;

        confirmacion_peaton_a      : out std_logic;
        confirmacion_peaton_b      : out std_logic;
        confirmacion_emergencia_a  : out std_logic;
        confirmacion_emergencia_b  : out std_logic;

        transito_a                 : out std_logic_vector (1 downto 0);
        transito_b                 : out std_logic_vector (1 downto 0);
        peaton_a                   : out std_logic;
        peaton_b                   : out std_logic
    );
end semaforo;

architecture rtl of semaforo is

    ------------------------------------------------------------------
    -- Tipos y constantes
    ------------------------------------------------------------------
    type estado_t is (
        VERDE_A, VERDE_A_AD, AMARILLO_A,
        VERDE_B, VERDE_B_AD, AMARILLO_B,
        EMERG_A, EMERG_B
    );

    signal est_act, est_sig : estado_t;

    constant VERDE    : std_logic_vector(1 downto 0) := "01";
    constant AMARILLO : std_logic_vector(1 downto 0) := "11";
    constant ROJO     : std_logic_vector(1 downto 0) := "10";

    -- Timer / prescaler
    signal hab_timer, listo, cero : std_logic;
    signal recarga_next, recarga  : std_logic_vector(N_TIMER-1 downto 0);
    signal rst_timer              : std_logic;

    -- Confirmaciones internas
    signal conf_pea_a, conf_pea_b : std_logic;
    signal conf_eme_a, conf_eme_b : std_logic;

begin

    ------------------------------------------------------------------
    -- Prescaler y Timer
    ------------------------------------------------------------------
    p1 : entity work.prescaler
        port map (
            nreset  => nreset,
            clk     => clk,
            preload => std_logic_vector(C_PRE),
            tc      => hab_timer
        );

    t1 : entity work.timer
        port map (
            clk    => clk,
            reset  => rst_timer,
            hab    => hab_timer,
            preload=> recarga,
            T      => listo,
            Z      => cero
        );

    ------------------------------------------------------------------
    -- Registro de estado (sincrónico)
    ------------------------------------------------------------------
    process(clk, nreset)
    begin
        if nreset = '0' then
            est_act <= VERDE_A;
        elsif rising_edge(clk) then
            est_act <= est_sig;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Registro de confirmaciones peatonales (sincrónico)
    ------------------------------------------------------------------
    process(clk, nreset)
    begin
        if nreset = '0' then
            conf_pea_a <= '0';
            conf_pea_b <= '0';
        elsif rising_edge(clk) then
            if solicitud_peaton_a = '1' and peaton_a = '0' then
                conf_pea_a <= '1';
            elsif peaton_a = '1' then
                conf_pea_a <= '0';
            end if;

            if solicitud_peaton_b = '1' and peaton_b = '0' then
                conf_pea_b <= '1';
            elsif peaton_b = '1' then
                conf_pea_b <= '0';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Registro de confirmaciones de emergencia (sincrónico)
    ------------------------------------------------------------------
    process(clk, nreset)
    begin
        if nreset = '0' then
            conf_eme_a <= '0';
            conf_eme_b <= '0';
        elsif rising_edge(clk) then
            conf_eme_a <= solicitud_emergencia_a;
            conf_eme_b <= solicitud_emergencia_b;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Máquina de estados (combinacional)
    ------------------------------------------------------------------
    process(est_act, conf_eme_a, conf_eme_b, conf_pea_a, conf_pea_b,
            listo, hab_timer)
    begin
        -- Valores por defecto
        est_sig       <= est_act;
        rst_timer     <= '0';
        recarga_next  <= recarga;

        case est_act is
            ----------------------------------------------------------
            when VERDE_A =>
                if conf_eme_a = '1' then
                    est_sig <= EMERG_A;
                elsif conf_eme_b = '1' then
                    est_sig <= AMARILLO_A;
                    rst_timer <= '1';
                elsif listo = '1' and hab_timer = '1' then
                    if conf_pea_a = '1' then
                        est_sig <= VERDE_A_AD;
                    else
                        est_sig <= AMARILLO_A;
                    end if;
                end if;

            when VERDE_A_AD =>
                if listo = '1' and hab_timer = '1' then
                    est_sig <= AMARILLO_A;
                end if;

            when AMARILLO_A =>
                if conf_eme_a = '1' and conf_eme_b = '0' then
                    est_sig <= EMERG_A;
                elsif listo = '1' and hab_timer = '1' then
                    est_sig <= VERDE_B;
                end if;

            when VERDE_B =>
                if conf_eme_b = '1' then
                    est_sig <= EMERG_B;
                elsif conf_eme_a = '1' then
                    est_sig <= AMARILLO_B;
                    rst_timer <= '1';
                elsif listo = '1' and hab_timer = '1' then
                    if conf_pea_b = '1' then
                        est_sig <= VERDE_B_AD;
                    else
                        est_sig <= AMARILLO_B;
                    end if;
                end if;

            when VERDE_B_AD =>
                if listo = '1' and hab_timer = '1' then
                    est_sig <= AMARILLO_B;
                end if;

            when AMARILLO_B =>
                if conf_eme_a = '1' and conf_eme_b = '0' then
                    est_sig <= EMERG_A;
                elsif listo = '1' and hab_timer = '1' then
                    est_sig <= VERDE_A;
                end if;

            when EMERG_A =>
                if (listo = '1' or cero = '1') and conf_eme_a = '0' then
                    est_sig <= AMARILLO_A;
                end if;

            when EMERG_B =>
                if (listo = '1' or cero = '1') and conf_eme_b = '0' then
                    est_sig <= AMARILLO_B;
                end if;
        end case;
    end process;

    ------------------------------------------------------------------
    -- Salidas (combinacional)
    ------------------------------------------------------------------
    process(est_act)
    begin
        -- Valores por defecto
        transito_a   <= ROJO;
        transito_b   <= ROJO;
        peaton_a     <= '0';
        peaton_b     <= '0';
        recarga_next <= (others => '0');

        case est_act is
            when VERDE_A =>
                transito_a   <= VERDE;
                transito_b   <= ROJO;
                recarga_next <= std_logic_vector(to_unsigned(T_VERDE-1, N_TIMER));

            when AMARILLO_A =>
                transito_a   <= AMARILLO;
                transito_b   <= ROJO;
                recarga_next <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));

            when VERDE_B =>
                transito_a   <= ROJO;
                transito_b   <= VERDE;
                recarga_next <= std_logic_vector(to_unsigned(T_VERDE-1, N_TIMER));

            when AMARILLO_B =>
                transito_a   <= ROJO;
                transito_b   <= AMARILLO;
                recarga_next <= std_logic_vector(to_unsigned(T_AMARILLO-1, N_TIMER));

            when VERDE_A_AD =>
                transito_a   <= VERDE;
                transito_b   <= ROJO;
                peaton_a     <= '1';
                recarga_next <= std_logic_vector(to_unsigned(T_PEATON-1, N_TIMER));

            when VERDE_B_AD =>
                transito_a   <= ROJO;
                transito_b   <= VERDE;
                peaton_b     <= '1';
                recarga_next <= std_logic_vector(to_unsigned(T_PEATON-1, N_TIMER));

            when EMERG_A =>
                transito_a   <= VERDE;
                transito_b   <= ROJO;

            when EMERG_B =>
                transito_a   <= ROJO;
                transito_b   <= VERDE;
        end case;
    end process;

    ------------------------------------------------------------------
    -- Asignaciones finales
    ------------------------------------------------------------------
    recarga <= recarga_next;
    confirmacion_peaton_a <= conf_pea_a;
    confirmacion_peaton_b <= conf_pea_b;
    confirmacion_emergencia_a <= conf_eme_a;
    confirmacion_emergencia_b <= conf_eme_b;

end rtl;
