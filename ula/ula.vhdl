library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula is
    port(
        inputData : in signed (3 downto 0);
        button, clock : in STD_LOGIC;
        indicators : out STD_LOGIC_VECTOR (3 downto 0);
        outputData : out signed (3 downto 0)
    );
end ula;

--| indicators representam tanto o estado, quanto as flags:
--|
--| indicator(3) : flag carry
--| indicator(2) : flag zero
--| indicator(1) : flag overflow
--| indicator(0) : flag negativo

architecture Behavioral of ula is

    -- Sinais internos
    signal a, b       : signed (3 downto 0) := (others => '0');
    signal operation  : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal intOutput : signed (4 downto 0) := (others => '0');
    signal intIndicators: STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

    -- Sinal estavel do botao
    signal stableSign : STD_LOGIC;

    type state is (s0, s1, s2, s3);
    signal currentState : state := s0;

    -- Declaração do componente debouncer
    component debouncer
        port (
            clk  : in  STD_LOGIC;
            bIn  : in  STD_LOGIC;
            bOut : out STD_LOGIC
        );
    end component;

begin

    -- Instanciação do debouncer
    debounce_unit : debouncer
        port map (
            clk  => clock,
            bIn  => button,
            bOut => stableSign
        );

    -- Logica de mudanca de estado
    process(stableSign)
    begin
        if rising_edge(stableSign) then
            case currentState is
                when s0 => currentState <= s1;
                when s1 => currentState <= s2;
                when s2 => currentState <= s3;
                when s3 => currentState <= s0;
            end case;
        end if;
    end process;

    -- Processo sequencial da ULA
    process(clock)
    begin
        
        if rising_edge(clock) then
            case currentState is
                -- Seletor de operacoes
                when s0 =>
                    operation <= std_logic_vector(inputData(2 downto 0));
                    indicators <= "1000";
                    outputData <= "0000";
                
                -- Seletor operando A
                when s1 =>
                    a <= inputData;
                    indicators <= "0100";

                -- Seletor operando B
                when s2 =>
                    b <= inputData;
                    indicators <= "0010";

                -- Operacional
                when s3 =>
                    case operation is
                        when "000" =>  -- ADD
                            tempOutput <= resize(a, 5) + resize(b, 5);
                        when "001" =>  -- SUB
                            tempOutput <= resize(a, 5) - resize(b, 5);
                        when "010" =>  -- AND
                            tempOutput <= resize(signed(a and b), 5);
                        when "011" =>  -- OR
                            tempOutput <= resize(a or b, 5);
                        when "100" =>  -- XOR
                            tempOutput <= resize(a xor b, 5);
                        when "101" =>  -- NOT A
                            tempOutput <= resize(not a, 5);
                        when "110" =>  -- NOT B
                            tempOutput <= resize(not b, 5);
                        when "111" =>  -- NAND
                            tempOutput <= resize(not (a and b), 5);
                        when others =>
                            tempOutput <= (others => '0');
                    end case;

                    -- Output port
                    outputData <= tempOutput(3 downto 0);

                    -- Flags:

                    -- Negativo
                    indicators(0) <= tempOutput(3);

                    -- Zero
                    if tempOutput(3 downto 0) = "0000" then
                        indicators(2) <= '1';
                    else
                        indicators(2) <= '0';
                    end if;

                    -- Carry
                    indicators(3) <= tempOutput(4);

                    -- Overflow (válido só para ADD e SUB)
                    if operation = "000" or operation = "001" then
                        indicators(1) <= (a(3) xor tempOutput(3)) and not (a(3) xor b(3));
                    else
                        indicators(1) <= '0';
                    end if;
                    
                    --

            end case;
            
        end if;
    end process;

    -- -- Indicadores de estados
    -- process(currentState)
    -- begin
    --     case currentState is
    --         when s0 =>
    --             indicators <= "1000";
    --         when s1 =>
    --             indicators <= "0100";
    --         when s2 =>
    --             indicators <= "0010";
    --         when s3 =>
    --             indicators <= "0001";
    --     end case;
    -- end process;

end Behavioral;