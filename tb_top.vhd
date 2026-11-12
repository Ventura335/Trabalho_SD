library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart_completa is
end entity tb_uart_completa;

architecture teste of tb_uart_completa is
    signal clk50MHz    : std_logic := '0';
    signal reset       : std_logic := '0';
    signal load        : std_logic := '0';
    signal tx_start    : std_logic := '0';
    signal sel_in_tx   : std_logic := '0';
    signal data_in     : std_logic_vector(7 downto 0) := (others => '0');
    
    signal tx_out_sig  : std_logic;
    signal tx_busy_sig : std_logic;
    
    signal rx_out_sig  : std_logic_vector(7 downto 0);
    signal rx_ready_sig: std_logic;

    constant CLK_PERIOD : time := 20 ns;
    signal sim_finished : boolean := false;

begin

    process
    begin
        while not sim_finished loop
            clk50MHz <= '0';
            wait for CLK_PERIOD / 2;
            clk50MHz <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Instância do Transmissor
    DUT_TX : entity work.uart_tx_top
        port map (
            clk50MHz  => clk50MHz,
            reset     => reset,
            load      => load,
            tx_start  => tx_start,
            sel_in_tx => sel_in_tx,
            data_in   => data_in,
            tx_out    => tx_out_sig,
            tx_busy   => tx_busy_sig
        );

    -- Instância do Receptor (Conectando a saída do TX na entrada do RX)
    DUT_RX : entity work.uart_rx_top
        port map (
            clk50MHz => clk50MHz,
            reset    => reset,
            data_in  => tx_out_sig,
            rx_out   => rx_out_sig,
            rx_ready => rx_ready_sig
        );

    -- Processo de estímulos
    process
    begin
        reset <= '1';
        load <= '0';
        tx_start <= '0';
        sel_in_tx <= '0';
        data_in <= "00000000";
        
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- Configura e carrega o dado no transmissor
        data_in <= "10110101";
        load <= '1';
        wait for CLK_PERIOD * 2;
        
        load <= '0';
        wait for CLK_PERIOD * 2;

        -- Inicia a transmissão
        tx_start <= '1';
        wait for CLK_PERIOD * 2;
        tx_start <= '0';

        -- Aguarda o tempo necessário para a transmissão e recepção completa do byte
        wait for 3 ms;

        -- Envia um segundo byte para testar novamente
        data_in <= "11001100";
        load <= '1';
        wait for CLK_PERIOD * 2;
        
        load <= '0';
        wait for CLK_PERIOD * 2;

        tx_start <= '1';
        wait for CLK_PERIOD * 2;
        tx_start <= '0';

        wait for 3 ms;

        sim_finished <= true;
        wait;
    end process;

end architecture teste;