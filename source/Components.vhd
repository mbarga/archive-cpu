   -- Component declarations
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
   
   component ramd IS
     PORT
     (
       address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
       clock		: IN STD_LOGIC ;
       data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
       wren		: IN STD_LOGIC ;
       q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
     );
   end component ramd;
   
   component alu is
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
  end component alu;
    
    component dff is
      port
      (
        -- input port
        D		:	in	std_logic;
        -- clock, positive edge triggered
        clk			:	in	std_logic;
        -- REMEMBER: nReset-> '0' = RESET, '1' = RUN
        nRst	:	in	std_logic;
        -- output
        output		:	out	std_logic
        );
    end component dff; 
    
    component rami IS
      PORT
      (
        address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        clock		: IN STD_LOGIC ;
        data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        wren		: IN STD_LOGIC ;
        q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
    END component rami;
    
    component pc is
      port
      (
        -- input port
        D		:	in	std_logic_vector (31 downto 0);
        -- if(halt == 1) pc <= I; else pc <= pc;
        halt			:	in	std_logic;
        -- clock, positive edge triggered
        clk			:	in	std_logic;
        -- REMEMBER: nReset-> '0' = RESET, '1' = RUN
        nRst	:	in	std_logic;
        -- output
        output		:	out	std_logic_vector (31 downto 0)
        );
    end component pc;
    
    component registerFile is
      port
      (
        -- Write data input port
        wdat		:	in	std_logic_vector (31 downto 0);
        -- Select which register to write
        wsel		:	in	std_logic_vector (4 downto 0);
        -- Write Enable for entire register file
        wen			:	in	std_logic;
        -- clock, positive edge triggered
        clk			:	in	std_logic;
        -- REMEMBER: nReset-> '0' = RESET, '1' = RUN
        nReset	:	in	std_logic;
        -- Select which register to read on rdat1 
        rsel1		:	in	std_logic_vector (4 downto 0);
        -- Select which register to read on rdat2
        rsel2		:	in	std_logic_vector (4 downto 0);
        -- read port 1
        rdat1		:	out	std_logic_vector (31 downto 0);
        -- read port 2
        rdat2		:	out	std_logic_vector (31 downto 0)
        );
    end component registerFile;
    
    component ext16Bit is
            port
            (
                    signed		:	in	std_logic;
                    -- Select
                    I		:	in	std_logic_vector (15 downto 0);
                    -- Inputs
                    output			:	out	std_logic_vector (31 downto 0)
                    -- Output
             );
    end component ext16Bit;
    
    component mux5 is
      port
      (
        sel		:	in	std_logic;
        -- Select
        I0,I1		:	in	std_logic_vector (4 downto 0);
        -- Inputs
        output			:	out	std_logic_vector (4 downto 0)
        -- Output
        );
    end component mux5;
    
    component mux32 is
      port
      (
        sel		:	in	std_logic;
        -- Select
        I0,I1		:	in	std_logic_vector (31 downto 0);
        -- Inputs
        output			:	out	std_logic_vector (31 downto 0)
        -- Output
        );
    end component mux32;