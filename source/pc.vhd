-- 32 bit program counter
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity pc is
	port
	(
		-- input port
		D		:	in	std_logic_vector (31 downto 0);
		-- if(halt == 1) pc <= I; else pc <= pc;
		halt			:	in	std_logic;
		rstAddr : in std_logic_vector(31 downto 0); 
		-- clock, positive edge triggered
		clk			:	in	std_logic;
		-- REMEMBER: nReset-> '0' = RESET, '1' = RUN
		nRst	:	in	std_logic;
		-- output
		output		:	out	std_logic_vector (31 downto 0)
		);
end pc;

architecture pc_arch of pc is
	signal Q	:	std_logic_vector(31 downto 0);				-- register
begin

	-- register process
	reg: process (clk, nRst, halt, rstAddr)
  begin
    -- one register if statement
		if (nRst = '0') then
			-- Reset here
		  Q <= rstAddr;
    elsif (rising_edge(clk) and halt = '0') then
			-- Set register here
			Q <= D;
    end if;
  end process;
  
  output <= Q;

end pc_arch;
