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
  type state_type is (Inicio, shift_rx, recebe_data, data_out);

  signal ps, ns : state_type;
  signal i : integer;
  signal start_detect : std_logic_vector(1 downto 0);
  signal start_bit : std_logic;
begin

sync_proc : process (BC)
begin
  start_detect <= start_detect(0) & data_in;
  start_bit <= '1' when (start_detect = "10") else '0';
  
  if (rising_edge(BC)) then
    if (reset = '1') then  
      PS <= Inicio;
    else
      PS <= NS;
    end if;
  end if;
end process sync_proc;


comb_proc : process (PS)
    begin
    case PS is
      when Inicio =>
        if (Reset = '1') then
          Ns <= Inicio;
        elsif (start_bit = '1') then
          Ns <= shift_rx;
        else 
          Ns <= Inicio;
        end if;
        
      when shift_rx =>
        ns <= recebe_data;
        i <= 0;
        rx_ready <= '0';
        start_sample <= '1';

      when recebe_data =>
        if (i < 8) then 
            ns <= recebe_data;
            i <= i + 1;
        else 
            ns <= data_out;
            i <= 0;
            start_sample <= '0';
        end if;
      when data_out =>
        NS <= Inicio;
        rx_ready <= '1';
        

  end case;
end process comb_proc;
end fsm;