library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder is
    port(
        a, b : in std_logic_vector(1 downto 0);
        o : out std_logic_vector(2 downto 0)  -- Corrigido para out
    );
end entity;

architecture logic of adder is
    signal s : std_logic_vector(1 downto 0);
    signal cout : std_logic;
begin
    s <= a + b;
    cout <= not(s(1)) and (a(1) or b(1));

    o(0) <= s(0);
    o(1) <= s(1);
    o(2) <= cout;
end logic;