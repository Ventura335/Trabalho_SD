library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tx_fsm is
  port (
    BC, reset, load, tx_start, sel_in_tx : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    tx_busy, shift_tx  : OUT std_logic;
    data_out : out std_logic_vector(7 downto 0)
    );
end tx_fsm;

architecture fsm of tx_fsm is
  type state_type is (Inicio, Load_tx_chave, Load_tx_loop, Tx_start_bit, Tx_bit, Stop);

  signal ps, ns : state_type;
  signal cont : integer;
begin

  sync_proc : process (BC) -- note: no NS here!
  begin -- state reset and transition
    if (rising_edge(BC)) then
      PS <= NS;
    end if;
  end process sync_proc;

  comb_proc : process (PS)
    begin
    case PS is
      when Inicio =>
        if (Reset = '1') then
          Ns <= Inicio;
        elsif (Reset = '0' and load='1') then
          Ns <= Load_tx_chave;
        end if;

      when Load_tx_chave =>
        tx_busy <= '0';
        if (tx_start = '1') then 
            ns <= Tx_start_bit;
        end if;
        if (sel_in_tx = '1') then
            ns <= Load_tx_loop;
        else 
            ns <= Load_tx_chave;
        end if;

      when Load_tx_loop =>
        tx_busy <= '0';
        if (tx_start = '1') then 
            ns <= Tx_start_bit;
        end if;
        if (not sel_in_tx = '1') then
            ns <= Load_tx_chave;
        else 
            ns <= Load_tx_loop;
        end if;
        
      when Tx_start_bit =>
        tx_busy <= '1';
        ns <= Tx_bit;
      when Tx_bit =>
        shift_tx <= '1';
        tx_busy <= '1';
        data_out <= data_in;
        NS <= Inicio;
        cont <= cont + 1;
        if (cont = 8) then
          ns <= Stop;
          cont <= 0;
        end if;
      when Stop =>
        tx_busy <= '0';
        ns <= Inicio;

  end case;
end process comb_proc;
end fsm;