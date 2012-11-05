library ieee;
use ieee.std_logic_1164.all;

entity cpuTest is
	port (
		-- clock
		CLOCK_27            : in    std_logic;
		-- switches
		SW      						: in    std_logic_vector(17 downto 0);
		-- the push keys
		KEY      						: in    std_logic_vector(3 downto 0);
		-- the 7seg display
		HEX0								:	out		std_logic_vector(6 downto 0);
		HEX1								:	out		std_logic_vector(6 downto 0);
		HEX2								:	out		std_logic_vector(6 downto 0);
		HEX3								:	out		std_logic_vector(6 downto 0);
		HEX4								:	out		std_logic_vector(6 downto 0);
		HEX5								:	out		std_logic_vector(6 downto 0);
		HEX6								:	out		std_logic_vector(6 downto 0);
		HEX7								:	out		std_logic_vector(6 downto 0);
		-- general perpose io (both have 36 pins but logic analyzer only supports 64)
		GPIO_0							: out		std_logic_vector(31 downto 0);
		GPIO_1							: out		std_logic_vector(31 downto 0);
		-- the leds
		LEDG             		: out   std_logic_vector(8 downto 0)
	);
end cpuTest;

architecture behavioral of cpuTest is

	component cpu
		port(
			-- begin ports needed for synthesis testing
			-- altera_reserved_tms	:		in	std_logic;
			-- altera_reserved_tck	:		in	std_logic;
			-- altera_reserved_tdi	:		in	std_logic;
			-- end ports needed for synthesis testing
		-- clock signal
		cpuClk							:		in	std_logic;
		-- clock signal
		ramClk							:		in	std_logic;
		-- reset for processor
		nReset					:		in	std_logic;
		-- halt for processor
		halt						:		out	std_logic;
		-- start mmio addins
		-- dip switch in
		dipIn						:		in	std_logic_vector(15 downto 0);
		-- hexout
		hexOut					:		out	std_logic_vector(31 downto 0);
		-- end mmio addins
		-- address to dump
		dumpAddr 				:		in	std_logic_vector(15 downto 0);
        memNReset : in std_logic;
        -- mux signal to arbitrate control of mem between cpu and tb.  '1' means tb
        memCtl : in std_logic;
        -- mem write enable
        memWen : in std_logic;
        -- mem address
        memAddr : in std_logic_vector(15 downto 0);
        -- mem data
        memData : in std_logic_vector(31 downto 0)
	);
	end component; 

	-- 7segment display decoder
	component bintohexDecoder
		port (
			input		:		in	std_logic_vector(3 downto 0);
			output	:		out	std_logic_vector(6 downto 0));
	end component;

	-- signals here
	signal imemAddr				:	std_logic_vector (31 downto 0);
	signal imemData				:	std_logic_vector (31 downto 0);
	signal dmemAddr				:	std_logic_vector (31 downto 0);
	signal dmemDataRead		:	std_logic_vector (31 downto 0);
	signal dmemDataWrite	:	std_logic_vector (31 downto 0);
	signal dpaddr					:	std_logic_vector (15 downto 0);
	signal halt						:	std_logic;
    signal dipIn : std_logic_vector(15 downto 0);
    signal hexOut : std_logic_vector(31 downto 0);
    signal sig_0 : std_logic;
    signal myMemAddr : std_logic_vector(15 downto 0);
    signal myMemData : std_logic_vector(31 downto 0);

begin

	cpu_comp : cpu port map (
		cpuClk       		=> CLOCK_27,
		ramClk       		=> CLOCK_27,
		nReset    		=> KEY (3),
		halt      		=> halt, --LEDG (8),
        dipIn => dipin,
        hexOut => hexout,
		dumpAddr			=> dpaddr,
        memNReset => KEY (3),
        memCtl => sig_0,
        memWen => sig_0,
        memAddr => myMemAddr,
        memData => myMemData);

	--port map decoders:
	BTH0: bintohexDecoder port map (dmemDataRead (3 downto 0), HEX0);
	BTH1: bintohexDecoder port map (dmemDataRead (7 downto 4), HEX1);	
	BTH2: bintohexDecoder port map (dmemDataRead (11 downto 8), HEX2);
	BTH3: bintohexDecoder port map (dmemDataRead (15 downto 12), HEX3);
	BTH4: bintohexDecoder port map (dmemDataRead (19 downto 16), HEX4);
	BTH5: bintohexDecoder port map (dmemDataRead (23 downto 20), HEX5);
	BTH6: bintohexDecoder port map (dmemDataRead (27 downto 24), HEX6);
	BTH7: bintohexDecoder port map (dmemDataRead (31 downto 28), HEX7);

	-- address to dump i cut off the last 2 bits
	-- which are always 0 for 4 byte aligned memory spaces
	dpaddr(15 downto 2) <= SW (13 downto 0);
	dpaddr(1 downto 0) <= "00";
	-- halt signal
	LEDG(8) <= halt;

	-- logic analyzer mux use switches 17 downto 14
	-- signals we need to always have:
	-- clock
	GPIO_0(31) <= CLOCK_27;
	-- nreset
	GPIO_0(30) <= KEY(3);
	-- halt
	GPIO_0(29) <= halt;
	-- user definable pins 29 of them
	-- can use 17 downto 16 for GPIO_0(28 downto 0)
	GPIO_0(28 downto 0) <= "00000000000000000000000000000";
	
	-- databus/addr toggle between instr and data
	with SW(15 downto 14) select
		GPIO_1 <= imemData when "01",
							dmemDataRead when "10",
							dmemDataWrite when "11",
							imemAddr(15 downto 0) & dmemAddr(15 downto 0) when others;

    sig_0 <= '0';
    dipin <= X"0000";
    myMemData <= X"00000000";
    myMemAddr <= X"0000";
end behavioral;
