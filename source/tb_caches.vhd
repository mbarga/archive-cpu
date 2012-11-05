-- $Id: $
-- File name:   tb_icache.vhd
-- Created:     3/8/2011
-- Author:      Alex Reyes
-- Lab Section: Wednesday 7:30-10:20
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;


entity tb_caches is
generic (Period : Time := 10 ns);
end tb_caches;

architecture TEST of tb_caches is

  function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
     return STD_LOGIC_VECTOR is
    variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
    variable tmp : INTEGER;
  begin
    tmp := X;
    for i in 0 to NumBits-1 loop
      if (tmp mod 2)=1 then
        res(i) := '1';
      else
        res(i) := '0';
      end if;
      tmp := tmp/2;
    end loop;
    return res;
  end;

  component icache2
    PORT(
         clk : IN std_logic;
         memins : IN std_logic_vector (31 DOWNTO 0);
         dataready : IN std_logic;
         nrst : IN std_logic;
         pc : IN std_logic_vector (31 DOWNTO 0);
         ins : OUT std_logic_vector (31 DOWNTO 0);
         mempc : OUT std_logic_vector (15 DOWNTO 0);
         pcwait : OUT std_logic;
         iread : OUT std_logic
    );
  end component;
    
    component dram
       PORT( 
          clk       : IN     std_logic;
          cpu_addr  : IN     std_logic_vector (31 DOWNTO 0);
          cpu_ren   : IN     std_logic;
          cpu_wdata : IN     std_logic_vector (31 DOWNTO 0);
          cpu_wen   : IN     std_logic;
          dready    : IN     std_logic;
          mem_rdat  : IN     std_logic_vector (31 DOWNTO 0);
          nrst      : IN     std_logic;
          dump      : IN     std_logic;
          dump_complete : OUT std_logic;
          cpu_rdata : OUT    std_logic_vector (31 DOWNTO 0);
          dwait     : OUT    std_logic;
          mem_addr  : OUT    STD_LOGIC_VECTOR (31 DOWNTO 0);
          mem_ren   : OUT    std_logic;
          mem_wdat  : OUT    std_logic_vector (31 DOWNTO 0);
          mem_wen   : OUT    std_logic
       );
  end component;

    procedure println( output_string : in string ) is
      variable lout                  :    line;
    begin
      WRITE(lout, output_string);
      WRITELINE(OUTPUT, lout);
    end println;
  
    procedure printlv( output_bv : in std_logic_vector(31 downto 0) ) is
      variable lout              :    line;
    begin
      WRITE(lout, output_bv);
      WRITELINE(OUTPUT, lout);
    end printlv; 
    
-- Insert signals Declarations here
  signal clk : std_logic;
  signal memins : std_logic_vector (31 DOWNTO 0);
  signal dataready : std_logic;
  signal nrst : std_logic;
  signal pc : std_logic_vector (31 DOWNTO 0);
  signal ins : std_logic_vector (31 DOWNTO 0);
  signal mempc : std_logic_vector (15 DOWNTO 0);
  signal pcwait : std_logic;
  signal iread : std_logic;
  
  signal cpu_addr  :      std_logic_vector (31 DOWNTO 0);
  signal cpu_ren   :      std_logic;
  signal cpu_wdata :      std_logic_vector (31 DOWNTO 0);
  signal cpu_wen   :      std_logic;
  signal dready    :      std_logic;
  signal mem_rdat  :     std_logic_vector (31 DOWNTO 0);
  signal dump      :     std_logic;
  signal dump_complete :  std_logic;
  signal cpu_rdata :     std_logic_vector (31 DOWNTO 0);
  signal dwait     :     std_logic;
  signal mem_addr  :     STD_LOGIC_VECTOR (31 DOWNTO 0);
  signal mem_ren   :    std_logic;
  signal mem_wdat  :    std_logic_vector (31 DOWNTO 0);
  signal mem_wen   :    std_logic;

-- signal <name> : <type>;

begin

CLKGEN: process
  variable clk_tmp: std_logic := '0';
begin
  clk_tmp := not clk_tmp;
  clk <= clk_tmp;
  wait for Period/2;
end process;

  DUT: icache2 port map(
                clk => clk,
                memins => memins,
                dataready => dataready,
                nrst => nrst,
                pc => pc,
                ins => ins,
                mempc => mempc,
                pcwait => pcwait,
                iread => iread
                );
  
  DUT1: dram port map(
    clk  => clk,
    cpu_addr =>cpu_addr,
    cpu_ren => cpu_ren,
    cpu_wdata => cpu_wdata,
    cpu_wen   => cpu_wen,
    dready    => dready,
    mem_rdat  => mem_rdat,
    nrst      => nrst,
    dump     => dump,
    dump_complete => dump_complete,
    cpu_rdata => cpu_rdata,
    dwait     => dwait,
    mem_addr  => mem_addr,
    mem_ren   => mem_ren,
    mem_wdat  => mem_wdat,
    mem_wen   => mem_wen
  );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    memins <= (others => '0'); 
    dataready <= '0'; 
    nrst <= '0';

    pc <= (others => '0');
    
    cpu_ren   <= '0';
    cpu_wdata <= (others => '0');
    cpu_wen   <= '0';
    dready    <= '0';
    mem_rdat  <= (others => '0');
    dump      <= '0';    
    
    wait for 15 ns;
    
    nrst <= '1';
    
    wait for 20 ns;

    if (iread = '1') then
      println("PASSED   : iread = 1");
    else
      println("FAILED   : iread != 1");
    end if;
    
    if (pcwait = '1') then
      println("PASSED   : pcwait = 1");
    else
      println("FAILED   : pcwait != 1");
    end if;
    
    memins <= (others => '1');
    dataready <= '1';
    pc <= (others => '0');
    
    wait for 10 ns;

    if (ins = x"FFFFFFFF") then
      println("PASSED   : ins = FFFFFFFF");
    else
      println("FAILED   : ins != FFFFFFFF");
    end if;
    
    if (pcwait = '0') then
      println("PASSED   : pcwait = 0");
    else
      println("FAILED   : pcwait != 0");
    end if;
    
    memins <= (others => '0');
    dataready <= '0';
    pc <= (others => '1');
    
    wait for 10 ns;
    
    if (pcwait = '1') then
      println("PASSED   : pcwait = 1");
    else
      println("FAILED   : pcwait != 1");
    end if;
    
    memins <= (others => '0');
    dataready <= '0';
    pc <= (others => '0');
    
    wait for 10 ns;
    
    
    
    if (ins = x"FFFFFFFF") then
      println("PASSED   : ins = FFFFFFFF");
    else
      println("FAILED   : ins != FFFFFFFF");
    end if;
    
     if (pcwait = '0') then
      println("PASSED   : pcwait = 0");
    else
      println("FAILED   : pcwait != 0");
    end if;
    
    if (iread = '0') then
      println("PASSED   : iread = 0");
    else
      println("FAILED   : iread != 0");
    end if;
    
    wait for 10 ns; 
    
    cpu_ren   <= '1';
    dready <= '0';
    
    wait for 10 ns;
    if (dwait = '1') then
      println("PASSED   : dwait = 1");
    else
      println("FAILED   : dwait != 1");
      
      
    end if;
    
    wait for 10 ns;
    
    dready <= '1';
    cpu_ren <= '0';
    cpu_wen <= '1';
    cpu_wdata <= x"FFFFFFFF";
    mem_rdat <= x"ABCDEF10"; 
    
    wait for 10 ns;

    if (mem_ren = '1') then
      println("PASSED   : memren = 1");
    else
      println("FAILED   : memren != 1");
    end if;
    
    wait for 80 ns;
    
    if (cpu_rdata = x"ABCDEF10") then
        println("PASSED   : cpuread data = ABCDEF01");
    else
        println("FAILED   : cpuread data != ABCDEF01");
    end if;

    if (mem_wdat /= x"FFFFFFFF") then
      println("PASSED   : mem write = FFFFFFFF");
    else
      println("FAILED   : mem write != FFFFFFFF");
    end if;
    
    if (dwait = '0') then
      println("PASSED   : dwait = 0");
    else
      println("FAILED   : dwait != 0");
    end if;
    
    dready <= '1';
    cpu_ren <= '1';
    
    wait for 20 ns;
    

    
    
    
    dready <= '1';
    
    wait for 10 ns;
    
    println("Test complete");
    wait;
  end process;
end TEST;