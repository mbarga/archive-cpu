-- 5 bit multiplexer
-- agreyes

library ieee;
use ieee.std_logic_1164.all;

entity mux5 is
	port
	(
		sel		:	in	std_logic;
		-- Select
		I0,I1		:	in	std_logic_vector (4 downto 0);
		-- Inputs
		output			:	out	std_logic_vector (4 downto 0)
		-- Output
		);
end mux5;

architecture mux_arch of mux5 is
begin
  with sel select
    output <= I0 when '0',
          I1 when others;
end mux_arch;
