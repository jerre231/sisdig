library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ula is
    port (
        I : in STD_LOGIC_VECTOR(3 downto 0);
        b_clk : in STD_LOGIC;
        clk : in STD_LOGIC;

        O : out STD_LOGIC_VECTOR(4 downto 0);
        flag_zero, flag_neg, flag_ow : out STD_LOGIC;
        Cout : out STD_LOGIC
    );
end ula;

architecture Behavioral of ula is

    signal OP, A, B : STD_LOGIC_VECTOR(3 downto 0);
    signal state : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal S : STD_LOGIC_VECTOR(4 downto 0);
    signal b_stable : STD_LOGIC;

    component debouncer is
        port (
            clock : in STD_LOGIC;
            button_in : in STD_LOGIC;
            button_out : out STD_LOGIC
        );
    end component;

begin

    D0: debouncer port map(
        clock => clk,
        button_in => b_clk,
        button_out => b_stable
        );
    
    
    process(b_stable, state)
    begin
        if b_stable = '1' then
            state <= state + "01";
        end if;
    end process;

    process(state, OP)
    begin
        case state is
            when "00" => -- SELECT OP
                OP <= I;

            when "01" => -- SELECT A
                A <= I;

            when "10" => -- SELECT B
                B <= I;

            when "11" => -- SHOW OUTPUTS
                case OP is
                    when "0000" => -- ADD
                        S <= A + B;

                        Cout <= S(4);

                        flag_zero <= not (S(3) or S(2) or S(1) or S(0));
                        flag_neg <= S(3);
                        flag_ow <= S(4);

                    when "0001" => -- SUB
                        S <= A - B;

                        Cout <= S(4);

                        flag_zero <= not (S(3) or S(2) or S(1) or S(0));
                        flag_neg <= S(3);
                        flag_ow <= S(4);

                    when "0010" => -- AND
                        S <= A and B;

                        Cout <= '0';

                        flag_zero <= not (S(3) or S(2) or S(1) or S(0));
                        flag_neg <= '0';
                        flag_ow <= '0';

                    when "0011" => -- OR
                        S <= A or B;

                        Cout <= '0';

                        flag_zero <= not (S(3) or S(2) or S(1) or S(0));
                        flag_neg <= '0';
                        flag_ow <= '0';

                    when "0100" => -- XOR
                        S <= A xor B;

                        Cout <= '0';

                        flag_zero <= not (S(3) or S(2) or S(1) or S(0));
                        flag_neg <= S(3);
                        flag_ow <= '0';

                    when "0101" => -- NOT A
                        S <= not A;

                        Cout <= '0';

                        flag_zero <= not (S(3) or S(2) or S(1) or S(0));
                        flag_neg <= S(3);
                        flag_ow <= '0';

                    when "0110" => -- NOT B
                        S <= not B;

                        Cout <= '0';

                        flag_zero <= not (S(3) or S(2) or S(1) or S(0));
                        flag_neg <= S(3);
                        flag_ow <= '0';

                    when "0111" => -- NAND
                        S <= not (A and B);

                        Cout <= '0';

                        flag_zero <= not (S(3) or S(2) or S(1) or S(0));
                        flag_neg <= '0';
                        flag_ow <= '0';

                    when others =>
                        S <= (others => '0');
                        Cout <= '1';

                        flag_zero <= '1';
                        flag_neg <= '1';
                        flag_ow <= '1';
                end case;

                O <= S; -- SHOW MAIN OUTPUT

            when others =>
                -- Do nothing

        end case;
    end process;
end Behavioral;