-- Baud Rate --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DivisorClock is
port ( 
    clk50MHz : in std_logic;
    reset    : in std_logic;
    BC       : out std_logic
);
end DivisorClock;

architecture Behavioral of DivisorClock is
begin
    process(clk50MHz, reset)
        variable cnt : integer range 0 to 5208;
    begin
        if (reset = '1') then
            cnt := 0;
            BC  <= '0';
        elsif (rising_edge(clk50MHz)) then
            BC <= '0';
            if (cnt = 5208) then
                cnt := 0;
                BC  <= '1';
            else 
                cnt := cnt + 1;
            end if;
        end if;
    end process;
end Behavioral;

-- SRL Tx --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity srl_tx is
port ( 
    clock         : in std_logic;
    reset         : in std_logic;
    load_tx       : in std_logic;
    shift_tx      : in std_logic;
    data_in       : in std_logic_vector(7 downto 0);
    tx_out        : out std_logic;
    carac_load_tx : out std_logic_vector(9 downto 0)
);
end srl_tx;

architecture comportamental of srl_tx is
    signal shift_register : std_logic_vector(9 downto 0);
begin
    process(clock, reset)
    begin
        if (reset = '1') then
            shift_register <= (others => '0');
        elsif (rising_edge(clock)) then
            if (load_tx = '1') then
                shift_register <= data_in & '0' & '1';
            elsif (shift_tx = '1') then
                shift_register <= shift_register srl 1;
            end if;
        end if;
    end process;
    
    carac_load_tx <= shift_register;
    tx_out        <= shift_register(0);
end comportamental;