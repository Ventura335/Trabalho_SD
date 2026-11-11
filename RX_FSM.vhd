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
begin

  sync_proc : process (BC) -- note: no NS here!
  begin -- state reset and transition
    if (rising_edge(BC)) then
      PS <= NS;
    end if;
  end process sync_proc;

  comb_proc : process (PS)
    variable i : integer;
    begin
    case PS is
      when Inicio =>
        if (Reset = '1') then
          Ns <= Inicio;
        else
          Ns <= shift_rx;
        end if;

      when shift_rx =>
        ns <= recebe_data;
        I := 0;
        rx_ready <= '0';
        start_sample <= '1';

      when recebe_data =>
        if (i < 8) then 
            ns <= recebe_data;
            i := i + 1;
        else 
            ns <= data_out;
            i := 0;
            start_sample <= '0';
        end if;
      when data_out =>
        NS <= Inicio;
        rx_ready <= '1';
        

  end case;
end process comb_proc;
end fsm;