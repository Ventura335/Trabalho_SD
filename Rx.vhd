-- Divisor de clock com entrada de 50MHz e saída de 1Hz
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Baud Rate --
entity DivisorClock is
port ( clk50MHz : in std_logic;
       reset : in std_logic;
       BC : out std_logic
     );
end DivisorClock;

architecture Behavioral of DivisorClock is

--signal count : integer := 0;
begin

process(clk50MHz)
	variable cnt : integer range 0 to 5207;
	begin
		if(rising_edge(clk50MHz)) then
		   if(reset = '1') then
			   cnt := 0;
               BC <= '0';
			else
                BC <= '0';
                if(cnt = 5208) then
                    cnt := 0;
                    BC <= '1';
                else 
                    cnt := cnt + 1;
                end if;
            end if;
		end if;
	end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DivisorClock16x is
port ( 
    clk50MHz : in std_logic;
    reset    : in std_logic;
    clk_16x  : out std_logic
);
end DivisorClock16x;

architecture Behavioral of DivisorClock16x is
begin
    process(clk50MHz, reset)
        variable cnt : integer range 0 to 324;
    begin
        if (reset = '1') then
            cnt := 0;
            clk_16x <= '0';
        elsif (rising_edge(clk50MHz)) then
            clk_16x <= '0';
            if (cnt = 324) then
                cnt := 0;
                clk_16x <= '1'; 
            else 
                cnt := cnt + 1;
            end if;
        end if;
    end process;
end Behavioral;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample_tick is
port (
    clock         : in std_logic; 
    reset         : in std_logic;
    start_sample  : in std_logic;
    ST          : out std_logic
);
end sample_tick;

architecture behavioral of sample_tick is
    signal div_cnt : integer range 0 to 15 := 0;
begin
    process(clock, reset)
    begin
        if (reset = '1') then
            div_cnt <= 0;
            ST    <= '0';
        elsif (rising_edge(clock)) then
            ST <= '0';

            if (start_sample = '1') then
                if (div_cnt = 15) then
                    div_cnt <= 0;
                else
                    div_cnt <= div_cnt + 1;
                end if;
                if (div_cnt = 7) then
                    ST <= '1';
                end if;
            else
                div_cnt <= 0;
            end if;
        end if;
    end process;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity srl_rx is
port ( 
    clock       : in std_logic;
    reset       : in std_logic;
    rx_in       : in std_logic;
    shift_rx    : in std_logic;
    rx_ready    : in std_logic; 
    data_out_rx : out std_logic_vector(7 downto 0)
);
end srl_rx;

architecture comportamental of srl_rx is
    signal shift_register : std_logic_vector(7 downto 0);
begin
    process(clock, reset)
    begin
        if (reset = '1') then
            shift_register <= (others => '0');
        elsif (rising_edge(clock)) then
            if (shift_rx = '1') then
                shift_register <= rx_in & shift_register(7 downto 1);
            end if;
        end if;
        if (rx_ready = '1') then
        data_out_rx <= shift_register;
    end if;
    end process;
    
end comportamental;