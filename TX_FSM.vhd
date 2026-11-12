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