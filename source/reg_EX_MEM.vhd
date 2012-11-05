-- instruction execute / mem back register

library ieee;
use ieee.std_logic_1164.all;

entity reg_EX_MEM is
	port
	(
		clk				:	in	std_logic;
		nReset	 	:	in	std_logic;
		nen : in std_logic;
		noop			: in std_logic;	
		
		d_halt  	: in std_logic;
		d_regWrite : in std_logic;
		d_regDest : in std_logic_vector(4 downto 0);
		
		d_B : in std_logic_vector(31 downto 0);
		d_result : in std_logic_vector(31 downto 0);
		d_memtoReg : in std_logic;
		d_memWrite : in std_logic;
		d_ll       : in std_logic;
		d_sc       : in std_logic;
		
		
		q_halt  	: out std_logic;
		q_regWrite : out std_logic;
		q_regDest : out std_logic_vector(4 downto 0);
		
		q_B : out std_logic_vector(31 downto 0);
		q_result : out std_logic_vector(31 downto 0);
		q_memtoReg : out std_logic;
		q_memWrite : out std_logic;
		q_ll       : out std_logic;
		q_sc       : out std_logic
	);
end reg_EX_MEM;

architecture regfile_arch of reg_EX_MEM is

	constant zero : std_logic_vector := x"00000000";
	
	signal r_halt  	: std_logic;
	signal r_regWrite : std_logic;
	signal r_regDest : std_logic_vector(4 downto 0);
	signal r_B : std_logic_vector(31 downto 0);
	signal r_result : std_logic_vector(31 downto 0);
  signal r_memtoReg : std_logic;
	signal r_memWrite : std_logic;
	signal r_ll       :  std_logic;
  signal r_sc       :  std_logic;
	
	signal n_halt  	: std_logic;
  signal n_regWrite : std_logic;
  signal n_regDest : std_logic_vector(4 downto 0);
  signal n_B : std_logic_vector(31 downto 0);
  signal n_result : std_logic_vector(31 downto 0);
  signal n_memtoReg : std_logic;
  signal n_memWrite : std_logic;
  signal n_ll       : std_logic;
  signal n_sc       : std_logic;
  
begin

	registers : process (clk, nReset, nen)
  begin
		if (nReset = '0') then
			r_halt <= '0';
      r_regWrite <= '0';
      r_regDest <= "00000";
      r_B <= zero;
      r_result <= (others => '0');
      r_memtoReg <= '0';
      r_memWrite <= '0';
      r_ll <= '0';
      r_sc <= '0';
    elsif (rising_edge(clk) and nen = '0') then
			r_halt <= n_halt;
      r_regWrite <= n_regWrite;
      r_regDest <= n_regDest;
      r_B <= n_B;
      r_result <= n_result;
      r_memtoReg <= n_memtoReg;
      r_memWrite <= n_memWrite;
      r_ll <= n_ll;
      r_sc <= n_sc;
    end if;
  end process;
  
  n_halt <= r_halt when (r_halt = '1') else
            d_halt when (noop = '0') else'0';
  n_regWrite <= r_regWrite when (r_halt = '1') else
               d_regWrite when (noop = '0') else '0';
  n_regDest <=  r_regDest when (r_halt = '1') else
                d_regDest when (noop = '0') else "00000";
  n_B <=  r_B when (r_halt = '1') else
          d_B when (noop = '0') else zero;
  n_result <= r_result when (r_halt = '1') else
              d_result when (noop = '0') else zero;
  n_memtoReg <= r_memtoReg when (r_halt = '1') else
                d_memtoReg when (noop = '0') else '0';
  n_memWrite <= r_memWrite when (r_halt = '1') else
                d_memWrite when (noop = '0') else '0';
  n_ll <= r_ll when (r_halt = '1') else
                d_ll when (noop = '0') else '0';
  n_sc <= r_sc when (r_halt = '1') else
                d_sc when (noop = '0') else '0';
  
  q_halt <= r_halt;
  q_regWrite <= r_regWrite;
  q_regDest <= r_regDest;
  q_B <= r_B;
  q_result <= r_result;
  q_memtoReg <= r_memtoReg;
  q_memWrite <= r_memWrite;
  q_ll <= r_ll;
  q_sc <= r_sc;
  
end regfile_arch;
