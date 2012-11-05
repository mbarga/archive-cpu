-- 16Bit Extend un/signed
-- agreyes

library ieee;
use ieee.std_logic_1164.all;

entity ext16Bit is
        port
        (
                signed		:	in	std_logic;
                -- Select
                I		:	in	std_logic_vector (15 downto 0);
                -- Inputs
                output			:	out	std_logic_vector (31 downto 0)
                -- Output
         );
end ext16Bit;

architecture ext16Bit_arch of ext16Bit is
  signal extend : std_logic;
begin
  
  with signed select
    extend <= '0' when '0',
              I(15) when others;
              
  with extend select
    output <= "0000000000000000" & I when '0',
              "1111111111111111" & I when others;
end ext16Bit_arch;

