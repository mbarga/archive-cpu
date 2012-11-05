-- fowarding operand mux (3 input)

library ieee;
use ieee.std_logic_1164.all;

entity fwdOpMux is
	port
	( -- 2-bit select
		sel		     :	in	std_logic_vector(1 downto 0);
    -- Inputs
		I0,I1,I2		:	in	std_logic_vector (31 downto 0);
    -- Output
		output			 :	out	std_logic_vector (31 downto 0)
	);
end fwdOpMux;

architecture mux_arch of fwdOpMux is
begin
  
  with sel select
    output <= I1 when "01",
              I2 when "10",
              I0 when others;
          
end mux_arch;
