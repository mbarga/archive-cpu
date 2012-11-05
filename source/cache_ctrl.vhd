-- MODULE: cache_ctrl; OWNER: mbarga

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cache_ctrl IS
  PORT
  (
    request : in STD_LOGIC_VECTOR (31 DOWNTO 0);  -- requested data on cache miss
    hit     : in std_logic;                       -- hit/nmiss signal
    newBlock: out std_logic_vector (31 downto 0); -- block to be loaded to cache from memory
    pcwait  : out std_logic;                     
    iread   : out std_logic;
    
    -- ram_interface/mem_control signals
    pc        : out std_logic_vector (15 DOWNTO 0);  -- ties to 'pc' of memctrl
    ins       : in std_logic_vector(31 downto 0);    -- instruction retrieved from memctrl
    
    clk		     : IN STD_LOGIC;
    nrst      : in std_logic
  );

END cache_ctrl;


ARCHITECTURE ctrl_arch OF cache_ctrl IS
  
  type state_type is (IDLE, FETCH, WRITE);
  signal   state, nextState : state_type;
  
BEGIN

  define_outputs : process (state, hit)
  begin
    case state is
      when IDLE =>
        if (hit='0') then
          nextState <= FETCH;
        else
          nextState <= IDLE;
        end if;
      when FETCH =>
        if (hit='1') then -- wait for instruction to become available
          nextState <= IDLE;
        else
          nextState <= FETCH;
        end if;
      --when WRITE =>
        --if (hit='1') then -- confirm we get a hit from the interface
         -- nextState <= IDLE;  
        --else
         -- nextState <= WRITE;
        --end if; 
      when others =>
        nextState <= IDLE;
    end case;
  end process; 
  
  newBlock  <= ins;
  pc        <= request(15 downto 0);
  pcwait     <= '1' when (hit='0') else '0';
  iread     <= '1' when nextState=FETCH or state=FETCH else '0';
 
  clk_process : process (clk, nrst) 
  begin
    if (nrst = '0') then
      state <= idle;
    elsif (clk = '1' AND clk'event) then
      state <= nextState;
    end if; 
  end process;

END ctrl_arch;


