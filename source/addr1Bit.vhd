-- 1 bit adder
-- agreyes

library ieee;
use ieee.std_logic_1164.all;

entity addr1Bit is
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
end addr1Bit;

architecture addr1Bit_arch of addr1Bit is
begin

	S <= Cin xor (A xor B);
	Cout <= (not Cin and B and A) or (Cin and (B or A));
			
end addr1Bit_arch;
