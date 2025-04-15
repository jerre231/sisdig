library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ula is
    port (
        A : in STD_LOGIC_VECTOR(3 downto 0);
        B : in STD_LOGIC_VECTOR(3 downto 0);
        OP : in STD_LOGIC_VECTOR(2 downto 0);
        clk : in STD_LOGIC;

        S : out STD_LOGIC_VECTOR(4 downto 0);
        flag_zero, flag_neg, flag_ow : out STD_LOGIC;
        Cout : out STD_LOGIC
    );
end ula;

architecture Behavioral of ula is

    signal state : STD_LOGIC_VECTOR(1 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then

            case OP is

                when "000" => -- ADD
                    S <= A + B;

                    Cout <= S(4);

                    flag_zero <= S(3) or S(2) or S(1) or S(0);
                    flag_neg <= S(3);
                    flag_ow <= S(4);

                when "001" => -- SUB
                    S <= A - B;

                    Cout <= S(4);

                    flag_zero <= S(3) or S(2) or S(1) or S(0);
                    flag_neg <= S(3);
                    flag_ow <= S(4);

                when "010" => -- AND
                    S <= A and B;
                    
                    Cout <= '0';

                    flag_zero <= S(3) or S(2) or S(1) or S(0);
                    flag_neg <= '0';
                    flag_ow <= '0';

                when "011" => -- OR
                    S <= A or B;
                    
                    Cout <= '0';

                    flag_zero <= S(3) or S(2) or S(1) or S(0);
                    flag_neg <= '0';
                    flag_ow <= '0';

                when "100" => -- XOR
                    S <= A xor B;
                    
                    Cout <= '0';
                    
                    flag_zero <= S(3) or S(2) or S(1) or S(0);
                    flag_neg <= S(3);
                    flag_ow <= '0';

                when "101" => -- NOT A
                    S <= not A;
                    
                    Cout <= '0';

                    flag_zero <= S(3) or S(2) or S(1) or S(0);
                    flag_neg <= S(3);
                    flag_ow <= '0';

                when "110" => -- NOT B
                    S <= not B;
                    
                    Cout <= '0';
                    flag_zero <= S(3) or S(2) or S(1) or S(0);
                    flag_neg <= S(3);
                    flag_ow <= '0';

                when "111" => -- NAND
                    S <= not (A and B);
                    
                    Cout <= '0';
                    flag_zero <= S(3) or S(2) or S(1) or S(0);
                    flag_neg <= '0';
                    flag_ow <= '0';
            end case;
        end if;
    end process;
end Behavioral;