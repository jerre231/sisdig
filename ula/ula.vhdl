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

architecture Behavioral of ula is

    signal a, b       : signed (3 downto 0) := (others => '0');
    signal operation  : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal stableSign : STD_LOGIC;

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
    process(clock)
    begin
        if rising_edge(clock) then
            if stableSign = '1' then
                case currentState is
                    when s0 =>
                        operation <= std_logic_vector(input(2 downto 0)); -- Opcode
                        currentState <= s1;
                    when s1 =>
                        a <= input;
                        currentState <= s2;
                    when s2 =>
                        b <= input;
                        currentState <= s3;
                    when s3 =>
                        case operation is
                            when "000" =>  -- ADD
                                output <= resize(a + b, 4);
                            when "001" =>  -- SUB
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
                        currentState <= s0;
                end case;
            end if;
        end if;
    end process;

    -- Indicadores de estado
    with currentState select
        indicators <= "1000" when s0,
                      "0100" when s1,
                      "0010" when s2,
                      "0001" when s3;

end Behavioral;