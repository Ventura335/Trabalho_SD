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

    -- Gerador de Clock Principal (50 MHz)
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

    -- Instância do Receptor (Loopback: tx_out ligado no rx)
    DUT_RX : entity work.uart_rx_top
        port map (
            clk50MHz => clk50MHz,
            reset    => reset,
            data_in  => tx_out_sig,
            rx_out   => rx_out_sig,
            rx_ready => rx_ready_sig
        );

    -- Processo de Estímulos com tempos estendidos para o BC
    process
    begin
        -- Estado inicial de Reset
        reset <= '1';
        load <= '0';
        tx_start <= '0';
        sel_in_tx <= '0';
        data_in <= (others => '0');
        
        wait for 200 ns;
        reset <= '0'; -- Libera o reset
        wait for 500 ns;

        -- 1º Envio de Dado ("10110101")
        data_in <= "10110101";
        load <= '1';          
        wait for 2 ms;        -- Tempo longo para o BC lento detetar o load
        load <= '0';          
        wait for 2 ms;

        tx_start <= '1';      
        wait for 2 ms;        -- Tempo longo para o BC lento detetar o start
        tx_start <= '0';

        -- Aguarda a transmissão completa do byte
        wait for 4 ms;

        -- 2º Envio de Dado ("11001100")
        data_in <= "11001100";
        load <= '1';
        wait for 2 ms;
        load <= '0';
        wait for 2 ms;

        tx_start <= '1';
        wait for 2 ms;
        tx_start <= '0';

        wait for 4 ms;

        sim_finished <= true;
        wait;
    end process;

end architecture teste;