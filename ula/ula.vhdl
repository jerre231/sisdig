library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Declaring entity
entity ula is
    port(
        I : in STD_LOGIC_VECTOR(3 downto 0);
        button : in STD_LOGIC;
        clk : in STD_LOGIC;
      
        S : out STD_LOGIC_VECTOR(3 downto 0);
        F_Z, F_N, F_C, F_O : out STD_LOGIC
    );
end ula;

-- Architecture of ULA
architecture Behavioral of ula is

    component debouncer
        port(
            clock      : in STD_LOGIC;
            button_in  : in STD_LOGIC;
            button_out : out STD_LOGIC
        );
    end component;

    signal stable : STD_LOGIC;
    signal A, B : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal S_temp : STD_LOGIC_VECTOR(4 downto 0);
    signal OP : STD_LOGIC_VECTOR(2 downto 0);

    type state is (S0, S1, S2, S3);
    signal current_state : state := S0;
    
begin

D0: debouncer port map(clock => clk, button_in => button, button_out => stable);

    process(stable)
    begin
    if rising_edge(stable) then
        case current_state is
            when S0 => -- SELECT OP
                current_state <= S1;
                OP(2 downto 0) <= I(2 downto 0);

            when S1 => -- SELECT A
                current_state <= S2;
                A <= I;

            when S2 => -- SELECT B
                current_state <= S3;
                B <= I;

            when S3 => -- SHOW OUTPUTS
                current_state <= S0;
            
                case OP is
                    when "000" => -- ADD
                        S_temp <= ('0' & A) + ('0' & B);
                        S <= S_temp(3 downto 0);
                        F_Z <= '1' when S_temp(3 downto 0) = "0000" else '0';
                        F_N <= S_temp(3);
                        F_C <= S_temp(4);
                        F_O <= '0'; -- Simplificado
            
                    when "001" => -- SUB
                        S_temp <= ('0' & A) - ('0' & B);
                        S <= S_temp(3 downto 0);
                        F_Z <= '1' when S_temp(3 downto 0) = "0000" else '0';
                        F_N <= S_temp(3);
                        F_C <= S_temp(4);
                        F_O <= '0'; -- Simplificado
            
                    when "010" => -- AND
                        S_temp(3 downto 0) <= A and B;
                        S_temp(4) <= '0';
                        S <= S_temp(3 downto 0);
                        F_Z <= '1' when S_temp(3 downto 0) = "0000" else '0';
                        F_N <= S_temp(3);
                        F_C <= '0';
                        F_O <= '0';
            
                    when "011" => -- OR
                        S_temp(3 downto 0) <= A or B;
                        S_temp(4) <= '0';
                        S <= S_temp(3 downto 0);
                        F_Z <= '1' when S_temp(3 downto 0) = "0000" else '0';
                        F_N <= S_temp(3);
                        F_C <= '0';
                        F_O <= '0';
            
                    when "100" => -- XOR
                        S_temp(3 downto 0) <= A xor B;
                        S_temp(4) <= '0';
                        S <= S_temp(3 downto 0);
                        F_Z <= '1' when S_temp(3 downto 0) = "0000" else '0';
                        F_N <= S_temp(3);
                        F_C <= '0';
                        F_O <= '0';
            
                    when "101" => -- NOT A
                        S_temp(3 downto 0) <= not A;
                        S_temp(4) <= '0';
                        S <= S_temp(3 downto 0);
                        F_Z <= '1' when S_temp(3 downto 0) = "0000" else '0';
                        F_N <= S_temp(3);
                        F_C <= '0';
                        F_O <= '0';
            
                    when "110" => -- NOT B
                        S_temp(3 downto 0) <= not B;
                        S_temp(4) <= '0';
                        S <= S_temp(3 downto 0);
                        F_Z <= '1' when S_temp(3 downto 0) = "0000" else '0';
                        F_N <= S_temp(3);
                        F_C <= '0';
                        F_O <= '0';
            
                    when "111" => -- NAND
                        S_temp(3 downto 0) <= not (A and B);
                        S_temp(4) <= '0';
                        S <= S_temp(3 downto 0);
                        F_Z <= '1' when S_temp(3 downto 0) = "0000" else '0';
                        F_N <= S_temp(3);
                        F_C <= '0';
                        F_O <= '0';
            
                    when others =>
                        S_temp <= (others => '0');
                        S <= S_temp(3 downto 0);
                        F_Z <= '1';
                        F_N <= '0';
                        F_C <= '0';
                        F_O <= '0';
            
                end case;     
        end case;
    end if;
    end process;

end Behavioral;

