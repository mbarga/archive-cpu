-- instruction memory / write back register

library ieee;
use ieee.std_logic_1164.all;

entity reg_MEM_WB is
	port
	(
		clk				:	in	std_logic;
		nReset	 	:	in	std_logic;
		nen : in std_logic;
		noop			: in std_logic;	
		
		d_halt  	: in std_logic;
		d_regWrite : in std_logic;
		d_regDest : in std_logic_vector(4 downto 0);
		d_Q : in std_logic_vector(31 downto 0);
		
		q_halt  	: out std_logic;
		q_regWrite : out std_logic;
		q_regDest : out std_logic_vector(4 downto 0);
		q_Q : out std_logic_vector(31 downto 0)
	);
end reg_MEM_WB;

architecture regfile_arch of reg_MEM_WB is

	constant zero : std_logic_vector := x"00000000";
	
	signal r_halt  	: std_logic;
	signal r_regWrite : std_logic;
	signal r_regDest : std_logic_vector(4 downto 0);
	signal r_Q : std_logic_vector(31 downto 0);
	
	signal n_halt  	: std_logic;
  signal n_regWrite : std_logic;
  signal n_regDest : std_logic_vector(4 downto 0);
  signal n_Q : std_logic_vector(31 downto 0);

begin

	registers : process (clk, nReset, nen)
  begin
		if (nReset = '0') then
			r_halt <= '0';
      r_regWrite <= '0';
      r_regDest <= "00000";
      r_Q <= zero;
    elsif (rising_edge(clk) and nen = '0') then
			r_halt <= n_halt;
      r_regWrite <= n_regWrite;
      r_regDest <= n_regDest;
      r_Q <= n_Q;
    end if;
  end process;
  
  n_halt <= r_halt when (r_halt = '1') else
            d_halt when (noop = '0') else'0';
  n_regWrite <= r_regWrite when (r_halt = '1') else
               d_regWrite when (noop = '0') else '0';
  n_regDest <=  r_regDest when (r_halt = '1') else
                d_regDest when (noop = '0') else "00000";
  n_Q <=  r_Q when (r_halt = '1') else
          d_Q when (noop = '0') else zero;
  
  q_halt <= r_halt;
  q_regWrite <= r_regWrite;
  q_regDest <= r_regDest;
  q_Q <= r_Q;
  
end regfile_arch;
