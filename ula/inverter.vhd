library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity inverter is
    port (
        A : in STD_LOGIC_VECTOR(3 downto 0);

        inv : out STD_LOGIC_VECTOR(3 downto 0);
        flag_neg : out STD_LOGIC;
        flag_zero : out STD_LOGIC
    );

end inverter;

architecture Behavioral of inverter is
    
signal inv_temp : STD_LOGIC_VECTOR(3 downto 0);

begin
    for i in 3 downto 0 generate
        inv_temp(i) <= not A(i);
    end generate;

    inv <= inv_temp;

    flag_zero <= '1' when inv_temp = "0000" else '0';
    flag_zero <= '1' when inv_temp = "0000" else '0';

end Behavioral;