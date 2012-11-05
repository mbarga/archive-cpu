-- MODULE: dram_ctrl; OWNER: agreyes

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY dram_ctrl IS
  PORT
  (
  
    -- LL SC Link Register
    sc : in std_logic;
    ll : in std_logic;
    sc_result : out std_logic;
    invalid_addr : in std_logic_vector(31 downto 0);
    invalidate : in std_logic;
    
    -- data_array interface
    dirty0 : in std_logic;
    dirty1 : in std_logic;
    valid0 : in std_logic;
    valid1 : in std_logic;
    wdat		 :	out	std_logic_vector (31 downto 0);    -- write data
    rdat0		:	in	std_logic_vector (31 downto 0);   -- read data in port0
    rdat1		:	in	std_logic_vector (31 downto 0);   -- read data in port0
    tag_dump0 : in std_logic_vector(24 downto 0);
    tag_dump1 : in std_logic_vector(24 downto 0);
    index : out std_logic_vector(3 downto 0);
    clean0 : out std_logic;
    wen0			:	out	std_logic;  
    clean1 : out std_logic;
    wen1			  :	out	std_logic; 
    word_sel : out std_logic;
    
    dirtyOut : out std_logic;
    validOut : out std_logic;
    
    dump : in std_logic;
    dump_complete : out std_logic;
    
    hit0 : in std_logic;
    hit1 : in std_logic;
    
    -- cpu interface
    dwait : out std_logic;
    cpu_rdata : out std_logic_vector(31 downto 0);
    
    cpu_addr : in std_logic_vector(31 downto 0);
    cpu_wdata : in std_logic_vector(31 downto 0);
    cpu_ren : in std_logic;
    cpu_wen : in std_logic;
    
    -- memCtrl interface
    mem_addr : out STD_LOGIC_VECTOR (31 DOWNTO 0);  -- requested data on cache miss
    mem_wdat : out std_logic_vector (31 downto 0);                     -- hit/nmiss signal
    mem_wen  : out std_logic;                     -- write enable for cache data array
    mem_ren : out std_logic;
    
    mem_rdat : in std_logic_vector (31 downto 0); -- block to be loaded to cache from memory
    dready : in std_logic;
    
    writeAction : out std_logic;
    writeAddr : out std_logic_vector(31 downto 0);
    
    clk			:	in	std_logic;
    nrst	 :	in	std_logic
  );

END dram_ctrl;


ARCHITECTURE dram_ctrl_arch OF dram_ctrl IS
  
  type state_type is (IDLE, FETCH0, FETCH1, WRITE0, WRITE1, DUMP0, DUMP1, HALT);
  signal state, nextState : state_type;
  signal int_word_sel : std_logic;
  signal way_sel : std_logic;
  signal hit : std_logic;
  signal pick       : integer range 0 to 15;
  --signal cache_wen : std_logic;
  signal cache_clean : std_logic;
  signal dirty : std_logic;
  signal tag_dump : std_logic_vector(24 downto 0);
  
  type INT16 is array (0 to 15) of std_logic;
  signal lru : INT16;    -- tag data array
  signal dump_cnt : std_logic_vector(3 downto 0);
  signal ndump_cnt : std_logic_vector(3 downto 0);
  signal dump_inc : std_logic;
  signal dump_pick : integer range 0 to 15;
  signal dump_word : std_logic;
  signal ndump_word : std_logic;
  signal tag : std_logic_vector(24 downto 0);
  signal int_index : std_logic_vector(3 downto 0);
  signal next_dump : std_logic;
  
  signal int_dwait: std_logic;
  
  signal linkReg : std_logic_vector(31 downto 0);
  signal n_linkReg : std_logic_vector(31 downto 0);
  signal validLink : std_logic;
  signal n_validLink : std_logic;
  
  signal invalidSC : std_logic;
  signal sc_result_int: std_logic;
  
BEGIN
  
  writeAddr <= cpu_addr;
  
  dirty <= dirty0 or dirty1;
  hit <= hit0 or hit1;
  
  tag_dump <= tag_dump0 when state = DUMP0 else 
              tag_dump1 when state = DUMP1 else
              tag_dump0 when way_sel = '0' else tag_dump1;
  
  way_sel <= lru(pick);
  
  nextstate_logic : process (state, hit, dirty, dready, dump_cnt, dump_inc, cpu_ren, cpu_wen, dump, valid0, valid1, dirty0, dirty1)
  begin
    case state is
      when IDLE =>  
        if(dump = '1') then
          nextState <= DUMP0; 
        elsif (hit = '0' and (cpu_ren = '1' or cpu_wen = '1')) then
          if((way_sel = '0' and dirty0 = '1' and valid0 = '1') or (way_sel = '1' and dirty1 = '1' and valid1 = '1')) then
            nextState <= WRITE0;
          else
            nextState <= FETCH0;
          end if;
        else
          nextState <= IDLE;
        end if;
        
      when FETCH0 =>
        if (dready='1') then -- wait for instruction to become available
          nextState <= FETCH1;
        else
          nextState <= FETCH0;
        end if;
        
      when FETCH1 =>                   
        if (dready='1') then -- wait for instruction to become available
          nextState <= IDLE;
        else
          nextState <= FETCH1;
        end if;    
            
      when WRITE0 =>                  
        if(dready = '1') then
          nextState <= WRITE1;
        else
          nextState <= WRITE0;
        end if;
        
      when WRITE1 =>    
        if(dready = '1') then
          nextState <= FETCH0;
        else
          nextState <= WRITE1;
        end if;
      
      when DUMP0 =>
        if(dump_cnt = "1111" and dump_inc = '1') then
          nextState <= DUMP1;
        else
          nextState <= DUMP0;
        end if;
      when DUMP1 =>
        if(dump_cnt = "1111" and dump_inc = '1') then
          nextState <= HALT;
        else
          nextState <= DUMP1;
        end if;
      when HALT =>
        nextState <= HALT;
    end case;
  end process; 
  
  link_process : process(clk, nrst, n_validLink, n_linkReg)
    begin
      if (nrst = '0') then
        linkReg <= (others => '0');
        validLink <= '0';
      elsif (clk = '1' AND clk'event) then
          validLink <= n_validLink;
          linkReg <= n_linkReg;
      end if;
    end process;
  
  n_validLink <= '1' when ll = '1' else
                 '0' when invalidSC = '1' or (linkReg = cpu_addr and sc = '1' and int_dwait = '0') else
                 validLink;
                 
  invalidSC <= '1' when linkReg = invalid_addr and invalidate = '1' else '0';
  
  sc_result_int <= '1' when validLink = '1' and linkReg = cpu_addr and sc = '1' and int_dwait = '0' and invalidSC = '0' else '0'; 
  sc_result <= sc_result_int;
                  
  n_linkReg <= cpu_addr when ll = '1' else linkReg;
  
  dump_cnt_process : process(clk, nrst, dump_inc, ndump_cnt, ndump_word)
  begin
    if (nrst = '0') then
      dump_cnt <= (others => '0');
      dump_word <= '0';
    elsif (clk = '1' AND clk'event) then
        dump_word <= ndump_word;
      if(dump_inc = '1') then
        dump_cnt <= ndump_cnt;
      end if;
    end if;
  end process;
  
  with dump_cnt select
        ndump_cnt <= "0001" when "0000", 
                    "0010" when "0001",
                    "0011" when "0010",
                    "0100" when "0011",
                    "0101" when "0100",
                    "0110" when "0101",
                   "0111" when "0110",
                   "1000" when "0111",
                   "1001" when "1000",
                   "1010" when "1001",
                   "1011" when "1010",
                   "1100" when "1011",
                   "1101" when "1100",
                   "1110" when "1101",
                  "1111" when "1110",
                  "0000" when others;
                  
  ndump_word <= not dump_word when (dready = '1' and (state = DUMP0 or state = DUMP1)) else dump_word;
                
  dump_inc <= (dready and dump_word) or (not valid0) when state = DUMP0 else 
             (dready and dump_word) or (not valid1) when state = DUMP1 else '0';
 
  clk_process : process (clk, nrst, hit, pick, hit1, nextstate) 
  begin
    if (nrst = '0') then
      state <= IDLE;
      lru <= (others => '0');
    elsif (clk = '1' AND clk'event) then
      state <= nextState;
      if(hit = '1') then
        lru(pick) <= hit0;
      end if;
    end if; 
  end process;
  
  cpu_rdata <= rdat0 when hit0 = '1' else
               rdat1 when hit1 = '1' else (others => '1');
               
  mem_wdat <= rdat0 when state = DUMP0 else
              rdat1 when state = DUMP1 else
              rdat0 when way_sel = '0' else
              rdat1 when way_sel = '1' else (others => '0');
              
  wdat <= cpu_wdata when state = IDLE else mem_rdat;
  
  mem_addr <= tag & int_index & int_word_sel & "00";
  
  --tag <= tag_dump when state = DUMP0 or state = DUMP1 else 
  --     cpu_addr(31 downto 7) when state = FETCH0 or state = FETCH1 else
  --      tag_dump when state = WRITE0 or state = WRITE1 else (others => '1');
        
  tag <= tag_dump when state /= FETCH0 and state /= FETCH1 else 
        cpu_addr(31 downto 7);
  
  int_index <= dump_cnt when state = DUMP0 or state = DUMP1 else
           cpu_addr(6 downto 3);
           
  index <= int_index;
  
  writeAction <= hit when cpu_wen = '1' and state = IDLE else '0';
  
  int_dwait <= (not hit) when ((cpu_ren = '1' or cpu_wen = '1') and state = IDLE) else 
           '0' when state = IDLE or state = HALT else '1';
  
  int_word_sel <=  dump_word when state = DUMP0 or state = DUMP1 else
                  cpu_addr(2) when state=IDLE else
                  '0' when state=WRITE0 or state=FETCH0 else
                  '1' when state=WRITE1 or state=FETCH1 else '0';
  
  --cache_wen	<= dready when state=FETCH0 or state=FETCH1 else 
  --            cpu_wen and hit when state=IDLE;
  
  wen0 <= hit0 and ((sc and sc_result_int) or (not(sc))) when cpu_wen = '1' and state = IDLE  else
          dready when way_sel = '0' and (state=FETCH0 or state=FETCH1)  else 
          '0';
          
  wen1 <= hit1 and ((sc and sc_result_int) or (not(sc))) when cpu_wen = '1' and state = IDLE else           
          dready when way_sel = '1' and (state=FETCH0 or state=FETCH1)  else 
          '0';
  
  cache_clean <= dready when state=FETCH1 or state=WRITE1 else '0';
  
  --cache_clean <= dready when state=WRITE1 else '0';
  
  --wen0 <= (not way_sel) and cache_wen;
  --wen1 <= way_sel and cache_wen;
  
  clean0 <= '1' when way_sel = '0' and cache_clean = '1' else '0';
  clean1 <= '1' when way_sel = '1' and cache_clean = '1' else '0';
  
  mem_wen <=  valid0 when state = DUMP0 else
              valid1 when state = DUMP1 else
              '1' when state = WRITE0 or state = WRITE1 else '0';
  
  mem_ren <= '1' when state = FETCH0 or state = FETCH1 else '0';
  
  word_sel <= int_word_sel;
  
  with cpu_addr(6 downto 3) select
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
                 
  dump_complete <= '1' when state = HALT else '0';
  
  dirtyOut <= dirty0 when hit0 = '1' else
              dirty1 when hit1 = '1' else '0';
              
  dwait <= int_dwait;
              
  validOut <= valid0 when hit0 = '1' else
              valid1 when hit1 = '1' else
              '0';

END dram_ctrl_arch;


