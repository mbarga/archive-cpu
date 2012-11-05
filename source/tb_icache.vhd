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


entity tb_icache is
generic (Period : Time := 10 ns);
end tb_icache;

architecture TEST of tb_icache is

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

  component icache
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

-- signal <name> : <type>;

begin

CLKGEN: process
  variable clk_tmp: std_logic := '0';
begin
  clk_tmp := not clk_tmp;
  clk <= clk_tmp;
  wait for Period/2;
end process;

  DUT: icache port map(
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

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    memins <= (others => '0'); 

    dataready <= '0'; 

    nrst <= '0';

    pc <= (others => '0');
    
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
    
    println("Test complete");
    wait;

  end process;
end TEST;