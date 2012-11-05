library ieee;
use ieee.std_logic_1164.all;

-- do not change this entity
-- yes the signal lengths are correct
entity coco is
	port ( 
	  -- processor 0
	  --   ramd interface
	  ---- For fetch or write
	  addrIn0      : in std_logic_vector(31 downto 0);
	  dataIn0      : in std_logic_vector(31 downto 0);
	  memRead0     : in std_logic;
	  memWrite0    : in std_logic;
	  dataOut0     : out std_logic_vector(31 downto 0);
	  dready0      : out std_logic;
	  
	  ---- dram state
	  valid0       : in std_logic;
	  dirty0       : in std_logic;
	  
	  ---- dram block invalidation
	  invalidate0 : out std_logic;
	  invalidate_addr0 : out std_logic_vector(31 downto 0);
	  
	  ---- dram action monitoring
	  actionAddr0 : in std_logic_vector(31 downto 0);
	  actionWrite0 : in std_logic;
	  
	  ---- dram snooping
	  snoopData0 : in std_logic_vector(31 downto 0);
	  snoopAddr0 : out std_logic_vector(31 downto 0);
	  snoopHit0 : in std_logic;
	  
	  
	  
	  --   rami interface
	  pc0           : in std_logic_vector(31 downto 0);
	  iread0        : in std_logic;
	  ins0          : out std_logic_vector(31 downto 0);
	  iready0       : out std_logic;
	  
    -- processor 1
    --   ramd interface
    ---- For fetch or write
	  addrIn1      : in std_logic_vector(31 downto 0);
	  dataIn1      : in std_logic_vector(31 downto 0);
	  memRead1     : in std_logic;
	  memWrite1    : in std_logic;
	  dataOut1     : out std_logic_vector(31 downto 0);
	  dready1      : out std_logic;
	  
	  ---- dram state
	  valid1       : in std_logic;
	  dirty1       : in std_logic;
	  
	  ---- dram block invalidation
	  invalidate1 : out std_logic;
	  invalidate_addr1 : out std_logic_vector(31 downto 0);
	  
	  ---- dram action monitoring
	  actionAddr1 : in std_logic_vector(31 downto 0);
	  actionWrite1 : in std_logic;
	  
	  ---- dram snooping
	  snoopData1 : in std_logic_vector(31 downto 0);
	  snoopAddr1 : out std_logic_vector(31 downto 0);
	  snoopHit1 : in std_logic;
    
    
    --   rami interface
    pc1           : in std_logic_vector(31 downto 0);
    iread1        : in std_logic;
    ins1          : out std_logic_vector(31 downto 0);
    iready1       : out std_logic;
    
    -- mem interface signals
    memAddr   : out std_logic_vector (15 DOWNTO 0);
    memData   : out std_logic_vector (31 DOWNTO 0);
    memWren   : out std_logic;
    memRden   : out std_logic;
    memQ      : in std_logic_vector(31 downto 0);
    memState  : in std_logic_vector(1 downto 0);
    
    clk : in std_logic;
    nrst : in std_logic
	);
end coco;

architecture behavioral of coco is
  constant MEMFREE        : std_logic_vector              := "00";
  constant MEMBUSY        : std_logic_vector              := "01";
  constant MEMACCESS      : std_logic_vector              := "10";
  constant MEMERROR       : std_logic_vector              := "11";

  signal dataReady : std_logic;
  signal allWait_int : std_logic;
  signal memOutSource : std_logic;
  
  signal priorityReg : std_logic;
  signal n_priorityReg : std_logic;
  
  type MSI_STATE is (mdfd, shrd, invl);
  signal dramState0 : MSI_STATE;
  signal dramState1: MSI_STATE;

  signal busy : std_logic;
  
  type focus is (iram0, iram1, dram0, dram1, idle);
  signal memSelect : focus;

begin
  
  prio_reg : process (clk, nrst, n_priorityReg)
    begin
  
      if (nrst = '0') then
        priorityReg <= '0';
      elsif (rising_edge(clk)) then
        priorityReg <= n_priorityReg;
        
      end if;
      
    end process;
  
    
  n_priorityReg <= '1' when memSelect = iram0 else
                   '0' when memSelect = iram1 else
                   priorityReg;
  
  
  
  dramState0 <= mdfd when valid0 = '1' and dirty0 = '1' else
                shrd when valid0 = '1' and dirty0 = '0' else
                invl;
                
  dramState1 <= mdfd when valid1 = '1' and dirty1 = '1' else
                shrd when valid1 = '1' and dirty1 = '0' else
                invl;
  
  
  memSelect <= dram0 when memRead0 = '1' or memWrite0 = '1' else
               dram1 when memRead1 = '1' or memWrite1 = '1' else
               iram0 when iread0 = '1' and (priorityReg = '0' or iread1 = '0') else
               iram1 when iread1 = '1' and (priorityReg = '1' or iread0 = '0') else
              idle;
  
  dataReady <= '1' when (memState = MEMACCESS) else '0';
  
  -- rami interface signals
  ins0 <= memQ when memSelect = iram0 else (others => '0');
  ins1 <= memQ when memSelect = iram1 else (others => '0');
  
  iready0 <= dataReady when memSelect = iram0 and iread0 = '1' else '0';
  iready1 <= dataReady when memSelect = iram1 and iread1 = '1' else '0';
  
  dready0 <= dataReady or memOutSource when memSelect = dram0 else '0';
  dready1 <= dataReady or memOutSource when memSelect = dram1 else '0';
  
  -- ramd interface signals
  dataOut0 <= memQ when memOutSource = '0' else snoopData1;
  dataOut1 <= memQ when memOutSource = '0' else snoopData0;
  
  -- mem interface signals
  
  memAddr <= addrIn0(15 downto 0) when (memSelect = dram0) else
             addrIn1(15 downto 0) when (memSelect = dram1) else
             pc1(15 downto 0) when (memSelect = iram1) else
             pc0(15 downto 0);
      
  memData <= dataIn0 when memSelect = dram0 else
             dataIn1 when memSelect = dram1 else (others => '1');
             
  memWren <= memWrite0 when memSelect = dram0 else
             memWrite1 when memSelect = dram1 else '0';
             
  memRden <= memRead0 and (not memWrite0) and (not memOutSource) when memSelect = dram0 else
             memRead1 and (not memWrite1) and (not memOutSource) when memSelect = dram1 else
             iread0 and (not memWrite0) when memSelect = iram0 else
             iread1 and (not memWrite1) when memSelect = iram1 else '0';
             
  memOutSource <= snoopHit1 and memRead0 and (not memWrite0) when memSelect = dram0 else
                  snoopHit0 and memRead1 and (not memWrite1) when memSelect = dram1 else '0';
                  
  snoopAddr0 <= addrIn1;
  snoopAddr1 <= addrIn0;
        
  invalidate0 <= actionWrite1;
  invalidate1 <= actionWrite0;
  
	invalidate_addr0 <= actionAddr1;
	invalidate_addr1 <= actionAddr0;

end behavioral;
