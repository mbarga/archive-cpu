library ieee;
use ieee.std_logic_1164.all;

-- do not change this entity
-- yes the signal lengths are correct
entity mem_arb is
        port ( 
          -- processor 0
          mem_pc_in0  : in std_logic_vector(31 downto 0);
          iread_in0   : in std_logic;
          
          memins_out0 : out std_logic_vector(31 downto 0);
          datareadyout0 : out std_logic;

          -- processor 1
          mem_pc_in1  : in std_logic_vector(31 downto 0);
          iread_in1   : in std_logic;
          
          memins_out1 : out std_logic_vector(31 downto 0);
          datareadyout1 : out std_logic;
          
          -- mem signals
          memState   : in std_logic_vector(1 downto 0);
          memQ       : in std_logic_vector(31 downto 0);
          memRden    : out std_logic;
          memWren    : out std_logic;
          memData    : out std_logic_vector(31 downto 0);
          memAddr    : out std_logic_vector(31 downto 0);
          
          -- to coherency ctrl
          coh_ctrlin : in std_logic;
          coh_ctrlout: out std_logic
        );
end mem_arb;

architecture behavioral of mem_arb is


begin


end behavioral;