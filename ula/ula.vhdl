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
--| indicator(3) : flag overflow
--| indicator(2) : flag zero
--| indicator(1) : flag carry
--| indicator(0) : flag negativo

architecture Behavioral of ula is

    -- Sinais internos
    signal a, b       : signed (3 downto 0) := (others => '0');
    signal operation  : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal intOutput : signed (4 downto 0) := (others => '0');
    signal intIndicators: STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

    -- Sinais vetoriais (para trabalhar bit a bit)
    signal aV, aB : STD_LOGIC_VECTOR(3 downto 0);

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
                            intOutput <= resize(a, 5) + resize(b, 5);
                        when "001" =>  -- SUB
                            intOutput <= resize(a, 5) - resize(b,5);
                        when "010" =>  -- AND
                            intOutput(3 downto 0) <= signed(a and b);
                        when "011" =>  -- OR
                            intOutput(3 downto 0) <= signed(a or b);
                        when "100" =>  -- XOR
                            intOutput(3 downto 0) <= signed(a xor b);
                        when "101" =>  -- NOT A
                            intOutput(3 downto 0) <= not a;
                        when "110" =>  -- NOT B
                            intOutput(3 downto 0) <= not b;
                        when "111" =>  -- NAND
                            intOutput(3 downto 0) <= signed(not (a and b));
                        when others =>
                            intOutput(3 downto 0) <= (others => '0');
                    end case;
						  
                    -- Flags:

                    -- Negativo
                    intIndicators(0) <= intOutput(3);

                    -- Zero
                    if intOutput(3 downto 0) = "0000" then
                        intIndicators(2) <= '1';
                    else
                        intIndicators(2) <= '0';
                    end if;

                    -- Overflow e Carry (somente para ADD e SUB)
                    if operation = "000" then

                        -- Carry
                        intIndicators(1) <= intOutput(4);

                        -- Overflow
                        intIndicators(3) <= (aV(3) and bV(3) and not intOutput(3)) or (not aV(3) and not bV(3) and intOutput(3));

                    elsif operation = "001" then

                        -- Carry
                        intIndicators(1) <= '1' when a >= b else '0';

                        -- Overflow
                        intIndicators(3) <= (aV(3) and not bV(3) and not intOutput(3)) or (not aV(3) and bV(3) and intOutput(3));

                    else
                        intIndicators(1) <= '0';
                        intIndicators(3) <= '0';

                    end if;
                    
                    -- outputData port
                    outputData <= intOutput(3 downto 0);
						  
		    -- indicators port
		    indicators <= intIndicators;

            end case;
        end if;

    end process;
end Behavioral;
