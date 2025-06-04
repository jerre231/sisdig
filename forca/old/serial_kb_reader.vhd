--
--
--  Codigo nao funciona como o esperado! Hipotese principal:
--
--  Nao ha logica de inicio e parada para o estabelecimento de comunicao
--  do proprio protocolo para PS/2.
--
--  Propostas para correcao:
--
--  Adicionar filtro, separar logica de estado, utilizar estados idle, dps e load.
--  Confirmacao para iniciar/encerrar comunicacao e adicionar sistema de buffer para
--  cada digito
--
--  TODO: Refatorar com base no manual ->
--  https://blog.aku.edu.tr/ismailkoyuncu/files/2017/04/02_ebook.pdf
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity serial_kb_reader is 
    port(
        data: in std_logic; -- Keyboard scan data
        pclk: in std_logic; -- Keyboard input clock

        keyDisplay: out std_logic_vector (7 downto 0) -- Temp key display in fpga leds
    );

end serial_kb_reader;

architecture Behavioral of serial_kb_reader is

    type stateType is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
    signal state, nextState: stateType;

    signal store: std_logic_vector (9 downto 0); -- Store key data, then display with keyDisplay (store(0) = startBit)

    -- Receive and store data
    process(pclk) -- update: process(pclk, data)
    begin

        -- Skip clock rise
        if pclk'event and pclk = '1' then
            state <= nextState;
        end if;

        if pclk'event and pclk = '0' then

            if state = S0 then
                store(0) <= data;
                nextState <= S1;

            elsif state = S1 then
                store(1) <= data;
                nextState <= S2;

            elsif state = S2 then
                store(2) <= data;
                nextState <= S3;

            elsif state = S3 then
                store(3) <= data;
                nextState <= S4;

            elsif state = S4 then
                store(4) <= data;
                nextState <= S5;

            elsif state = S5 then
                store(5) <= data;
                nextState <= S6;

            elsif state = S6 then
                store(6) <= data;
                nextState <= S7;

            elsif state = S7 then
                store(7) <= data;
                nextState <= S8;

            elsif state = S8 then
                store(8) <= data;
                nextState <= S9;

            elsif state = S9 then
                store(9) <= data;
                nextState <= S0; -- Return to initial state

            end if;
        end if;
    end process;

--    -- Display store data (probably temporary)
--    process(store)
--    begin
--        keyDisplay(7 downto 0) <= store(8 downto 1);
--    end process;

    keyDisplay <= store(8 downto 1);

end Behavioral;
