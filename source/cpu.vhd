library ieee;
use ieee.std_logic_1164.all;

-- do not change this entity
-- yes the signal lengths are correct
entity cpu is
	port ( 
		-- clock signal
		cpuClk							:		in	std_logic;
		-- clock signal
		ramClk							:		in	std_logic;
		-- reset for processor
		nReset					:		in	std_logic;
		-- halt for processor
		halt						:		out	std_logic;
		-- start mmio addins
		-- dip switch in
		dipIn						:		in	std_logic_vector(15 downto 0);
		-- hexout
		hexOut					:		out	std_logic_vector(31 downto 0);
		-- end mmio addins
		-- address to dump
		dumpAddr 				:		in	std_logic_vector(15 downto 0);
        memNReset : in std_logic;
        -- mux signal to arbitrate control of mem between cpu and tb.  '1' means tb
        memCtl : in std_logic;
        -- mem write enable
        memWen : in std_logic;
        -- mem address
        memAddr : in std_logic_vector(15 downto 0);
        -- mem data
        memData : in std_logic_vector(31 downto 0);
        -- mem read result for dumping
        memQ : out std_logic_vector(31 downto 0);
        -- Address and write_en for snooping where write accesses are
        viewMemAddr : out std_logic_vector(15 downto 0);
        viewMemWen : out std_logic
	);
end cpu;

architecture behavioral of cpu is

	-- you may change the entity of your component
	-- as well as the signal names
  
	component mycpu
		port ( 
			-- clock signal
			CLK							:		in	std_logic;
			-- reset for processor
			nReset					:		in	std_logic;
			-- halt for processor
			halt						:		out	std_logic;
            ramAddr : out std_logic_vector(15 downto 0);
            ramData : out std_logic_vector(31 downto 0);
            ramWen  : out std_logic;
            ramRen  : out std_logic;
            ramQ    : in  std_logic_vector(31 downto 0);
            ramState : in std_logic_vector(1 downto 0)
		);
	end component;

	component VarLatRAM
	    port (
		nReset	         : in std_logic ;		
		clock	         : in std_logic ;
		address	         : in std_logic_vector (15 DOWNTO 0);
		data	         : in std_logic_vector (31 DOWNTO 0);
		wren	         : in std_logic ;
		rden	         : in std_logic ;
		latency_override : in std_logic ; 
	    q		         : out std_logic_vector (31 DOWNTO 0);
		memstate         : out std_logic_vector (1 DOWNTO 0)
	);
    end component;

    signal halt_int : std_logic;

    signal nonDumpAddr : std_logic_vector ( 15 downto 0);

    signal cpuRamAddr : std_logic_vector ( 15 downto 0);
    signal cpuRamData : std_logic_vector ( 31 downto 0);
    signal cpuRamWriteEn : std_logic;
    signal cpuRamReadEn : std_logic;
    signal cpuHalt : std_logic;

    signal ramAddr : std_logic_vector (15 downto 0);
    signal ramData : std_logic_vector (31 downto 0);
    signal ramWriteEn : std_logic;
    signal ramWriteEnTmp : std_logic;
    signal ramReadEn : std_logic;
    signal ramLatencyOverride : std_logic;
    signal ramQ : std_logic_vector (31 downto 0);
    signal ramState : std_logic_vector (1 downto 0);
    
begin

	theCPU : mycpu
	port map (CLK => cpuCLK, 
              nReset => nReset, 
              halt => cpuHalt, 
              ramAddr => cpuRamAddr,
              ramData => cpuRamData,
              ramWen => cpuRamWriteEn,
              ramRen => cpuRamReadEn,
              ramQ => ramQ,
              ramState => ramState);
    theRAM : VarLatRAM
    port map (
       nReset => memNReset,
       clock => ramClk,
       address => ramAddr,
       data => ramData,
       wren => ramWriteEn,
       rden => ramReadEn,
       latency_override => ramLatencyOverride,
       q => ramQ,
       memstate => ramState);
    with cpuHalt select
        ramAddr <= nonDumpAddr when '0',
                   dumpAddr when others;
    with memCtl select
        nonDumpAddr <= memAddr when '1',
                   cpuRamAddr when others;
    with memCtl select
        ramData <= memData when '1',
                   cpuRamData when others;
    with memCtl select
        ramWriteEnTmp <= memWen when '1',
                      cpuRamWriteEn when others;
    with cpuHalt select
        ramWriteEn <= ramWriteEnTmp when '0',
                      '0' when others;
    ramReadEn <= cpuRamReadEn or cpuHalt;
    ramLatencyOverride <= cpuHalt or memCtl;
    halt <= cpuHalt;
    memQ <= ramQ;
    viewMemWen <= ramWriteEn;
    viewMemAddr <= ramAddr;
    hexOut <= X"00000000";

end behavioral;
