library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 

entity VarLatRAM is
        port
        (
                nReset          : in std_logic ;
                clock           : in std_logic ;
                address         : in std_logic_vector (15 DOWNTO 0);
                data            : in std_logic_vector (31 DOWNTO 0);
                wren            : in std_logic ;
                rden            : in std_logic ;
                latency_override: in std_logic ; 
                q               : out std_logic_vector (31 DOWNTO 0);
                memstate        : out std_logic_vector (1 DOWNTO 0)
        );
end VarLatRAM;

architecture VarLatRAM_arch of VarLatRAM is

        component ram
        PORT
        (
                address         : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                clock           : IN STD_LOGIC ;
                data            : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                wren            : IN STD_LOGIC ;
                q               : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
        end component;

        -- you can change this for testing purpose to make sure your pipeline can handle flexible latency.
        -- when latency is 5, the counter counts 1 to 5 then hits access state, access state itself takes one cycle,
        -- therefore, the memory operation will actually take LATENCY + 1 cycle to complete before next operation starts. 
        -- if LATENCY is set to 0, then there will be no busy state and counter will not count, 
        -- it will go straight to access state and takes only one cycle to access the memory like lab4. 
        -- also keep in mind that LATENCY conunter is 8 bits, do not change to some number beyond, like a million. :)
        constant LATENCY        : std_logic_vector              := x"00";

        -- when memory is in free or busy or error or reset state, this is the temperay output and also dummy output.
        -- only when memory hits done state, then your read or write will be completed. you can change this as well. 
        constant BAD1BAD1       : std_logic_vector              := x"BAD1BAD1";

        -- MEMFREE : when read enable (rden) or write enable (wren) are both '0', then memory is free to use
        -- MEMBUSY : when either read enable (rden) or write enable (wren) is '1', then memory enters busy state to provide latency. 
        -- MEMACCESS: memory hits access state when counter reaches LATENCY, then your read or write opreation should be completed, 
        --              access state will only last for one cycle, you should use this cycle to access ram with your read or write.
        -- MEMERROR: when read enable (rden) or write enable (wren) are both '1', then memory encounters error until flags changes.
        --              state changes are happening on falling edge of clock just like ram.vhd and your memories in lab4.
        constant MEMFREE        : std_logic_vector              := "00";
        constant MEMBUSY        : std_logic_vector              := "01";
        constant MEMACCESS      : std_logic_vector              := "10";
        constant MEMERROR       : std_logic_vector              := "11";

        -- for internal read or write control state and counter initialization.
        constant READ           : std_logic                     := '0';
        constant WRITE          : std_logic                     := '1';
        constant ZEROS          : std_logic_vector              := x"08";

        -- internal write enable, used as wrapper signals to ram.vhd
        signal write_en         : std_logic;
        signal data_out         : std_logic_vector (31 downto 0);

        -- internal count and nextcount signal in latency counter. 8 bits counter.
        signal count,nextcount  : std_logic_vector (7 downto 0);

begin
        SYNRAM : ram port map ( address, clock, data, write_en, data_out );

  registers: process(nReset, clock)
  begin
    if nReset = '0' then
      count <= ZEROS;
    elsif falling_edge(clock) then
      count <= nextcount;
    end if;
  end process;

  counter: process(count,clock,wren,rden,latency_override)
  begin 
    nextcount <= ZEROS; --default count value

    if (wren /= rden) and count /= LATENCY and latency_override = '0' then
        nextcount <= count + 1;
    end if;
  end process;

  memstateout: process(wren,rden,count,latency_override)
  begin

    if LATENCY /= x"0" and latency_override = '0' then

      if (wren /= rden) and (count = LATENCY) then 
        memstate <= MEMACCESS;
      elsif (wren /= rden) then
        memstate <= MEMBUSY;
      elsif (wren = '1') and (rden = '1') then
        memstate <= MEMERROR;
      else --no read or write in progress
        memstate <= MEMFREE;
      end if;

   else -- latency is 0

      if (wren /= rden) then 
        memstate <= MEMACCESS;
      elsif (wren = '1') and (rden = '1') then
        memstate <= MEMERROR;
      else --no read or write in progress
        memstate <= MEMFREE;
      end if;

    end if;
  end process;

  -- data only available to read when latency reached during read operation
  q <= data_out when (wren = '0' and rden = '1' and (LATENCY = count or LATENCY = x"0" or latency_override = '1') ) else
        BAD1BAD1;
  write_en <= WRITE when (wren = '1' and rden = '0' and (LATENCY = count or LATENCY = x"0" or latency_override = '1') ) else
        READ;

end VarLatRAM_arch;

