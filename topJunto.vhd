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
        variable cnt : integer range 0 to 5208 := 0;
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

-- Divisor de clock com entrada de 50MHz e saída de 1Hz
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_fsm is
  port (
    BC, reset, load, tx_start, sel_in_tx : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    tx_busy, shift_tx  : out std_logic;
    data_out : out std_logic_vector(7 downto 0)
  );
end tx_fsm;

architecture fsm of tx_fsm is
  type state_type is (Inicio, Load_tx_chave, Tx_start_bit, Tx_bit, Stop);
  signal ps, ns : state_type;
  signal cont : integer;
begin
  sync_proc : process (BC, reset)
  begin 
    if (reset = '1') then
      ps <= Inicio;
      cont <= 0;
    elsif (rising_edge(BC)) then
      ps <= ns;
      if ps = Tx_bit then
        if cont = 7 then
          cont <= 0;
        else
          cont <= cont + 1;
        end if;
      else
        cont <= 0;
      end if;
    end if;
  end process sync_proc;

  -- Processo Combinacional sem Latches
  comb_proc : process (ps, load, tx_start, sel_in_tx, cont, data_in)
  begin
    ns <= ps;
    tx_busy <= '0';
    shift_tx <= '0';
    data_out <= (others => '0');

    case ps is
      when Inicio =>
        if (load = '1') then
          ns <= Load_tx_chave;
        end if;

      when Load_tx_chave =>
        tx_busy <= '0';
        if (tx_start = '1') then 
          ns <= Tx_start_bit;
        else
          ns <= Load_tx_chave;
        end if;
        
      when Tx_start_bit =>
        tx_busy <= '1';
        shift_tx <= '1';
        ns <= Tx_bit;

      when Tx_bit =>
        tx_busy <= '1';
        shift_tx <= '1';
        if (cont = 7) then
          ns <= Stop;
        end if;

      when Stop =>
        tx_busy <= '1';
        shift_tx <= '0';
        ns <= Inicio;

      when others =>
        ns <= Inicio;
    end case;
  end process comb_proc;
end fsm;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rx_fsm is
  port (
    BC, reset, data_in : in std_logic;
    rx_ready, start_sample : OUT std_logic
    );
end rx_fsm;

architecture fsm of rx_fsm is

--------------------------------------------------------------
-------------------------------------------------------------------
  type state_type is (Inicio, shift_rx, recebe_data, data_out, Espera);

  signal ps, ns : state_type;
  signal i : integer := 0;
  signal start_detect : std_logic_vector(1 downto 0) := "11";
  signal start_bit : std_logic := '0';
begin

sync_proc : process (BC)
begin
  if (rising_edge(BC)) then
    if (reset = '1') then
      start_detect <= "11";
      start_bit <= '0';
      PS <= Inicio;
    else
      start_detect <= start_detect(0) & data_in;
      PS <= NS;
      if (NS = recebe_data) then
        i <= i + 1;
      elsif (PS = Inicio) then
        i <= 0;
      end if;
      if (start_detect = "10") then
        start_bit <= '1';
        
      elsif (PS /= Inicio) then
        start_bit <= '0';
      end if;
    end if;
  end if;
end process sync_proc;



comb_proc : process (start_bit, PS, BC)
    begin
    case PS is
      when Inicio =>
        start_sample <= '1';
        if (Reset = '1') then
          Ns <= Inicio;
        elsif (start_bit = '1') then
          Ns <= shift_rx;
        else 
          Ns <= Inicio;
        end if;
        
      when shift_rx =>
        ns <= recebe_data;
      when recebe_data =>
        if (i < 6) then 
            ns <= recebe_data;
        else 
            ns <= data_out;
            start_sample <= '0';
        end if;
      when data_out =>
        NS <= Espera;
        rx_ready <= '1';
      when Espera =>  
        NS <= Inicio;
        rx_ready <= '0';
  end case;
end process comb_proc;
end fsm;

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

    Srlrx : srl_rx
        port map ( 
            clock       => clk_16x,       
            reset       => reset,
            rx_in       => data_in,
            shift_rx    => shift_rx_top,  
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