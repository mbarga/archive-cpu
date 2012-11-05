-- data array for icache; OWNER: mbarga

library ieee;
use ieee.std_logic_1164.all;

entity data_array is
  port
  ( wdat		:	in	std_logic_vector (31 downto 0);    -- new block data
    dataready			:	in	std_logic;                         -- write enable
    
    rsel		:	in	std_logic_vector (31 downto 0);    -- block select port
    rdat		:	out	std_logic_vector (31 downto 0);   -- read data out port
    hit   : out std_logic;
    
    
   
    clk			:	in	std_logic;
    nrst	 :	in	std_logic
    );
end data_array;

architecture data_arch of data_array is

  --- [31-6]:cache tag [5-2]:cache index, [1-0]:byte select ---
  
  constant BAD	:	std_logic_vector		:= x"BAD1BAD1";

  type SET16 is array (0 to 15) of std_logic_vector(31 downto 0);
  type TAG16 is array (0 to 15) of std_logic_vector(26 downto 0); -- 1 bid valid + 26 bit tag
  signal set	:	SET16;				-- set array
  signal tag : TAG16;    -- tag data array
  
  signal currentTag : std_logic_vector(26 downto 0);  -- clip of tag on input query address
  signal pick       : integer range 0 to 15;
  signal index      : std_logic_vector(3 downto 0);
  
begin
  
  currentTag <= '1'&rsel(31 downto 6); -- set valid bit of input query to '1' for check against stored tag
  index      <= rsel(5 downto 2);
  
  sets : process (clk, nrst, dataready)
  begin

    if (nrst = '0') then
      -- on reset, set all valid bits to FALSE
      for i in 15 downto 0 loop
        tag(i) <= "000"&x"000000";
      end loop;
      
    elsif (rising_edge(clk)) then
      -- if write enable set, then write ram data to indexed set
      if (dataready = '1') then
        set(pick) <= wdat;
        tag(pick) <= currentTag; -- inherently sets valid bit to TRUE
      end if;
     
    end if;
    
  end process;

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
               --16 when others; -- index error
               
  -- read select data is current indexed set
	rdat  <=	set(pick);
	-- hit when tag match
  hit   <= '1' when tag(pick)=currentTag else '0';  

end data_arch;

