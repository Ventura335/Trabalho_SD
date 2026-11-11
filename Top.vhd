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

    -- Baud Clock --

    component DivisorClock is
        port ( 
            clk50MHz : in std_logic;
            reset    : in std_logic;
            BC       : out std_logic
        );
    end component;

    -- Registrador de deslocamento --

    component srl_tx is
        port ( 
            clock         : in std_logic;
            reset         : in std_logic;
            load_tx       : in std_logic;
            shift_tx      : in std_logic;
            data_in       : in std_logic_vector(7 downto 0);
            tx_out        : out std_logic;
            carac_load_tx : out std_logic_vector(7 downto 0)
        );
    end component;

    -- FSM do transmissor --

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