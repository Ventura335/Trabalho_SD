library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_top is
  port (
    clk50MHz   : in std_logic;
    reset      : in std_logic;
    load       : in std_logic;
    tx_start   : in std_logic;
    sel_in_tx  : in std_logic;
    data_in    : in std_logic_vector(7 downto 0);
    tx_out     : out std_logic;
    tx_busy    : out std_logic
  );
end uart_tx_top;

architecture structural of uart_tx_top is
    signal bc_top         : std_logic;
    signal shift_tx_top   : std_logic;
    signal data_fsm_top   : std_logic_vector(7 downto 0);

    component DivisorClock is
        port ( 
            clk50MHz : in std_logic;
            reset    : in std_logic;
            BC       : out std_logic
        );
    end component;

    component srl_tx is
        port ( 
            clock         : in std_logic;
            reset         : in std_logic;
            load_tx       : in std_logic;
            shift_tx      : in std_logic;
            data_in       : in std_logic_vector(7 downto 0);
            tx_out        : out std_logic;
            carac_load_tx : out std_logic_vector(9 downto 0)
        );
    end component;

    component tx_fsm is
        port (
            BC, reset, load, tx_start, sel_in_tx : in std_logic;
            data_in : in std_logic_vector(7 downto 0);
            tx_busy, shift_tx  : out std_logic;
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

begin 

    Baud : DivisorClock
        port map ( 
            clk50MHz => clk50MHz,
            reset    => reset,
            BC       => bc_top
        );

    SrlTx : srl_tx
        port map ( 
            clock         => bc_top,
            reset         => reset,
            load_tx       => load,
            shift_tx      => shift_tx_top,
            data_in       => data_in,
            tx_out        => tx_out,
            carac_load_tx => open
        );

    FSM_Tx : tx_fsm
        port map (
            BC        => bc_top,
            reset     => reset,
            load      => load,
            tx_start  => tx_start,
            sel_in_tx => sel_in_tx,
            data_in   => data_in,
            tx_busy   => tx_busy,
            shift_tx  => shift_tx_top,
            data_out  => data_fsm_top
        );  
    
end structural;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_top is
  port (
    clk50MHz   : in std_logic;
    reset      : in std_logic;
    data_in    : in std_logic;
    rx_out     : out std_logic_vector(7 downto 0);
    rx_ready   : out std_logic
  );
end uart_rx_top;

architecture structural of uart_rx_top is
    signal bc_top         : std_logic;
    signal shift_rx_top   : std_logic;
    signal clk_16x        : std_logic;
    signal start_sample   : std_logic;

    component DivisorClock is
        port ( 
            clk50MHz : in std_logic;
            reset    : in std_logic;
            BC       : out std_logic
        );
    end component;

    component DivisorClock16x is
    port ( 
        clk50MHz : in std_logic;
        reset    : in std_logic;
        clk_16x  : out std_logic
    );
    end component;

    component sample_tick is
    port (
        clock         : in std_logic; 
        reset         : in std_logic;
        start_sample  : in std_logic;
        ST          : out std_logic
    );
    end component;

    component srl_rx is
    port ( 
        clock       : in std_logic;
        reset       : in std_logic;
        rx_in       : in std_logic;
        shift_rx    : in std_logic;
        rx_ready    : in std_logic;
        data_out_rx : out std_logic_vector(7 downto 0)
    );
    end component;

    component rx_fsm is
    port (
        BC, reset, data_in : in std_logic;
        rx_ready, start_sample : out std_logic
    );
    end component;

begin 

    Baud : DivisorClock
        port map ( 
            clk50MHz => clk50MHz,
            reset    => reset,
            BC       => bc_top
        );

    Div16x : DivisorClock16x
        port map ( 
            clk50MHz => clk50MHz,
            reset    => reset,
            clk_16x  => clk_16x
        );
    
    Sample : sample_tick
        port map ( 
            clock         => clk_16x,
            reset         => reset,
            start_sample  => start_sample,
            ST          => shift_rx_top
        );

    -- CORREÇÃO: O registrador do receptor deve ser deslocado pelo pulso de amostragem (shift_rx_top)
    Srlrx : srl_rx
        port map ( 
            clock       => clk_16x,       -- Usa o clock de alta frequência 16x ou o tick estrutural
            reset       => reset,
            rx_in       => data_in,
            shift_rx    => shift_rx_top,  -- Pulso de habilitação/deslocamento
            rx_ready    => rx_ready,
            data_out_rx => rx_out
        );

    fsm_rx : rx_fsm
        port map (
            BC          => bc_top,
            reset       => reset,
            data_in     => data_in,
            rx_ready    => rx_ready,
            start_sample => start_sample
        );
    
end structural;