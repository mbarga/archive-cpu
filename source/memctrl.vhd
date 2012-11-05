-- memory controller file
-- agreyes

library ieee;
use ieee.std_logic_1164.all;

entity memctrl is
	port
	(
	  -- rami interface signals
		pc	:	in	std_logic_vector(31 downto 0);
		iread : in std_logic;
		ins : out std_logic_vector(31 downto 0);
		iready : out std_logic;
		
		
		-- ramd interface signals
		addr : in std_logic_vector(31 downto 0);
		dataIn : in std_logic_vector(31 downto 0);
		memRead : in std_logic;
		memWrite : in std_logic;
		dataOut : out std_logic_vector(31 downto 0);
		dready: out std_logic;
		
		-- mem interface signals
		memAddr : out std_logic_vector (15 DOWNTO 0);
    memData : out std_logic_vector (31 DOWNTO 0);
    memWren : out std_logic ;
    memRden : out std_logic ;
		memQ : in std_logic_vector(31 downto 0);
		memState : in std_logic_vector(1 downto 0)
		);
end memctrl;

architecture memctrl_arch of memctrl is
  constant MEMFREE        : std_logic_vector              := "00";
  constant MEMBUSY        : std_logic_vector              := "01";
  constant MEMACCESS      : std_logic_vector              := "10";
  constant MEMERROR       : std_logic_vector              := "11";
  signal memSelect : std_logic;
  signal dataReady : std_logic;
  signal allWait_int : std_logic;
	
begin
  
  memSelect <= memRead or memWrite;
  
  dataReady <= '1' when (memState = MEMACCESS) else '0';
  
  -- rami interface signals
  ins <= (others => '0') when (memSelect = '1') else memQ;
  iready <= iread and (not memSelect) and dataReady;
  dready <= memSelect and dataReady;
  
  -- ramd interface signals
  dataOut <= memQ;
  
  -- mem interface signals
  memAddr <= addr(15 downto 0) when (memSelect = '1') else pc(15 downto 0);
  memData <= dataIn;
  memWren <= memWrite;
  memRden <= (memRead or iread) and (not memWrite);

end memctrl_arch;
