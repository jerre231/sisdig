library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity and_gate is
    port (
        A : in STD_LOGIC_VECTOR(3 downto 0);
        B : in STD_LOGIC_VECTOR(3 downto 0);

        ret : out STD_LOGIC_VECTOR(3 downto 0);
        flag_zero, flag_neg : out STD_LOGIC
    );

end and_gate;

architecture Behavioral of and_gate is

begin

    ret <= A AND B;

    flag_zero <= '1' when ret = "0000" else '0';
    
    flag_neg <= '1' when ret(3) = '1' else '0';

end Behavioral;
