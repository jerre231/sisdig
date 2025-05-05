library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula is
    port(
        input : in signed (3 downto 0);
        button, clock : in STD_LOGIC;
        indicators : out signed (3 downto 0);
        output : out signed (3 downto 0)
    );
end ula;

--| indicators representam tanto o estado, quanto as flags:
--|
--| indicator(3) : flag carry
--| indicator(2) : flag zero
--| indicator(1) : flag overflow
--| indicator(0) : flag negativo

architecture Behavioral of ula is

    signal a, b       : signed (3 downto 0) := (others => '0');
    signal operation  : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal stableSign : STD_LOGIC;
    signal temp_out : STD_LOGIC_VECTOR (4 downto 0);

    type state is (s0, s1, s2, s3);
    signal currentState : state := s0;

    -- Declaração do componente Debouncer
    component debouncer
        port (
            clk  : in  STD_LOGIC;
            bIn  : in  STD_LOGIC;
            bOut : out STD_LOGIC
        );
    end component;

begin

    -- Instanciação do debouncer externo
    debounce_unit : debouncer
        port map (
            clk  => clock,
            bIn  => button,
            bOut => stableSign
        );

    -- Máquina de estados da ULA
    process(clock, stableSign)
    begin
        
        -- Logica de troca de estados
        if rising_edge(stableSign) then
            case currentState is
                when s0 => currentState <= s1;
                when s1 => currentState <= s2;
                when s2 => currentState <= s3;
                when s3 => currentState <= s0;
            end case;
        end if;

        if rising_edge(clock) then
            case currentState is
                when s0 =>
                    operation <= std_logic_vector(input(2 downto 0));
                    indicators <= "1000";
                    output <= "0000"
                when s1 =>
                    a <= input;
                    indicators <= "0100";
                when s2 =>
                    b <= input;
                    indicators <= "0010";
                when s3 =>
                    case operation is
                        when "000" =>  -- ADD
                            temp_out <= resize(a, 5) + resize(b, 5);
                            indicators(3) <= temp_out(4)
                            indicators(1) <= (a(3) xor not b(3)) and (a(3) xor temp_out(3))
                            output <= resize(a + b, 4);

                        when "001" =>  -- SUB
                            temp_out <= resize(a, 5) + resize(b, 5);
                            indicators(3) <= temp_out(4)
                            indicators(1) <= (a(3) xor b(3)) and (a(3) xor temp_out(3))
                            output <= resize(a - b, 4);

                        when "010" =>  -- AND
                            output <= a and b;

                        when "011" =>  -- OR
                            output <= a or b;

                        when "100" =>  -- XOR
                            output <= a xor b;

                        when "101" =>  -- NOT A
                            output <= not a;

                        when "110" =>  -- NOT B
                            output <= not b;

                        when "111" =>  -- NAND
                            output <= not (a and b);

                        when others =>
                            output <= (others => '0');

                    end case;

                    -- Flags comuns a todas as operações
                    indicators(0) := output(3);  -- Negativo (bit de sinal)
                    indicators(2) := '1' when output = "0000" else '0';

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