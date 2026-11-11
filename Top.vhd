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
    signal bc_top       : std_logic;
    signal shift_tx_top : std_logic;
    signal data_fsm_top : std_logic_vector(7 downto 0);
end architecture;