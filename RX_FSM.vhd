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
  signal start_detect : std_logic_vector(1 downto 0) := "11";
  signal start_bit : std_logic := '0';
begin

sync_proc : process (BC)
begin
  if (rising_edge(BC)) then
    if (reset = '1') then
      start_detect    <= "11";
      start_bit <= '0';
      PS <= Inicio;
    else
      start_detect <= start_detect(0) & data_in;
      PS <= NS;
      if (start_detect = "10") then
        start_bit <= '1';
      elsif (PS /= Inicio) then
        start_bit <= '0';
      end if;
    end if;
  end if;
end process sync_proc;



comb_proc : process (BC, PS)
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
        if (i < 16) then 
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
