-- instruction memory / write back register

library ieee;
use ieee.std_logic_1164.all;

entity reg_IF_ID is
  port
  (
    clk				:	in	std_logic;
    nReset	 	:	in	std_logic;
    nen : in std_logic;
    noop			: in std_logic;	
    
    d_halt  	: in std_logic;
    d_pc			: in std_logic_vector(31 downto 0);
    d_ins : in std_logic_vector(31 downto 0);
    
    q_halt  	: out std_logic;
    q_pc			: out std_logic_vector(31 downto 0);
    q_ins : out std_logic_vector(31 downto 0)
  );
end reg_IF_ID;

architecture regfile_arch of reg_IF_ID is

  constant zero : std_logic_vector := x"00000000";
  
  signal r_halt  	: std_logic;
  signal r_pc			: std_logic_vector(31 downto 0);
  signal r_ins : std_logic_vector(31 downto 0);
  
  signal n_halt  	: std_logic;
  signal n_pc			: std_logic_vector(31 downto 0);
  signal n_ins : std_logic_vector(31 downto 0);
  
begin

  registers : process (clk, nReset, nen)
  begin
    if (nReset = '0') then
      r_halt <= '0';
      r_pc	<= zero;
      r_ins <= zero;
    elsif (rising_edge(clk) and nen = '0') then
      r_halt <= n_halt;
      r_pc	<= n_pc;
      r_ins <= n_ins;
    end if;
  end process;
  
  n_halt <= r_halt when (r_halt = '1') else
            d_halt when (noop = '0') else'0';
  n_pc	<=  r_pc when (r_halt = '1') else
            d_pc when (noop = '0') else zero;
  n_ins	<=  r_ins when (r_halt = '1') else
            d_ins when (noop = '0') else zero;
  
  q_halt <= r_halt;
  q_pc	<= r_pc;
  q_ins <= r_ins;
  
end regfile_arch;

