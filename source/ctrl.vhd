-- controller file
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity ctrl is
	port
	(
		
		ins : in std_logic_vector(31 downto 0);
		
		aluop		:	out	std_logic_vector (2 downto 0);
		-- read port 2
		ImmWrite		:	out	std_logic;
		Jump		:	out	std_logic;
		Link		:	out	std_logic;
		BEQ		:	out	std_logic;
		BNE : out std_logic;
		SLT : out std_logic;
		MemToReg		:	out	std_logic;
		MemWrite		:	out	std_logic;
		RegWrite		:	out	std_logic;
		AluSrc		:	out	std_logic;
		RegJump : out std_logic;
		RegSel		:	out	std_logic;
		SignExt		:	out	std_logic;
		ALUSrcShamt : out std_logic;
		LL      : out std_logic;
		SC      : out std_logic
		);
end ctrl;

architecture ctrl_arch of ctrl is

  constant ALU_SLL	:	std_logic_vector		:= "000";
  constant ALU_SRL	:	std_logic_vector		:= "001";
  constant ALU_ADD	:	std_logic_vector		:= "010";
  constant ALU_SUB	:	std_logic_vector		:= "011";
  constant ALU_AND	:	std_logic_vector		:= "100";
  constant ALU_NOR	:	std_logic_vector		:= "101";
  constant ALU_OR	:	std_logic_vector		:= "110";
  constant ALU_XOR	:	std_logic_vector		:= "111";
  
  constant op_addu	:	std_logic_vector		:= "100001";
  constant op_and	:	std_logic_vector		:= "100100";
  constant op_jr	:	std_logic_vector		:= "001000";
  constant op_nor	:	std_logic_vector		:= "100111";
  constant op_or	:	std_logic_vector		:= "100101";
  constant op_sll	:	std_logic_vector		:= "000000";
  constant op_slt	:	std_logic_vector		:= "101010";
  constant op_sltu	:	std_logic_vector		:= "101011";
  constant op_srl	:	std_logic_vector		:= "000010";
  constant op_subu	:	std_logic_vector		:= "100011";
  constant op_xor	:	std_logic_vector		:= "100110";
  
  constant op_addiu	:	std_logic_vector		:= "001001";
  constant op_andi	:	std_logic_vector		:= "001100";
  constant op_beq	:	std_logic_vector		:= "000100";
  constant op_bne	:	std_logic_vector		:= "000101";
  constant op_lui	:	std_logic_vector		:= "001111";
  constant op_lw	:	std_logic_vector		:= "100011";
  constant op_ori	:	std_logic_vector		:= "001101";
  constant op_slti	:	std_logic_vector		:= "001010";
  constant op_sltiu	:	std_logic_vector		:= "001011";
  constant op_sw	:	std_logic_vector		:= "101011";
  constant op_xori	:	std_logic_vector		:= "001110";
  constant op_ll  : std_logic_vector := "110000";
  constant op_sc : std_logic_vector :=  "111000";
  
  constant op_j	:	std_logic_vector		:= "000010";
  constant op_jal :	std_logic_vector		:= "000011";
  
  signal r_addu	:	std_logic;
  signal r_and	:	std_logic;
  signal r_jr	:	std_logic;
  signal r_nor	:	std_logic;
  signal r_or	:	std_logic;
  signal r_sll	:	std_logic;
  signal r_slt	:	std_logic;
  signal r_sltu	:	std_logic;
  signal r_srl	:	std_logic;
  signal r_subu	:	std_logic;
  signal r_xor	:	std_logic;
  
  signal i_addiu	:	std_logic;
  signal i_andi	:	std_logic;
  signal i_beq	:	std_logic;
  signal i_bne	:	std_logic;
  signal i_lui	:	std_logic;
  signal i_lw	:	std_logic;
  signal i_ori	:	std_logic;
  signal i_slti	:	std_logic;
  signal i_sltiu	:	std_logic;
  signal i_sw	:	std_logic;
  signal i_xori	:	std_logic;
  signal i_ll   : std_logic;
  signal i_sc   : std_logic;
  
  signal o_j	:	std_logic;
  signal o_jal	:	std_logic;
  
  
  signal opcode		:	std_logic_vector (5 downto 0);
  
  signal funct		:	std_logic_vector (5 downto 0);
  
	signal RTYPE	:	std_logic;
	
begin
  
  opcode <= ins(31 downto 26);
  funct <= ins(5 downto 0);
  
  --accept <= r_addu or r_and or r_jr or r_nor or r_or or r_sll or r_slt or r_sltu or r_srl or r_subu or r_xor or i_addiu or i_andi or i_beq or i_bne or i_lui or i_lw or i_ori or i_slti or i_sltiu or i_sw or i_xori or o_j or o_jal;

  
	RTYPE <= '1' when opcode = "000000" else '0';
	
	r_addu <= RTYPE when (funct = op_addu) else '0';
	r_and <= RTYPE when (funct = op_and) else '0';
	r_jr <= RTYPE when (funct = op_jr) else '0';
	r_nor <= RTYPE when (funct = op_nor) else '0';
	r_or <= RTYPE when (funct = op_or) else '0';
	r_sll <= RTYPE when (funct = op_sll) else '0';
	r_slt <= RTYPE when (funct = op_slt) else '0';
	r_sltu <= RTYPE when (funct = op_sltu) else '0';
	r_srl <= RTYPE when (funct = op_srl) else '0';
	r_subu <= RTYPE when (funct = op_subu) else '0';
	r_xor <= RTYPE when (funct = op_xor) else '0';
	
	
	i_addiu <= '1' when (opcode = op_addiu) else '0';
	i_andi <= '1' when (opcode = op_andi) else '0';
	i_beq <= '1' when (opcode = op_beq) else '0';
	i_bne <= '1' when (opcode = op_bne) else '0';
	i_lui <= '1' when (opcode = op_lui) else '0';
	i_lw <= '1' when (opcode = op_lw) else '0';
	i_ori <= '1' when (opcode = op_ori) else '0';
	i_slti <= '1' when (opcode = op_slti) else '0';
	i_sltiu <= '1' when (opcode = op_sltiu) else '0';
	i_sw <= '1' when (opcode = op_sw) else '0';
	i_xori <= '1' when (opcode = op_xori) else '0';
	i_ll   <= '1' when (opcode = op_ll) else '0';
	i_sc   <= '1' when (opcode = op_sc) else '0';
	
	o_j <= '1' when (opcode = op_j) else '0';
	o_jal <= '1' when (opcode = op_jal) else '0';


  ImmWrite	<= i_lui;
  Jump	<= o_j or o_jal;
  Link	<= o_jal;
  BEQ	<= i_beq;
  BNE	<= i_bne;
  SLT	<= i_slti or i_sltiu or r_slt or r_sltu;
  ALUSrcShamt <= r_sll or r_srl;
  RegWrite	<= i_sc or i_ll or r_addu or r_and or r_nor or r_or or r_sll or r_srl or r_slt or r_sltu or r_subu or r_xor or i_addiu or i_andi or i_lui or i_lw or i_ori or i_slti or i_sltiu or i_xori or o_jal;
  SignExt	<= i_sc or i_ll or i_addiu or i_lw or i_slti or i_sw or i_beq or i_bne;
  RegJump		<= r_jr;
  MemToReg	<= i_lw or i_ll;
  MemWrite <= i_sc or i_sw;
  LL       <= i_ll;
  SC       <= i_sc;
  
  
  AluSrc	<= i_sc or i_ll or i_addiu or i_andi or i_lui or i_ori or i_xori or i_sltiu or i_slti or i_lw or i_sw or i_bne or i_beq;
  
  
  RegSel	<= not RTYPE;  
  
  
  aluop <= ALU_SLL when r_sll = '1' else
           ALU_SRL when r_srl = '1' else
           ALU_ADD when (r_addu or i_addiu or i_lw or i_sw or i_ll or i_sc) = '1' else
           ALU_AND when (r_and or i_andi) = '1' else
           ALU_NOR when r_nor = '1' else
           ALU_OR when (r_or or i_ori) = '1' else
           ALU_XOR when (r_xor or i_xori) = '1' else ALU_SUB;

end ctrl_arch;
