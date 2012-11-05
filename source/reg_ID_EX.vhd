-- instruction memory / write back register

library ieee;
use ieee.std_logic_1164.all;

entity reg_ID_EX is
  port
  (
    clk				:	in	std_logic;
    nReset	 	:	in	std_logic;
    nen : in std_logic;
    noop			: in std_logic;	
    
    d_halt  	: in std_logic;
    d_pc			: in std_logic_vector(31 downto 0);
    d_immWrite : in std_logic;
    d_SLT : in std_logic;
    d_regWrite : in std_logic;
    d_link : in std_logic;
    d_regDest : in std_logic_vector(4 downto 0);
    d_B : in std_logic_vector(31 downto 0);  
    d_shamt : in std_logic_vector(31 downto 0);
    d_imm : in std_logic_vector(31 downto 0);   
    d_memtoReg : in std_logic;
    d_memWrite : in std_logic;
    d_A : in std_logic_vector(31 downto 0);
    d_AluOp : in std_logic_vector(2 downto 0);
    d_AluSrcShamt : in std_logic;
    d_AluSrc : in std_logic;
    
    d_fwA : in std_logic;
    d_fwB : in std_logic;
    
    d_sc : in std_logic;
    d_ll : in std_logic;
    
    q_sc : out std_logic;
    q_ll : out std_logic;
    q_halt  	: out std_logic;
    q_pc			: out std_logic_vector(31 downto 0);
    q_immWrite : out std_logic;
    q_SLT : out std_logic;
    q_regWrite : out std_logic;
    q_link : out std_logic;
    q_regDest : out std_logic_vector(4 downto 0);
    q_B : out std_logic_vector(31 downto 0);
    q_shamt : out std_logic_vector(31 downto 0);
    q_imm : out std_logic_vector(31 downto 0);
    q_memtoReg : out std_logic;
    q_memWrite : out std_logic;
    q_A : out std_logic_vector(31 downto 0);
    q_AluSrcShamt : out std_logic;
    q_AluSrc : out std_logic;
    q_fwA : out std_logic;
    q_fwB : out std_logic;
    q_AluOp : out std_logic_vector(2 downto 0)
  );
end reg_ID_EX;

architecture regfile_arch of reg_ID_EX is

  constant zero : std_logic_vector := x"00000000";
  
  signal r_halt  	: std_logic;
  signal r_pc			: std_logic_vector(31 downto 0);
  signal r_immWrite : std_logic;
  signal r_SLT : std_logic;
  signal r_regWrite : std_logic;
  signal r_link : std_logic;
  signal r_regDest : std_logic_vector(4 downto 0);
  signal r_B : std_logic_vector(31 downto 0);
  signal r_memtoReg : std_logic;
  signal r_memWrite : std_logic;
  signal r_A : std_logic_vector(31 downto 0);
  signal r_AluOp : std_logic_vector(2 downto 0);
  signal r_shamt : std_logic_vector(31 downto 0);
  signal r_imm : std_logic_vector(31 downto 0);
  signal r_AluSrcShamt : std_logic;
  signal r_AluSrc : std_logic;
  signal r_fwA : std_logic;
  signal r_fwB : std_logic;
  signal r_ll : std_logic;
  signal r_sc : std_logic;
  
  signal n_halt  	: std_logic;
  signal n_pc			: std_logic_vector(31 downto 0);
  signal n_immWrite : std_logic;
  signal n_SLT : std_logic;
  signal n_regWrite : std_logic;
  signal n_link : std_logic;
  signal n_regDest : std_logic_vector(4 downto 0);
  signal n_B : std_logic_vector(31 downto 0);
  signal n_memtoReg : std_logic;
  signal n_memWrite : std_logic;
  signal n_A : std_logic_vector(31 downto 0);
  signal n_AluOp : std_logic_vector(2 downto 0);
  signal n_shamt : std_logic_vector(31 downto 0);
  signal n_imm : std_logic_vector(31 downto 0);
  signal n_AluSrcShamt : std_logic;
  signal n_AluSrc : std_logic;
  signal n_fwA : std_logic;
  signal n_fwB : std_logic;
  signal n_ll : std_logic;
  signal n_sc : std_logic;
  
begin

  registers : process (clk, nReset, nen)
  begin
    if (nReset = '0') then
      r_halt <= '0';
      r_pc	<= zero;
      r_immWrite <= '0';
      r_SLT <= '0';
      r_regWrite <= '0';
      r_link <= '0';
      r_regDest <= "00000";
      r_B <= zero;
      r_memtoReg <= '0';
      r_memWrite <= '0';
      r_A <= zero;
      r_AluOp <= "000";
      r_shamt <= zero;
      r_imm <= zero;
      r_AluSrcShamt <= '0';
      r_AluSrc <= '0';
      r_fwA <= '0';
      r_fwB <= '0';
      r_ll <= '0';
      r_sc <= '0';
    elsif (rising_edge(clk) and nen = '0') then
      r_halt <= n_halt;
      r_pc	<= n_pc;
      r_immWrite <= n_immWrite;
      r_SLT <= n_SLT;
      r_regWrite <= n_regWrite;
      r_link <= n_link;
      r_regDest <= n_regDest;
      r_B <= n_B;
      r_memtoReg <= n_memtoReg;
      r_memWrite <= n_memWrite;
      r_A <= n_A;
      r_AluOp <= n_AluOp;
      r_shamt <= n_shamt;
      r_imm <= n_imm;
      r_AluSrcShamt <= n_AluSrcShamt;
      r_AluSrc <= n_AluSrc;
      r_fwA <= n_fwA;
      r_fwB <= n_fwB;
      r_ll <= n_ll;
      r_sc <= n_sc;
    end if;
  end process;
  
  n_halt <= r_halt when (r_halt = '1') else
            d_halt when (noop = '0') else'0';
  n_pc	<=  r_pc when (r_halt = '1') else
            d_pc when (noop = '0') else zero;
  n_immWrite <= r_immWrite when (r_halt = '1') else
                d_immWrite when (noop = '0') else '0';
  n_SLT <= r_SLT when (r_halt = '1') else
           d_SLT when (noop = '0') else '0';
  n_regWrite <= r_regWrite when (r_halt = '1') else
               d_regWrite when (noop = '0') else '0';
  n_link <=  r_link when (r_halt = '1') else
              d_link when (noop = '0') else '0';
  n_regDest <=  r_regDest when (r_halt = '1') else
                d_regDest when (noop = '0') else "00000";
  n_B <=  r_B when (r_halt = '1') else
          d_B when (noop = '0') else zero;
  n_A <=  r_A when (r_halt = '1') else
          d_A when (noop = '0') else zero;
  n_AluOp <=  r_AluOp when (r_halt = '1') else
          d_AluOp when (noop = '0') else "000";
  n_memtoReg <= r_memtoReg when (r_halt = '1') else
                d_memtoReg when (noop = '0') else '0';
  n_memWrite <= r_memWrite when (r_halt = '1') else
                d_memWrite when (noop = '0') else '0';
  n_shamt <= r_shamt when (r_halt = '1') else
                d_shamt when (noop = '0') else zero;
  n_imm <= r_imm when (r_halt = '1') else
                d_imm when (noop = '0') else zero;
                
  n_AluSrcShamt <= r_AluSrcShamt when (r_halt = '1') else
                d_AluSrcShamt when (noop = '0') else '0';
  n_AluSrc <= r_AluSrc when (r_halt = '1') else
                d_AluSrc when (noop = '0') else '0';
  n_fwA <= r_fwA when (r_halt = '1') else
           d_fwA when (noop = '0') else '0';
  n_fwB <= r_fwB when (r_halt = '1') else
           d_fwB when (noop = '0') else '0';
           
  n_ll <= r_ll when (r_halt = '1') else
          d_ll when (noop = '0') else '0';
          
  n_sc <= r_sc when (r_halt = '1') else
          d_sc when (noop = '0') else '0';
  
  q_halt <= r_halt;
  q_pc	<= r_pc;
  q_immWrite <= r_immWrite;
  q_SLT <= r_SLT;
  q_regWrite <= r_regWrite;
  q_link <= r_link;
  q_regDest <= r_regDest;
  q_A <= r_A;
  q_AluOp <= r_AluOp;
  q_B <= r_B;
  q_memtoReg <= r_memtoReg;
  q_memWrite <= r_memWrite;
  q_shamt <= r_shamt;
  q_imm <= r_imm;
  q_AluSrcShamt <= r_AluSrcShamt;
  q_AluSrc <= r_AluSrc;
  q_fwA <= r_fwA;
  q_fwB <= r_fwB;
  q_ll <= r_ll;
  q_sc <= r_sc;
  
end regfile_arch;

