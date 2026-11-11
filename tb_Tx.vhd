library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_srl_tx is
end entity tb_srl_tx;

architecture teste of tb_srl_tx is

    signal clock         : std_logic := '0';
    signal reset         : std_logic := '0';
    signal load_tx       : std_logic := '0';
    signal shift_tx      : std_logic := '0';
    signal data_in       : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_out        : std_logic;
    signal carac_load_tx : std_logic_vector(7 downto 0);

    constant CLK_PERIOD  : time := 10 ns;

begin
    DUT : entity work.srl_tx
        port map (
            clock         => clock,
            reset         => reset,
            load_tx       => load_tx,
            shift_tx      => shift_tx,
            data_in       => data_in,
            tx_out        => tx_out,
            carac_load_tx => carac_load_tx
        );
    process
        procedure clk_pulse is
        begin
            clock <= '0';
            wait for CLK_PERIOD / 2;
            clock <= '1';
            wait for CLK_PERIOD / 2;
        end procedure;
    begin
        reset <= '1';
        load_tx <= '0';
        shift_tx <= '0';
        data_in <= "00000000";
        
        clk_pulse;
        clk_pulse;
        
        reset <= '0';
        clk_pulse;

        data_in <= "10110101";
        load_tx <= '1';
        clk_pulse;
        
        load_tx <= '0';
        clk_pulse;

        shift_tx <= '1';
        for i in 1 to 8 loop
            clk_pulse;
        end loop;

        shift_tx <= '0';
        clk_pulse;
        clk_pulse;

        data_in <= "11001100";
        load_tx <= '1';
        clk_pulse;
        
        load_tx <= '0';
        shift_tx <= '1';
        for i in 1 to 8 loop
            clk_pulse;
        end loop;

        shift_tx <= '0';
        clk_pulse;
        clk_pulse;
        
        wait;
    end process;

end architecture teste;