library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity multiplier is
    Port (
        A : in STD_LOGIC_VECTOR(3 downto 0); -- 4-bit input A
        B : in STD_LOGIC_VECTOR(3 downto 0); -- 4-bit input B

        P : out STD_LOGIC_VECTOR(7 downto 0); -- 8-bit output Product
        flag_zero : out STD_LOGIC;
        flag_neg : out STD_LOGIC
    );
end multiplier;

architecture Behavioral of multiplier is
begin
    process(A, B)
    begin
        P <= STD_LOGIC_VECTOR(unsigned(A) * unsigned(B));

        -- Set flag_zero if P is all zeros
        if P = "00000000" then
            flag_zero <= '1';
        else
            flag_zero <= '0';
        end if;

        -- Set flag_neg if the most significant bit of P is '1'
        flag_neg <= P(7);
    end process;
end Behavioral;