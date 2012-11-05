# ECE437 Makefile

.SUFFIXES: .vhd 
COMPILE.VHDL = vcom
COMPILE.VHDLFLAGS = -93
SRCDIR = ./source
WORKDIR = ./work
VPATH= $(WORKDIR)

#Rules

%.vhd : $(SRCDIR)/%.vhd
	if [ ! -d $(WORKDIR) ]; then vlib $(WORKDIR); vmap lpm $(WORKDIR); fi
	$(COMPILE.VHDL) $(COMPILE.VHDLFLAGS) $(SRCDIR)/$@

# begin VHDL files (keep this)

registerFile_tb.vhd : registerFile.vhd
regTest.vhd: registerFile.vhd

alu.vhd: addr32Bit.vhd
addr32Bit.vhd: addr1Bit.vhd
addr32Bit_tb.vhd: addr32Bit.vhd
addr1Bit_tb.vhd: addr1Bit.vhd
tb_alu.vhd: alu.vhd
dram.vhd: dram_array.vhd dram_ctrl.vhd
aluTest.vhd: alu.vhd bintohexDecoder.vhd
mycpu.vhd: pc.vhd addr32Bit.vhd mux5.vhd ext16bit.vhd mux32.vhd registerFile.vhd alu.vhd ctrl.vhd reg_IF_ID.vhd reg_ID_EX.vhd reg_EX_MEM.vhd reg_MEM_WB.vhd fwdUnit.vhd icache.vhd dram.vhd coco.vhd
icache.vhd: cache_ctrl.vhd data_array.vhd
cpu.vhd: mycpu.vhd VarLatRAM.vhd
LAcpu.vhd: mycpu.vhd VarLatRAM.vhd
VarLatRAM.vhd: ram.vhd
cpuTest.vhd: cpu.vhd bintohexDecoder.vhd
LAcpuTest.vhd: LAcpu.vhd bintohexDecoder.vhd
tb_cpu.vhd: cpu.vhd VarLatRAM.vhd
tb_mux32.vhd: mux32.vhd
tb_mux5.vhd: mux5.vhd
tb_ext16bit.vhd: ext16bit.vhd
tb_pc.vhd: pc.vhd
tb_pauseReg.vhd: pauseReg.vhd

# end VHDL files (keep this)

# Cache rules (cache labs)
# replace this ramAxB.vhd with your own
ram16x50.vhd : 220model.vhd
220pack.vhd:
	if [ ! -d $(WORKDIR) ]; then vlib $(WORKDIR); vmap lpm $(WORKDIR); fi
	$(COMPILE.VHDL) -87 ${HOME437}/lib/LPM/220pack.vhd
220model.vhd: 220pack.vhd
	if [ ! -d $(WORKDIR) ]; then vlib $(WORKDIR); vmap lpm $(WORKDIR); fi
	$(COMPILE.VHDL) -87 ${HOME437}/lib/LPM/220model.vhd

# Lab Rules DO NOT CHANGE THESE
# OR YOU MAY FAIL THE GRADING SCRIPT
lab1: registerFile_tb.vhd
lab2: tb_alu.vhd
lab4: tb_cpu.vhd
lab5: tb_cpu.vhd
lab6: tb_cpu.vhd
lab7: tb_cpu.vhd
lab8: tb_cpu.vhd
lab9: tb_cpu.vhd
lab10: tb_cpu.vhd
lab11: tb_cpu.vhd
lab12: tb_cpu.vhd


# Time Saving Rules
clean:
	$(RM) -rf $(WORKDIR) *.log transcript \._* mapped/*.vhd *.hex
