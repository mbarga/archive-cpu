-- result forwarding unit

library ieee;
use ieee.std_logic_1164.all;

entity fwdUnit is
	port
	( -- pending write registers
    
    pendWr1  : in std_logic_vector(4 downto 0);
    pendWr2 : in std_logic_vector(4 downto 0);
    pendWr1Data : in std_logic_vector(31 downto 0);
    pendWr2Data : in std_logic_vector(31 downto 0);
    memToReg1 : in std_logic;
    memToReg2 : in std_logic;
    
    regWrite1 : in std_logic;
    regWrite2 : in std_logic;
    
    rselA : in std_logic_vector(4 downto 0);
    rdatA : in std_logic_vector(31 downto 0);
    rselB : in std_logic_vector(4 downto 0);
    rdatB : in std_logic_vector(31 downto 0);
    
    Aout : out std_logic_vector(31 downto 0);
    Bout : out std_logic_vector(31 downto 0);
     
    fw2A : out std_logic;
    fw2B : out std_logic;
    loadDep1   : out std_logic
	);
end fwdUnit;

architecture fwdUnit_arch of fwdUnit is

signal match1A : std_logic;
signal match2A : std_logic;

signal match1B : std_logic;
signal match2B : std_logic;
	
begin
  
  match1A <= '1' when (pendWr1 = rselA and (not (rselA = "00000")) and (regWrite1 = '1')) else '0';
  match2A <= '1' when (pendWr2 = rselA and (not (rselA = "00000")) and (regWrite2 = '1')) else '0';
  
  match1B <= '1' when (pendWr1 = rselB and (not (rselB = "00000")) and (regWrite1 = '1')) else '0';
  match2B <= '1' when (pendWr2 = rselB and (not (rselB = "00000")) and (regWrite2 = '1')) else '0';
  
  Aout <= pendWr1Data when (match1A = '1') else
          pendWr2Data when (match2A = '1') else
          rdatA;
          
  Bout <= pendWr1Data when (match1B = '1') else
          pendWr2Data when (match2B = '1') else
          rdatB;
          
  loadDep1 <= (memToReg1 and (match1A or match1B)) or (memToReg2 and (match2A or match2B));
  
  
  fw2A <= '0';
  fw2B <= '0';
  
end fwdUnit_arch;
