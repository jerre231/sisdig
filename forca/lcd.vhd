LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LCD IS
    PORT(LCD_DB: OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Barramento de dados do LCD (8 bits)
         RS:OUT STD_LOGIC; -- Pino Register Select (0 para comando, 1 para dado)
         RW:OUT STD_LOGIC; -- Pino Read/Write (0 para escrever, 1 para ler - aqui sempre escrevendo)
         CLK:IN STD_LOGIC; -- Sinal de clock principal da FPGA
         OE:OUT STD_LOGIC; -- Pino Enable do LCD (ativo em nível baixo para escrita)
         RST:IN STD_LOGIC; -- Sinal de Reset assíncrono
         LEDS : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- Saída para LEDs (para depuração, mostra o keycode)
         PS2D, PS2C: IN STD_LOGIC); -- Pinos de dados e clock do teclado PS/2
END LCD;

ARCHITECTURE BEHAVIORAL OF LCD IS

------------------------------------------------------------------
--  INSTANCIAR COMPONENTES
------------------------------------------------------------------
-- Componente para interface com o teclado PS/2
COMPONENT KB_CODE PORT(CLK, RESET: IN  STD_LOGIC; -- Clock e Reset para o teclado
                       PS2D, PS2C: IN  STD_LOGIC; -- Dados e Clock do PS/2
                       RD_KEY_CODE: IN STD_LOGIC; -- Sinal para liberar o buffer do teclado
                       KEY_CODE: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);-- Código da tecla lida no buffer
                       KB_BUF_EMPTY: OUT STD_LOGIC); -- Indica se o buffer do teclado está vazio (0 se tem tecla)
END COMPONENT KB_CODE;

------------------------------------------------------------------
--  DECLARAÇÕES
-----------------------------------------------------------------

-- Tipos de estado para a Máquina de Estados de Controle do LCD
TYPE MSTATE IS (STFUNCTIONSET,          -- Estado para enviar o comando Function Set
                STDISPLAYCTRLSET,       -- Estado para enviar o comando Display Control Set
                STDISPLAYCLEAR,         -- Estado para enviar o comando Clear Display
                STPOWERON_DELAY,        -- Estado de atraso inicial após ligar
                STFUNCTIONSET_DELAY,    -- Atraso após Function Set
                STDISPLAYCTRLSET_DELAY, -- Atraso após Display Control Set
                STDISPLAYCLEAR_DELAY,   -- Atraso após Clear Display
                STINITDNE,              -- Estado de inicialização concluída
                STACTWR,                -- Estado para ativar a escrita no LCD
                STCHARDELAY);           -- Atraso após escrita de caractere/comando

-- Tipos de estado para a Máquina de Estados de Controle de Escrita (Enable)
TYPE WSTATE IS (STRW,                   -- Estado para configurar RW
                STENABLE,               -- Estado para pulsar o Enable
                STIDLE);                -- Estado ocioso

-- Tipos de estado para o "Jogo da Forca" (não totalmente implementado como jogo completo)
TYPE JESTADOS IS (JESPERA,              -- Estado de espera
                  JACERTO,              -- Estado de acerto
                  JERRO,                -- Estado de erro
                  JPERDE);              -- Estado de perda

-- Tipos de estado para a Máquina de Estados de Leitura do Teclado
TYPE MLEITOR IS (MINICIAL,              -- Estado inicial (espera por tecla)
                MMEIO,                  -- Estado intermediário (tecla lida)
                MFINAL);                -- Estado final (processamento da tecla)

SIGNAL CLKCOUNT:STD_LOGIC_VECTOR(5 DOWNTO 0); -- Contador para gerar um clock de 1us
SIGNAL ACTIVATEW:STD_LOGIC:= '0'; -- Sinal para ativar a máquina de estados de escrita do LCD
SIGNAL COUNT:STD_LOGIC_VECTOR (16 DOWNTO 0):= "00000000000000000"; -- Contador de atraso para o LCD
SIGNAL DELAYOK:STD_LOGIC:= '0';  -- Sinal que indica que o atraso necessário foi atingido
SIGNAL ONEUSCLK:STD_LOGIC;       -- Clock de 1us (derivado do CLK principal)
SIGNAL STCUR:MSTATE:= STPOWERON_DELAY; -- Estado atual da máquina de estados do LCD
SIGNAL JATUAL:JESTADOS:= JESPERA; -- Estado atual do jogo (não totalmente usado)
SIGNAL JNEXT:JESTADOS;           -- Próximo estado do jogo
SIGNAL STNEXT:MSTATE;            -- Próximo estado da máquina de estados do LCD
SIGNAL MATUAL: MLEITOR:= MINICIAL; -- Estado atual da máquina de estados de leitura do teclado
SIGNAL STCURW:WSTATE:= STIDLE;   -- Estado atual da máquina de estados de escrita (Enable)
SIGNAL STNEXTW:WSTATE;           -- Próximo estado da máquina de estados de escrita (Enable)
SIGNAL WRITEDONE:STD_LOGIC:= '0'; -- Indica se todos os comandos iniciais do LCD foram escritos
SIGNAL LIBERABUF : STD_LOGIC := '0'; -- Sinal para liberar o buffer do teclado (RD_KEY_CODE)
SIGNAL KEYREAD : STD_LOGIC_VECTOR (7 DOWNTO 0):= "00000000"; -- Código da tecla lida e processada
SIGNAL KEYBUFFER : STD_LOGIC_VECTOR (7 DOWNTO 0); -- Código da tecla vindo do componente KB_CODE
SIGNAL BUFEMPTY : STD_LOGIC ; -- Indica se o buffer do teclado está vazio (0 = não vazio)
SIGNAL ERROCOUNT: UNSIGNED (3 DOWNTO 0):= "0000"; -- Contador de erros no jogo da forca
SIGNAL TECLOU : STD_LOGIC := '0'; -- Sinal que indica que uma tecla foi pressionada
SIGNAL LEU : STD_LOGIC := '0'; -- Sinal que indica que a tecla foi lida e processada
SIGNAL PERDEU : STD_LOGIC_VECTOR (7 DOWNTO 0):= "11111111"; -- Sinal não utilizado diretamente, mas pode ser para futuras expansões

-- Array para armazenar os caracteres a serem exibidos no LCD para a palavra "SISTEMA"
-- Cada elemento é um STD_LOGIC_VECTOR(9 DOWNTO 0), onde os dois bits mais significativos
-- indicam o tipo (00 para comando, 10 para dado) e os 8 bits restantes são o dado/comando.
TYPE SHOW_T IS ARRAY(INTEGER RANGE 0 TO 6) OF STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL SHOW : SHOW_T := (
-- Inicializando com pontos (ASCII X"2E") para ocultar a palavra "SISTEMA"
0 => "10"&X"2E", -- Posição 0 (S)
1 => "10"&X"2E", -- Posição 1 (I)
2 => "10"&X"2E", -- Posição 2 (S)
3 => "10"&X"2E", -- Posição 3 (T)
4 => "10"&X"2E", -- Posição 4 (E)
5 => "10"&X"2E", -- Posição 5 (M)
6 => "10"&X"2E"  -- Posição 6 (A)
);

-- Array para armazenar a sequência de comandos e dados a serem enviados ao LCD
TYPE LCD_CMDS_T IS ARRAY(INTEGER RANGE 0 TO 13) OF STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL LCD_CMDS : LCD_CMDS_T := (
0 => "00"&X"3C",            -- Comando: Function Set (8 bits, 2 linhas, fonte 5x8)
1 => "00"&X"0C",            -- Comando: Display On, Cursor Off, Blink Off
2 => "00"&X"01",            -- Comando: Clear Display
3 => "00"&X"02",            -- Comando: Return Home (cursor para 0x00)

-- Mapeamento dos caracteres da palavra "SISTEMA" para o array de comandos/dados do LCD
-- Estes serão atualizados dinamicamente pelo processo do jogo da forca
4 => "10"&X"53",            -- S (placeholder, será atualizado por SHOW(0))
5 => "10"&X"49",            -- I (placeholder, será atualizado por SHOW(1))
6 => "10"&X"53",            -- S (placeholder, será atualizado por SHOW(2))
7 => "10"&X"54",            -- T (placeholder, será atualizado por SHOW(3))
8 => "10"&X"45",            -- E (placeholder, será atualizado por SHOW(4))
9 => "10"&X"4D",            -- M (placeholder, será atualizado por SHOW(5))
10 => "10"&X"41",           -- A (placeholder, será atualizado por SHOW(6))

11 => "1000100000",         -- Um caractere ou comando fixo (ex: espaço ou outro símbolo)
12 => "10"&"0011"&(STD_LOGIC_VECTOR(ERROCOUNT)), -- Exibe o contador de erros (ASCII '0' + ERROCOUNT)
13 => "00"&X"02");          -- Comando: Return Home (para reposicionar o cursor)

SIGNAL LCD_CMD_PTR : INTEGER RANGE 0 TO LCD_CMDS'HIGH + 1 := 0; -- Ponteiro para o comando/dado atual no array LCD_CMDS
BEGIN
-- Mapeamento dos bits do KEYREAD para os LEDs de depuração
LEDS(0) <= KEYREAD(0);
LEDS(1) <= KEYREAD(1);
LEDS(2) <= KEYREAD(2);
LEDS(3) <= KEYREAD(3);
LEDS(4) <= KEYREAD(4);
LEDS(5) <= KEYREAD(5);
LEDS(6) <= KEYREAD(6);
LEDS(7) <= KEYREAD(7);

-- Re-atribuição dos comandos iniciais do LCD (redundante, mas garante os valores)
LCD_CMDS(0) <= "00"&X"3C"; -- Function Set
LCD_CMDS(1) <= "00"&X"0C"; -- Display On
LCD_CMDS(2) <= "00"&X"01"; -- Clear Display
LCD_CMDS(3) <= "00"&X"02"; -- Return Home

-- Mapeamento dinâmico dos elementos de SHOW para os comandos de exibição no LCD_CMDS
-- Isso permite que a palavra oculta seja revelada no LCD
LCD_CMDS(4) <= SHOW(0); -- Caractere na posição 0 da palavra
LCD_CMDS(5) <= SHOW(1); -- Caractere na posição 1 da palavra
LCD_CMDS(6) <= SHOW(2); -- Caractere na posição 2 da palavra
LCD_CMDS(7) <= SHOW(3); -- Caractere na posição 3 da palavra
LCD_CMDS(8) <= SHOW(4); -- Caractere na posição 4 da palavra
LCD_CMDS(9) <= SHOW(5); -- Caractere na posição 5 da palavra
LCD_CMDS(10) <= SHOW(6); -- Caractere na posição 6 da palavra

LCD_CMDS(11) <= "1000100000"; -- Caractere/comando fixo
LCD_CMDS(12) <= "10"&"0011"&(STD_LOGIC_VECTOR(ERROCOUNT)); -- Exibe o contador de erros
LCD_CMDS(13) <= "00"&X"02"; -- Return Home

-- Instanciação do componente do teclado PS/2
KBC: KB_CODE PORT MAP (CLK, RST, PS2D, PS2C, LIBERABUF, KEYBUFFER, BUFEMPTY);

-- Processo para gerar um clock de 1us a partir do clock principal
PROCESS (CLK, ONEUSCLK)
BEGIN
    IF (CLK = '1' AND CLK'EVENT) THEN -- Borda de subida do CLK principal
        CLKCOUNT <= CLKCOUNT + 1; -- Incrementa o contador
    END IF;
END PROCESS;

-- Atribuição do sinal ONEUSCLK (bit 5 do CLKCOUNT, para um clock mais lento)
ONEUSCLK <= CLKCOUNT(5);

-- Processo para controlar o contador de atraso (COUNT)
PROCESS (ONEUSCLK, DELAYOK)
BEGIN
    IF (ONEUSCLK = '1' AND ONEUSCLK'EVENT) THEN -- Borda de subida do clock de 1us
        IF DELAYOK = '1' THEN -- Se o atraso foi atingido, reseta o contador
            COUNT <= "00000000000000000";
        ELSE
            COUNT <= COUNT + 1; -- Caso contrário, incrementa
        END IF;
    END IF;
END PROCESS;

-- Sinal que indica se todos os comandos iniciais do LCD foram escritos
WRITEDONE <= '1' WHEN (LCD_CMD_PTR = LCD_CMDS'HIGH) 
ELSE '0';

-- Processo para controlar o ponteiro de comandos do LCD (LCD_CMD_PTR)
PROCESS (LCD_CMD_PTR, ONEUSCLK)
BEGIN
    IF (ONEUSCLK = '1' AND ONEUSCLK'EVENT) THEN -- Borda de subida do clock de 1us
        -- Avança o ponteiro se o estado atual é de inicialização ou escrita de comando/caractere
        IF ((STNEXT = STINITDNE OR STNEXT = STDISPLAYCTRLSET OR STNEXT = STDISPLAYCLEAR) AND WRITEDONE = '0') THEN 
            LCD_CMD_PTR <= LCD_CMD_PTR + 1;
        -- Reseta o ponteiro se estiver no atraso de power-on
        ELSIF STCUR = STPOWERON_DELAY OR STNEXT = STPOWERON_DELAY THEN
            LCD_CMD_PTR <= 0;
        -- Se uma tecla foi pressionada, retorna o ponteiro para o comando "Return Home"
        -- Isso força a reexibição da palavra atualizada
        ELSIF TECLOU = '1' THEN
            LCD_CMD_PTR <= 3; -- Comando "Return Home" (posição 3 no LCD_CMDS)
        ELSE
            LCD_CMD_PTR <= LCD_CMD_PTR; -- Mantém o ponteiro no mesmo lugar
        END IF;
    END IF;
END PROCESS;

-- Lógica para determinar se o atraso necessário foi atingido para cada estado
DELAYOK <= '1' WHEN ((STCUR = STPOWERON_DELAY AND COUNT = "00100111001010010") OR   -- Atraso de 20ms
                     (STCUR = STFUNCTIONSET_DELAY AND COUNT = "00000000000110010") OR -- Atraso de 40us
                     (STCUR = STDISPLAYCTRLSET_DELAY AND COUNT = "00000000000110010") OR -- Atraso de 40us
                     (STCUR = STDISPLAYCLEAR_DELAY AND COUNT = "00000011001000000") OR -- Atraso de 1.64ms
                     (STCUR = STCHARDELAY AND COUNT = "11111111111111111")) -- Atraso para escrita de caractere (longo o suficiente)
               ELSE '0';

-- Processo da Máquina de Estados de Controle do LCD
PROCESS (ONEUSCLK, RST)
BEGIN
    IF ONEUSCLK = '1' AND ONEUSCLK'EVENT THEN -- Borda de subida do clock de 1us
        IF RST = '1' THEN -- Reset assíncrono
            STCUR <= STPOWERON_DELAY; -- Inicia no estado de atraso de power-on
        ELSE
            STCUR <= STNEXT; -- Transiciona para o próximo estado
        END IF;
    END IF;
END PROCESS;

-- Processo para gerar a sequência necessária para escrever no LCD (saídas RS, RW, LCD_DB)
PROCESS (STCUR, DELAYOK, WRITEDONE, LCD_CMD_PTR)
BEGIN   
    -- Valores padrão para as saídas (importante para evitar latches)
    RS <= LCD_CMDS(LCD_CMD_PTR)(9);
    RW <= LCD_CMDS(LCD_CMD_PTR)(8);
    LCD_DB <= LCD_CMDS(LCD_CMD_PTR)(7 DOWNTO 0);
    ACTIVATEW <= '0'; -- Por padrão, não ativa a escrita

    CASE STCUR IS
        -- Atrasa a máquina de estados em 20ms (tempo para o LCD inicializar)
        WHEN STPOWERON_DELAY =>
            IF DELAYOK = '1' THEN -- Se o atraso terminou
                STNEXT <= STFUNCTIONSET; -- Vai para o Function Set
            ELSE
                STNEXT <= STPOWERON_DELAY; -- Continua atrasando
            END IF;
            -- Saídas já definidas antes do CASE

        WHEN STFUNCTIONSET =>
            ACTIVATEW <= '1';   -- Ativa a escrita para enviar o comando
            STNEXT <= STFUNCTIONSET_DELAY; -- Vai para o estado de atraso
            -- Saídas já definidas antes do CASE

        --- DELAY após Function Set
        WHEN STFUNCTIONSET_DELAY =>
            IF DELAYOK = '1' THEN -- Se o atraso terminou
                STNEXT <= STDISPLAYCTRLSET; -- Vai para o Display Control Set
            ELSE
                STNEXT <= STFUNCTIONSET_DELAY; -- Continua atrasando
            END IF;
            -- Saídas já definidas antes do CASE

        -- Envia o comando Display Control Set (Display ON, Cursor OFF, Blink OFF)
        WHEN STDISPLAYCTRLSET =>
            ACTIVATEW <= '1';
            STNEXT <= STDISPLAYCTRLSET_DELAY;
            -- Saídas já definidas antes do CASE

        WHEN STDISPLAYCTRLSET_DELAY =>
            IF DELAYOK = '1' THEN
                STNEXT <= STDISPLAYCLEAR;
            ELSE
                STNEXT <= STDISPLAYCTRLSET_DELAY;
            END IF;
            -- Saídas já definidas antes do CASE

        WHEN STDISPLAYCLEAR =>
            ACTIVATEW <= '1';
            STNEXT <= STDISPLAYCLEAR_DELAY;
            -- Saídas já definidas antes do CASE

        WHEN STDISPLAYCLEAR_DELAY =>
            IF DELAYOK = '1' THEN
                STNEXT <= STINITDNE; -- Inicialização concluída
            ELSE
                STNEXT <= STDISPLAYCLEAR_DELAY;
            END IF;
            -- Saídas já definidas antes do CASE

        WHEN STINITDNE =>       
            -- Estado onde o LCD está pronto e espera por comandos/dados
            STNEXT <= STACTWR; -- Transiciona para ativar a escrita
            -- Saídas já definidas antes do CASE

        WHEN STACTWR =>     
            -- Ativa a escrita de um caractere ou comando
            ACTIVATEW <= '1';
            STNEXT <= STCHARDELAY; -- Vai para o atraso de caractere
            -- Saídas já definidas antes do CASE

        WHEN STCHARDELAY =>
            -- Atraso após a escrita de um caractere/comando
            IF DELAYOK = '1' THEN
                STNEXT <= STINITDNE; -- Retorna para o estado pronto
            ELSE
                STNEXT <= STCHARDELAY; -- Continua atrasando
            END IF;
            -- Saídas já definidas antes do CASE
    END CASE;

END PROCESS;                    

-- Processo da Máquina de Estados de Controle de Escrita (pulso de Enable)
PROCESS (ONEUSCLK, RST)
BEGIN
    IF ONEUSCLK = '1' AND ONEUSCLK'EVENT THEN -- Borda de subida do clock de 1us
        IF RST = '1' THEN
            STCURW <= STIDLE; -- Reseta para o estado ocioso
        ELSE
            STCURW <= STNEXTW; -- Transiciona para o próximo estado
        END IF;
    END IF;
END PROCESS;

PROCESS (STCURW, ACTIVATEW)
BEGIN   
    OE <= '1'; -- Por padrão, Enable desativado (nível alto)

    CASE STCURW IS
        WHEN STRW =>
            OE <= '0'; -- Ativa Enable (nível baixo)
            STNEXTW <= STENABLE; -- Vai para o estado de pulso
        WHEN STENABLE => 
            OE <= '0'; -- Mantém Enable ativo
            STNEXTW <= STIDLE; -- Vai para o estado ocioso após o pulso
        WHEN STIDLE =>
            OE <= '1'; -- Desativa Enable
            IF ACTIVATEW = '1' THEN -- Se a escrita foi ativada
                STNEXTW <= STRW; -- Inicia a sequência de escrita
            ELSE
                STNEXTW <= STIDLE; -- Permanece ocioso
            END IF;
    END CASE;
END PROCESS;


--- LÓGICA DO JOGO DA FORCA
PROCESS(RST,ONEUSCLK,TECLOU,KEYREAD)
BEGIN
    IF RST = '1' THEN
        -- No reset, inicializa a palavra com pontos (oculta)
        SHOW(0) <= "10"&X"2E";
        SHOW(1) <= "10"&X"2E";
        SHOW(2) <= "10"&X"2E";
        SHOW(3) <= "10"&X"2E";
        SHOW(4) <= "10"&X"2E";
        SHOW(5) <= "10"&X"2E";
        SHOW(6) <= "10"&X"2E";
        ERROCOUNT <= "0000"; -- Reseta o contador de erros

    ELSIF ONEUSCLK = '1' AND ONEUSCLK'EVENT THEN -- Borda de subida do clock de 1us
        -- Verifica se o número de erros atingiu o limite (7 erros para "PERDEU")
        IF ERROCOUNT >= 7 THEN
            -- Se perdeu, exibe a palavra "PERDEU!" no LCD
            SHOW(0) <= "10"&X"50"; -- P
            SHOW(1) <= "10"&X"45"; -- E
            SHOW(2) <= "10"&X"52"; -- R
            SHOW(3) <= "10"&X"44"; -- D
            SHOW(4) <= "10"&X"45"; -- E
            SHOW(5) <= "10"&X"55"; -- U
            SHOW(6) <= "10"&X"21"; -- ! (Exclamação)

        ELSIF TECLOU = '1' THEN -- Se uma tecla foi pressionada
        --- A palavra secreta é "SISTEMA"
            CASE KEYREAD IS
                WHEN "00011011" =>                  --- Código de varredura PS/2 para 'S'
                    SHOW(0) <= "10"&X"53";          --- Revela 'S' na posição 0
                    SHOW(2) <= "10"&X"53";          --- Revela 'S' na posição 2
                    -- Mantém os outros caracteres como estão
                    SHOW(1) <= SHOW(1);
                    SHOW(3 TO 6) <= SHOW(3 TO 6);
                WHEN "00100011" =>                  --- Código de varredura PS/2 para 'I'
                    SHOW(1) <= "10"&X"49";          --- Revela 'I' na posição 1
                    -- Mantém os outros caracteres como estão
                    SHOW(0) <= SHOW(0);
                    SHOW(2 TO 6) <= SHOW(2 TO 6);
                WHEN "00101100" =>                  --- Código de varredura PS/2 para 'T'
                    SHOW(3) <= "10"&X"54";          --- Revela 'T' na posição 3
                    -- Mantém os outros caracteres como estão
                    SHOW(0 TO 2) <= SHOW(0 TO 2);
                    SHOW(4 TO 6) <= SHOW(4 TO 6);
                WHEN "00100100" =>                  --- Código de varredura PS/2 para 'E'
                    SHOW(4) <= "10"&X"45";          --- Revela 'E' na posição 4
                    -- Mantém os outros caracteres como estão
                    SHOW(0 TO 3) <= SHOW(0 TO 3);
                    SHOW(5 TO 6) <= SHOW(5 TO 6);
                WHEN "00110010" =>                  --- Código de varredura PS/2 para 'M'
                    SHOW(5) <= "10"&X"4D";          --- Revela 'M' na posição 5
                    -- Mantém os outros caracteres como estão
                    SHOW(0 TO 4) <= SHOW(0 TO 4);
                    SHOW(6) <= SHOW(6);
                WHEN "00011100" =>                  --- Código de varredura PS/2 para 'A'
                    SHOW(6) <= "10"&X"41";          --- Revela 'A' na posição 6
                    -- Mantém os outros caracteres como estão
                    SHOW(0 TO 5) <= SHOW(0 TO 5);
                WHEN OTHERS => -- Se a tecla não corresponde a nenhuma letra da palavra
                    ERROCOUNT <= ERROCOUNT + 1; -- Incrementa o contador de erros
                    SHOW(0 TO 6)<= SHOW(0 TO 6); -- Mantém a exibição atual
            END CASE;
            LEU <= '1'; -- Sinaliza que a tecla foi lida e processada
    ELSE
        SHOW<=SHOW; -- Mantém a exibição atual se não houver tecla
        END IF;
    END IF;
END PROCESS;

----------------------------------------------------            
-- Máquina de Estados para Leitura do Teclado
PROCESS(ONEUSCLK)
BEGIN
    IF ONEUSCLK = '1' AND ONEUSCLK'EVENT THEN -- Borda de subida do clock de 1us
        CASE MATUAL IS
            WHEN MINICIAL=> -- Estado inicial: espera por uma tecla
                IF BUFEMPTY = '0' THEN -- Se o buffer do teclado não está vazio (tem tecla)
                    MATUAL <= MMEIO; -- Vai para o estado de processamento da tecla
                END IF;

            WHEN MMEIO => -- Estado intermediário: tecla lida
                IF LEU <= '1' THEN -- Se a tecla foi processada pela lógica do jogo
                    MATUAL <= MFINAL; -- Vai para o estado final
                END IF;

            WHEN MFINAL => -- Estado final: reinicia para esperar a próxima tecla
                MATUAL <= MINICIAL;
        END CASE;
    END IF;
END PROCESS;
    ----------------------------------------------------    
-- Lógica de controle para a Máquina de Estados de Leitura do Teclado
PROCESS(ONEUSCLK)
BEGIN
    IF ONEUSCLK = '1' AND ONEUSCLK'EVENT THEN -- Borda de subida do clock de 1us
        CASE MATUAL IS
            WHEN MINICIAL =>
                LIBERABUF <= '0'; -- Não libera o buffer do teclado (ainda esperando)
            WHEN MMEIO =>
                TECLOU <= '1'; -- Sinaliza que uma tecla foi pressionada
                KEYREAD <= KEYBUFFER; -- Copia o código da tecla do buffer para KEYREAD
            WHEN MFINAL =>
                TECLOU <= '0'; -- Reseta o sinal de tecla pressionada
                LEU<= '0'; -- Reseta o sinal de tecla lida
                LIBERABUF <= '1'; -- Libera o buffer do teclado para a próxima tecla
        END CASE;
    END IF;
END PROCESS;


END BEHAVIORAL;
