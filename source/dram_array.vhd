-- data array for icache; OWNER: mbarga

library ieee;
use ieee.std_logic_1164.all;

entity dram_array is
  port
  ( wdat		:	in	std_logic_vector (31 downto 0);    -- write data
    
    wen			:	in	std_logic;                         -- write enable
    set   : in std_logic;                         -- set sel
    
    tag : in std_logic_vector(24 downto 0);
    
    tag_dump : out std_logic_vector(24 downto 0);
    
    invalid_addr : in std_logic_vector(31 downto 0);
    invalidate : in std_logic;
    
    index : in std_logic_vector(3 downto 0);
        
    ---- dram snooping
    snoopData : out std_logic_vector(31 downto 0);
    snoopAddr : in std_logic_vector(31 downto 0);
    snoopHit : out std_logic;
    
    rdat		:	out	std_logic_vector (31 downto 0);   -- read data out port
    dirty_out : out std_logic;
    valid_out : out std_logic;
    
    clean : in std_logic;
    
    hit   : out std_logic;
    
    clk			:	in	std_logic;
    nrst	 :	in	std_logic
    );
end dram_array;

architecture dram_array_arch of dram_array is

  --- [31-7]:cache tag [6-3]:cache index,[2]:word select, [1-0]:byte select ---
  
  constant BAD	:	std_logic_vector		:= x"BAD1BAD1";

  type VALID16 is array (0 to 15) of std_logic;
  type DIRTY16 is array (0 to 15) of std_logic;
  type TAG25 is array (0 to 15) of std_logic_vector(24 downto 0); -- 25 bit tag
  
  type SET16 is array (0 to 15) of std_logic_vector(31 downto 0);
  
  signal set0	:	SET16;				-- set array
  signal set1 : SET16;    -- set array
  signal tags : TAG25;    -- tag data array
  signal valid : VALID16;    -- tag data array
  signal dirty : DIRTY16;    -- tag data array
  
  signal wen0 : std_logic;
  signal wen1 : std_logic;
  
  signal rdat0 : std_logic_vector(31 downto 0);
  signal rdat1 : std_logic_vector(31 downto 0);
  
  signal pick       : integer range 0 to 15;
  
  signal invalid_tag : std_logic_vector(24 downto 0);
  signal invalid_index : std_logic_vector(3 downto 0);
  signal invalid_pick : integer range 0 to 15;
  
  signal snoopPick : integer range 0 to 15;
  signal snoop_index : std_logic_vector(3 downto 0);
  
  signal int_snoopHit : std_logic;
  
begin
  
  snoop_index <= snoopAddr(6 downto 3);
  
  wen0 <= wen when set = '0' else '0';
  wen1 <= wen when set = '1' else '0';
  
  sets : process (clk, nrst, wen, clean, invalidate, pick, invalid_pick, tag, wdat, wen0, wen1)
  begin

    if (nrst = '0') then
      -- on reset, set all valid bits to FALSE
      for i in 15 downto 0 loop
        dirty(i) <= '0';
        valid(i) <= '0';
      end loop;
      
    elsif (rising_edge(clk)) then
      -- if write enable set, then write ram data to indexed set
      if(wen = '1')then
        tags(pick) <= tag;
      end if;
      
      if(wen = '1') then
        valid(pick) <= '1';
      elsif(invalidate = '1') then
        if(tags(invalid_pick) = invalid_tag) then
          valid(invalid_pick) <= '0';
        end if;
      end if;
      
      if(wen0 = '1') then
        set0(pick) <= wdat;
      end if;
      
      if(wen1 = '1') then
        set1(pick) <= wdat;
      end if;
      
      
      if(clean = '1') then
        dirty(pick) <= '0';
      elsif(wen = '1') then
        dirty(pick) <= '1';
      end if;
    end if;
    
  end process;
  
  invalid_index <= invalid_addr(6 downto 3);
  invalid_tag <= invalid_addr(31 downto 7);

  with index select
    pick <=    0 when "0000", 
               1 when "0001",
               2 when "0010",
               3 when "0011",
               4 when "0100",
               5 when "0101",
               6 when "0110",
               7 when "0111",
               8 when "1000",
               9 when "1001",
               10 when "1010",
               11 when "1011",
               12 when "1100",
               13 when "1101",
               14 when "1110",
               15 when others;
               
  with invalid_index select
    invalid_pick <=    0 when "0000", 
               1 when "0001",
               2 when "0010",
               3 when "0011",
               4 when "0100",
               5 when "0101",
               6 when "0110",
               7 when "0111",
               8 when "1000",
               9 when "1001",
               10 when "1010",
               11 when "1011",
               12 when "1100",
               13 when "1101",
               14 when "1110",
               15 when others;
  with snoop_index select
    snoopPick <=    0 when "0000", 
               1 when "0001",
               2 when "0010",
               3 when "0011",
               4 when "0100",
               5 when "0101",
               6 when "0110",
               7 when "0111",
               8 when "1000",
               9 when "1001",
               10 when "1010",
               11 when "1011",
               12 when "1100",
               13 when "1101",
               14 when "1110",
               15 when others;
               
  -- read select data is current indexed set
	rdat0  <=	set0(pick);
	rdat1  <=	set1(pick);
	
	
	dirty_out <= dirty(pick);
	valid_out <= valid(pick);
	tag_dump <= tags(pick);
	
	rdat <= rdat0 when set = '0' else rdat1;
	
	-- hit when tag match
	hit <= '1' when (tags(pick)=tag) and (valid(pick)='1') else
	       '0';
	       
	snoopData <= set0(snoopPick) when int_snoopHit = '1' and snoopAddr(2) = '0' else
	             set1(snoopPick) when int_snoopHit = '1' and snoopAddr(2) = '1' else (others => '1');

  int_snoopHit <= '0' when valid(snoopPick) = '0' else
              '1' when (tags(snoopPick) = snoopAddr(31 downto 7)) else
              '0';
  snoopHit <= int_snoopHit;
  
end dram_array_arch;

