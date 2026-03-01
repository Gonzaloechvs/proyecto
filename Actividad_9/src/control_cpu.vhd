library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_cpu is
    port (
        clk        : in  std_logic;
        nreset     : in  std_logic;
        take_branch: in  std_logic;
        op         : in  std_logic_vector (6 downto 0);
        jump       : out std_logic;
        s1pc       : out std_logic;
        wpc        : out std_logic;
        wmem       : out std_logic;
        wreg       : out std_logic;
        sel_imm    : out std_logic;
        data_addr  : out std_logic;
        mem_source : out std_logic;
        imm_source : out std_logic;
        winst      : out std_logic;
        alu_mode   : out std_logic_vector (1 downto 0);
        imm_mode   : out std_logic_vector (2 downto 0)
    );
end control_cpu;

architecture arch of control_cpu is

    -- Definición de todos los estados
    type estado_t is (
        INICIO, LEE_MEM_PC, CARGA_IR, DECODIFICA, 
        EXEC_R, EXEC_I, 
        EXEC_LOAD, CARGA_RD_DE_MEM, 
        EXEC_STORE, 
        EXEC_BRANCH, BRANCH_TAKEN, BRANCH_NOT_TAKEN,
        EXEC_JAL_1, EXEC_JAL_2, 
        EXEC_JALR_1, EXEC_JALR_2, 
        EXEC_LUI, EXEC_AUIPC
    );
    signal estado_sig, estado : estado_t;

    -- imm mode
    subtype imm_mode_t is std_logic_vector (2 downto 0);
    constant IMM_CONST_4 : imm_mode_t := "000";
    constant IMM_I       : imm_mode_t := "001";
    constant IMM_S       : imm_mode_t := "010";
    constant IMM_B       : imm_mode_t := "011";
    constant IMM_U       : imm_mode_t := "100";
    constant IMM_J       : imm_mode_t := "101";

    -- Opcodes 
    constant OPC_LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant OPC_STORE  : std_logic_vector(6 downto 0) := "0100011";
    constant OPC_BRANCH : std_logic_vector(6 downto 0) := "1100011";
    constant OPC_JAL    : std_logic_vector(6 downto 0) := "1101111";
    constant OPC_JALR   : std_logic_vector(6 downto 0) := "1100111";
    constant OPC_OP_IMM : std_logic_vector(6 downto 0) := "0010011";
    constant OPC_OP     : std_logic_vector(6 downto 0) := "0110011";
    constant OPC_LUI    : std_logic_vector(6 downto 0) := "0110111";
    constant OPC_AUIPC  : std_logic_vector(6 downto 0) := "0010111";

begin

    registros : process (clk)
    begin
        if rising_edge(clk) then
            if not nreset then
                estado <= INICIO;
            else
                estado <= estado_sig;
            end if;
        end if;
    end process;

    logica_estado_siguiente : process (all) 
    begin
        estado_sig <= INICIO; -- Por defecto
        case( estado ) is
            when INICIO =>
                estado_sig <= LEE_MEM_PC;
            when LEE_MEM_PC =>
                estado_sig <= CARGA_IR;
            when CARGA_IR =>
                estado_sig <= DECODIFICA;
            when DECODIFICA =>
                case( op ) is
                    when OPC_LOAD   => estado_sig <= EXEC_LOAD;
                    when OPC_STORE  => estado_sig <= EXEC_STORE;
                    when OPC_OP     => estado_sig <= EXEC_R;
                    when OPC_OP_IMM => estado_sig <= EXEC_I;
                    when OPC_BRANCH => estado_sig <= EXEC_BRANCH;
                    when OPC_JAL    => estado_sig <= EXEC_JAL_1;
                    when OPC_JALR   => estado_sig <= EXEC_JALR_1;
                    when OPC_LUI    => estado_sig <= EXEC_LUI;
                    when OPC_AUIPC  => estado_sig <= EXEC_AUIPC;
                    when others     => estado_sig <= INICIO;
                end case;

            -- Secuencia de Load
            when EXEC_LOAD =>
                estado_sig <= CARGA_RD_DE_MEM;
            when CARGA_RD_DE_MEM =>
                estado_sig <= LEE_MEM_PC;

            -- Secuencia de Branch Evaluar y Saltar/No Saltar
            when EXEC_BRANCH =>
                if take_branch = '1' then
                    estado_sig <= BRANCH_TAKEN;
                else
                    estado_sig <= BRANCH_NOT_TAKEN;
                end if;
            
            -- Secuencia de JAL y JALR Guardar PC+4 y Saltar
            when EXEC_JAL_1 =>
                estado_sig <= EXEC_JAL_2;
            when EXEC_JALR_1 =>
                estado_sig <= EXEC_JALR_2;

            -- Todos los estados finales vuelven al Fetch
            when EXEC_R | EXEC_I | EXEC_STORE | BRANCH_TAKEN | BRANCH_NOT_TAKEN | 
                 EXEC_JAL_2 | EXEC_JALR_2 | EXEC_LUI | EXEC_AUIPC =>
                estado_sig <= LEE_MEM_PC;
                
            when others =>
                estado_sig <= INICIO;
        end case;
    end process;

    logica_salida : process (all)
    begin
        -- Valores por defecto
        wpc <= '0';
        wmem <= '0';
        winst <= '0';
        wreg <= '0';
        jump <= '0';
        s1pc <= '0';
        alu_mode <= "00";
        imm_mode <= IMM_CONST_4;
        sel_imm <= '0';
        data_addr <= '0';
        mem_source <= '0';
        imm_source <= '0';

        case (estado) is
            when INICIO =>
                -- por defecto

            when LEE_MEM_PC =>
                data_addr <= '0';

            when CARGA_IR =>
                winst <= '1';     -- Guardamos la instrucción leída en IR

            when DECODIFICA =>
                -- por defecto
            
            --arimeticas
            when EXEC_R =>
                alu_mode <= "10"; 
                wreg <= '1';
                wpc <= '1'; -- Incrementa PC normal (PC+4)

            when EXEC_I =>
                alu_mode <= "01";
                sel_imm <= '1';
                imm_mode <= IMM_I;
                wreg <= '1';
                wpc <= '1';

            --memorias
            when EXEC_LOAD =>
                alu_mode <= "00"; -- Sumamos rs1 + imm
                sel_imm <= '1';
                imm_mode <= IMM_I;
                data_addr <= '1'; -- Apuntamos a memoria de datos
                wpc <= '1';

            when CARGA_RD_DE_MEM =>
                mem_source <= '1';
                wreg <= '1';

            when EXEC_STORE =>
                alu_mode <= "00"; -- Sumamos rs1 + imm
                sel_imm <= '1';
                imm_mode <= IMM_S;
                data_addr <= '1'; 
                wmem <= '1';      -- Habilitamos escritura
                wpc <= '1';

            -- saltos cond branchs
            when EXEC_BRANCH =>
                alu_mode <= "11"; --alu_b compara rs1 y rs2
                sel_imm <= '0';
                
            when BRANCH_TAKEN =>
                alu_mode <= "00"; -- Sumamos
                s1pc <= '1';      -- ALU A = PC
                sel_imm <= '1';   -- ALU B = imm
                imm_mode <= IMM_B;
                jump <= '1';      -- Avisamos al multiplexor del PC que tome alu_y
                wpc <= '1';

            when BRANCH_NOT_TAKEN =>
                wpc <= '1';       -- Si no salta, solo incrementamos PC+4 normal

            -- saltos incond (JAL / JALR)
            when EXEC_JAL_1 | EXEC_JALR_1 =>
                -- Calculamos PC+4 y lo guardamos en 'rd'
                alu_mode <= "00";
                s1pc <= '1';      -- ALU A = PC
                sel_imm <= '1';
                imm_mode <= IMM_CONST_4; -- ALU B = 4
                wreg <= '1';      -- Escribimos el PC+4 en rd
            
            when EXEC_JAL_2 =>
                -- Calculamos el salto PC = PC + imm_j
                alu_mode <= "00";
                s1pc <= '1';
                sel_imm <= '1';
                imm_mode <= IMM_J;
                jump <= '1';
                wpc <= '1';

            when EXEC_JALR_2 =>
                -- Calculamos el salto PC = rs1 + imm_i
                alu_mode <= "00";
                s1pc <= '0';      -- ALU A = rs1
                sel_imm <= '1';
                imm_mode <= IMM_I;
                jump <= '1';
                wpc <= '1';

            --  LUI / AUIPC 
            when EXEC_LUI =>
                imm_source <= '1'; -- dato desde inmediato
                imm_mode <= IMM_U;
                wreg <= '1';
                wpc <= '1';

            when EXEC_AUIPC =>
                alu_mode <= "00";
                s1pc <= '1';       -- ALU A = PC
                sel_imm <= '1';    -- ALU B = imm_u
                imm_mode <= IMM_U;
                wreg <= '1';
                wpc <= '1';

            when others =>
        end case;
    end process;

end arch;