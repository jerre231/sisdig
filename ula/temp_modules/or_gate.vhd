library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity or_gate is
    port (
        A : in STD_LOGIC_VECTOR(3 downto 0);
        B : in STD_LOGIC_VECTOR(3 downto 0);

        ret : out STD_LOGIC_VECTOR(3 downto 0);
        flag_zero, flag_neg : out STD_LOGIC
    );

end or_gate;

architecture Behavioral of or_gate is

begin

    ret <= A OR B;

    -- Define a flag_zero como '1' se o resultado for "0000"
    flag_zero <= '1' when ret = "0000" else '0';

    -- Define a flag_neg como '1' se o bit mais significativo (MSB) for '1'
    flag_neg <= '1' when ret(3) = '1' else '0';

end Behavioral;
