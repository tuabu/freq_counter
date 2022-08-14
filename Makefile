#BOARD CONFIG
PCF ?= icebitsy1.pcf
FREQ ?= 12
PACKAGE ?= sg48

#FILE CONFIG
TOP_VERILOG ?= top.v
TOP_VHDL    ?= top.vhdl
TOP_MODULE ?= top
FILE ?= a
TB     ?= tb.sv

#TOOLCHAIN
YOSYS ?= yosys
YOSYS_ARGS_VERILOG ?= -p 'synth_ice40 -top $(TOP_MODULE) -device u -json $(FILE).json' $(TOP_VERILOG)
YOSYS_ARGS_VHDL ?= -m ghdl -p 'ghdl $(TOP_VHDL) -e $(TOP_MODULE); synth_ice40 -json $(FILE).json' 
NEXTPNR ?= nextpnr-ice40
NEXTPNR_ARGS ?= --seed 12 --freq $(FREQ) --up5k --package $(PACKAGE) --asc $(FILE).asc --pcf $(PCF) --json $(FILE).json 
ICEPACK ?= icepack
ICEPACK_ARGS ?= $(FILE).asc $(FILE).bin

DFU ?= dfu-util
DFU_ARGS ?= -a 0 -D $(FILE).bin

.PHONY: testbench verilog vhdl synth-verilog synth-vhdl pnr pack prog clean  

testbench: $(TOP_VERILOG) $(TB)
		iverilog -Wall -g2012 $(TOP_VERILOG) $(TB)
		vvp a.out

verilog: $(TOP_VERILOG)
	$(YOSYS) $(YOSYS_ARGS_VERILOG) 
	$(NEXTPNR) $(NEXTPNR_ARGS)
	$(ICEPACK) $(ICEPACK_ARGS)

vhdl: $(TOP_VHDL)
	$(YOSYS) $(YOSYS_ARGS_VHDL)
	$(NEXTPNR) $(NEXTPNR_ARGS)
	$(ICEPACK) $(ICEPACK_ARGS)

synth-verilog: $(TOP_VERILOG)
	$(YOSYS) $(YOSYS_ARGS_VERILOG)

synth-vhdl: $(TOP_VHDL)
	$(YOSYS) $(YOSYS_ARGS_VHDL) 

pnr: $(FILE).json
	$(NEXTPNR) $(NEXTPNR_ARGS)

pack: $(FILE).asc
	$(ICEPACK) $(ICEPACK_ARGS)

prog: $(FILE).bin
	$(DFU) $(DFU_ARGS)

clean: $(FILE).*
	rm $(FILE).*


