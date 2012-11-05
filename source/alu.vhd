-- 32 bit arithmetic logic unit
-- agreyes

library ieee;
use ieee.std_logic_1164.all;

entity alu is
	port
	(
		opcode		:	in	std_logic_vector (2 downto 0);
		-- Operands
		A,B		:	in	std_logic_vector (31 downto 0);
		-- Write Enable for entire register file
		output			:	out	std_logic_vector (31 downto 0);
		-- flags
		negative, overflow, zero			:	out	std_logic
		);
end alu;

architecture alu_arch of alu is

  component addr32Bit is
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
end component;

	constant OP_SLL	:	std_logic_vector		:= "000";
	constant OP_SRL	:	std_logic_vector		:= "001";
	constant OP_ADD	:	std_logic_vector		:= "010";
	constant OP_SUB	:	std_logic_vector		:= "011";
	constant OP_AND	:	std_logic_vector		:= "100";
	constant OP_NOR	:	std_logic_vector		:= "101";
	constant OP_OR	:	std_logic_vector		:= "110";
	constant OP_XOR	:	std_logic_vector		:= "111";
	
  signal and_out : std_logic_vector(31 downto 0);
  signal nor_out : std_logic_vector(31 downto 0);
  signal or_out : std_logic_vector(31 downto 0);
  signal xor_out : std_logic_vector(31 downto 0);
  
  signal add_out : std_logic_vector(31 downto 0);
  signal Cin : std_logic;
  signal Cout : std_logic;
  
  signal Cin31 : std_logic;
  
  signal WL : std_logic_vector(31 downto 0);
  signal XL : std_logic_vector(31 downto 0);
  signal YL : std_logic_vector(31 downto 0);
  signal ZL : std_logic_vector(31 downto 0);
  signal sll_out : std_logic_vector(31 downto 0);
  
  signal WR : std_logic_vector(31 downto 0);
  signal XR : std_logic_vector(31 downto 0);
  signal YR : std_logic_vector(31 downto 0);
  signal ZR : std_logic_vector(31 downto 0);
  signal srl_out : std_logic_vector(31 downto 0);
  
  signal Bin : std_logic_vector(31 downto 0);
  
  signal O : std_logic_vector(31 downto 0);

begin
  
  --sll
  with B(0) select
    WL <= A(30 downto 0) & "0" when '1',
          A(31 downto 0) when others;
  with B(1) select
    XL <= WL(29 downto 0) & "00" when '1',
          WL(31 downto 0) when others;
  with B(2) select
    YL <= XL(27 downto 0) & "0000" when '1',
          XL(31 downto 0) when others;
  with B(3) select
    ZL <= YL(23 downto 0) & "00000000" when '1',
          YL(31 downto 0) when others;
  with B(4) select
    sll_out <= ZL(15 downto 0) & "0000000000000000" when '1',
          ZL(31 downto 0) when others;
  
  --srl
  with B(0) select
      WR <= "0" & A(31 downto 1) when '1',
            A(31 downto 0) when others;
    with B(1) select
      XR <= "00" & WR(31 downto 2) when '1',
            WR(31 downto 0) when others;
    with B(2) select
      YR <= "0000" & XR(31 downto 4) when '1',
            XR(31 downto 0) when others;
    with B(3) select
      ZR <= "00000000" & YR(31 downto 8) when '1',
            YR(31 downto 0) when others;
    with B(4) select
      srl_out <= "0000000000000000" & ZR(31 downto 16) when '1',
            ZR(31 downto 0) when others;
  
  -- and
  and_out <= A and B;
  
  -- xor
  xor_out <= A xor B;
  
  -- nor
  nor_out <= A nor B;
  
  -- or
  or_out <= A or B;
  
  with opcode select
    Bin <= not B when OP_SUB,
           B when others;
  
  -- add and sub
  Cin <= (not opcode(2)) and opcode(1) and opcode(0);
  
  I00: addr32Bit port map (A, Bin, Cin, add_out, Cout);
  
  -- negative flag
  negative <= O(31);
  
  -- zero flag
  zero <= not(O(0) or
          O(1) or
          O(2) or
          O(3) or
          O(4) or
          O(5) or
          O(6) or
          O(7) or
          O(8) or
          O(9) or
          O(10) or
          O(11) or
          O(12) or
          O(13) or
          O(14) or
          O(15) or
          O(16) or
          O(17) or
          O(18) or
          O(19) or
          O(20) or
          O(21) or
          O(22) or
          O(23) or
          O(24) or
          O(25) or
          O(26) or
          O(27) or
          O(28) or
          O(29) or
          O(30) or
          O(31));
   
  -- overflow flag
  with opcode select
    overflow <= Cout when OP_ADD,
                Cout when OP_SUB,
                '0' when others;
              
  
  output <= O;        
	-- output select:
	with opcode select
		O <= sll_out when OP_SLL,
		srl_out when OP_SRL,
		add_out when OP_ADD,
		add_out when OP_SUB,
		and_out when OP_AND,
		nor_out when OP_NOR,
		or_out when OP_OR,
		xor_out when OP_XOR,
		x"00000000" when others;

end alu_arch;
