-- 32 bit multiplexer
-- agreyes

library ieee;
use ieee.std_logic_1164.all;

entity mux32 is
	port
	(
		sel		:	in	std_logic;
		-- Select
		I0,I1		:	in	std_logic_vector (31 downto 0);
		-- Inputs
		output			:	out	std_logic_vector (31 downto 0)
		-- Output
		);
end mux32;

architecture mux_arch of mux32 is
begin
  with sel select
    output <= I0 when '0',
          I1 when others;
end mux_arch;
