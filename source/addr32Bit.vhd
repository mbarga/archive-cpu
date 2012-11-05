-- 32 bit adder
-- agreyes

library ieee;
use ieee.std_logic_1164.all;

entity addr32Bit is
	port
	(
		-- 32 Bit operands
		A,B : in std_logic_vector(31 downto 0);
		-- Carry in bit
		Cin : in std_logic;
		-- Sum bit
		Sout : out std_logic_vector(31 downto 0);
		-- Carry out bit
		OVERFLOW : out std_logic
		);
end addr32Bit;

architecture addr32Bit_arch of addr32Bit is
  component addr1Bit is
    port
    (
      -- 1 Bit operands
      A,B : in std_logic;
      -- Carry in bit
      Cin : in std_logic;
      -- Sum bit
      S : out std_logic;
      -- Carry out bit
      Cout : out std_logic
      );
  end component;
  
  signal carrys : std_logic_vector(31 downto 0);
  signal S : std_logic_vector(31 downto 0);
  
begin

	I00: addr1Bit port map (A(0), B(0), Cin, S(0), carrys(0));
	I01: addr1Bit port map (A(1), B(1), carrys(0), S(1), carrys(1)); 
	I02: addr1Bit port map (A(2), B(2), carrys(1), S(2), carrys(2)); 
	I03: addr1Bit port map (A(3), B(3), carrys(2), S(3), carrys(3));
	I04: addr1Bit port map (A(4), B(4), carrys(3), S(4), carrys(4)); 
	I05: addr1Bit port map (A(5), B(5), carrys(4), S(5), carrys(5)); 
	I06: addr1Bit port map (A(6), B(6), carrys(5), S(6), carrys(6)); 
	I07: addr1Bit port map (A(7), B(7), carrys(6), S(7), carrys(7)); 
	I08: addr1Bit port map (A(8), B(8), carrys(7), S(8), carrys(8)); 
	I09: addr1Bit port map (A(9), B(9), carrys(8), S(9), carrys(9)); 
	I10: addr1Bit port map (A(10), B(10), carrys(9), S(10), carrys(10));  
	I11: addr1Bit port map (A(11), B(11), carrys(10), S(11), carrys(11));		
	I12: addr1Bit port map (A(12), B(12), carrys(11), S(12), carrys(12));
	I13: addr1Bit port map (A(13), B(13), carrys(12), S(13), carrys(13));
	I14: addr1Bit port map (A(14), B(14), carrys(13), S(14), carrys(14));
	I15: addr1Bit port map (A(15), B(15), carrys(14), S(15), carrys(15));
	I16: addr1Bit port map (A(16), B(16), carrys(15), S(16), carrys(16));
	I17: addr1Bit port map (A(17), B(17), carrys(16), S(17), carrys(17));
	I18: addr1Bit port map (A(18), B(18), carrys(17), S(18), carrys(18));
	I19: addr1Bit port map (A(19), B(19), carrys(18), S(19), carrys(19));
	I20: addr1Bit port map (A(20), B(20), carrys(19), S(20), carrys(20));
	I21: addr1Bit port map (A(21), B(21), carrys(20), S(21), carrys(21));
	I22: addr1Bit port map (A(22), B(22), carrys(21), S(22), carrys(22));
	I23: addr1Bit port map (A(23), B(23), carrys(22), S(23), carrys(23));
	I24: addr1Bit port map (A(24), B(24), carrys(23), S(24), carrys(24));
	I25: addr1Bit port map (A(25), B(25), carrys(24), S(25), carrys(25));
	I26: addr1Bit port map (A(26), B(26), carrys(25), S(26), carrys(26));
	I27: addr1Bit port map (A(27), B(27), carrys(26), S(27), carrys(27));
	I28: addr1Bit port map (A(28), B(28), carrys(27), S(28), carrys(28));
	I29: addr1Bit port map (A(29), B(29), carrys(28), S(29), carrys(29));
	I30: addr1Bit port map (A(30), B(30), carrys(29), S(30), carrys(30));
	I31: addr1Bit port map (A(31), B(31), carrys(30), S(31), carrys(31)); 
	
	Sout <= S;
	OVERFLOW <= carrys(31) xor carrys(30); 
end addr32Bit_arch;
