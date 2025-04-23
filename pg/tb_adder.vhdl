library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_adder is
end entity;

architecture Behavioral of tb_adder is  -- Corrigido nome da architecture

    component adder is
        port(
            a, b : in std_logic_vector(1 downto 0);
            o : out std_logic_vector(2 downto 0)
        );
    end component;

    signal a, b : std_logic_vector(1 downto 0) := (others => '0');
    signal o : std_logic_vector(2 downto 0);

begin   

    uut: adder port map(a => a, b => b, o => o);

    stim: process
    begin
        assert false report "simulando" severity note;
        wait for 1 ms;

        a <= "01";
        b <= "00";
        wait for 1 ms;

        a <= "10";
        b <= "01";
        wait for 1 ms;
        
        a <= "10";
        b <= "10";
        wait for 1 ms;

        a <= "11";
        b <= "11";
        wait for 1 ms;
        wait;
    end process;

end Behavioral;
