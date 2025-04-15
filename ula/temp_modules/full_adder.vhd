library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
    Port (
        A     : in  STD_LOGIC;  -- Primeiro operando de entrada
        B     : in  STD_LOGIC;  -- Segundo operando de entrada
        Cin   : in  STD_LOGIC;  -- Entrada de carry (usada para +1 no complemento de 2)

        Sum   : out STD_LOGIC;  -- Saída da soma
        Cout  : out STD_LOGIC   -- Saída do carry
    );
end full_adder;

architecture Behavioral of full_adder is
begin
    process(A, B, Cin)
    begin
        Sum <= A xor B xor Cin;  -- Soma dos bits

        Cout <= (A and B) or (Cin and (A xor B));  -- Carry de saída
    end process;
end Behavioral;