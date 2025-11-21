library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;
use ieee.numeric_std.all;

-- Bloco de Controle (BC) da ULA.
-- Responsável por gerar os sinais de controle para o bloco operativo (BO),
-- por meio de uma FSM.
entity ula_bo is
  generic (
    N : positive := 8
  );
  port (
    clk           : in std_logic; -- clock (sinal de relógio)
    in_operativo  : in bo_entradas;
    in_comandos   : in bc_comandos;
    out_status    : out status_bo;
    out_operativo : out bo_saidas);
end entity ula_bo;

architecture structure of ula_bo is
  signal A, B : std_logic_vector(N - 1 downto 0);
  --renato signal´s
  signal result_mux6, result_mux7, count_r, result_mux8, result_count_r_less : std_logic_vector(N - 1 downto 0);
begin

  -- madu
  --registrador para passar A
  reg_A : entity work.std_logic_register(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      enable => in_comandos.cA, --VERIFICARRRRRRRRRRRRR pq n é so isso, fiz so para eu preciso de "A" para o meu 
      d      => in_operativo.entA,
      q      => A);
  --registrador para passar B
  reg_B : entity work.std_logic_register(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      enable => in_comandos.cB,
      d      => in_operativo.entB,
      q      => B);
  

  -------------------------PARTE DO RENATO FINALIZADA---------------------------

  --signals A(0) e A==0?
  out_status.A_0 <= A(0);
  out_status.Az <= '1' when unsigned(count_r) = 0 else '0';

  mux_6 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c0,
      in_0  => A,
      in_1  => std_logic_vector(to_unsigned(N, N)),
      s_mux => result_mux6);

  mux_7 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => in_comandos.mcount,
      in_0  => result_count_r_less,
      in_1  => std_logic_vector(to_unsigned(N, N)),
      s_mux => result_mux7);

  reg_count_r : entity work.std_logic_register(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      enable => in_comandos.ccount,
      d      => result_mux7,
      q      => count_r);

  --signal count == 0?
  out_status.countz <= '1' when unsigned(count_r) = 0 else '0';

  mux_8 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c0,
      in_0  => B,
      in_1 => (0 => '1', others => '0'),
      s_mux => result_mux8);

  sub: entity work.subtractor(behavior)
  generic map(
      N => N)
    port map
    (
    input_a => count_r,
    input_b  => result_mux8,
    result    => result_count_r_less,
    carry_out => open,
    overflow => open);

  count_less_than_B: entity work.count_less_than_B(behavior)
  generic map(
      N => N)
    port map
    (
    input_a => count_r,
    input_b  => B,
    result    => out_status.AmqB);


  -- Lucas

  --Lucas, o sinal que entra em M9 entrada 0 se chama "count_r". ass: Renato
end architecture structure;