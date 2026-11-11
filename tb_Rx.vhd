library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_srl_rx is
end entity tb_srl_rx;

architecture teste of tb_srl_rx is
    signal clk_16x       : std_logic := '0';
    signal reset         : std_logic := '0';
    signal start_sample  : std_logic := '0';
    signal ST            : std_logic;
    signal rx_in         : std_logic := '0';
    signal data_out_rx   : std_logic_vector(7 downto 0);
    constant CLK_16X_PERIOD : time := 20 ns;

    signal sim_finished : boolean := false;

begin
    process
    begin
        while not sim_finished loop
            clk_16x <= '0';
            wait for CLK_16X_PERIOD / 2;
            clk_16x <= '1';
            wait for CLK_16X_PERIOD / 2;
        end loop;
        wait;
    end process;

    DUT_TICK : entity work.sample_tick
        port map (
            clock        => clk_16x,
            reset        => reset,
            start_sample => start_sample,
            ST           => ST
        );

    DUT_RX : entity work.srl_rx
        port map (
            clock       => clk_16x,
            reset       => reset,
            rx_in       => rx_in,
            shift_rx    => ST,
            data_out_rx => data_out_rx
        );

    process
    begin
        reset        <= '1';
        start_sample <= '0';
        rx_in        <= '0';
        
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        start_sample <= '1';

        for i in 1 to 8 loop
            wait until rising_edge(ST) for 50 us;
            
            if ST = '1' or rising_edge(ST) then
                case i is
                    when 1 => rx_in <= '1';
                    when 2 => rx_in <= '0';
                    when 3 => rx_in <= '1';
                    when 4 => rx_in <= '0';
                    when 5 => rx_in <= '0';
                    when 6 => rx_in <= '0';
                    when 7 => rx_in <= '0';
                    when 8 => 
                        rx_in <= '1';
                        
                    when others => rx_in <= '0';
                end case;
            end if;
        end loop;

            start_sample <= '0';
        wait for 500 ns;

        rx_in <= '0';
        
        wait for 200 ns;
        sim_finished <= true;
        
        wait;
    end process;

end architecture teste;