## GENERAL ##


## XC7A35T (BASYS3) ##
.PHONY: projgen_xc7a35t
projgen_xc7a35t:
	@cd system/XC7A35T/build && make projgen

.PHONY: open_xc7a35t
open_xc7a35t:
	@cd system/XC7A35T/build && vivado fpga_xc7a35t.xpr &

## CLEAN ##
.PHONY: clean_all
clean_all: clean clean_xc7a35t clean_cocotb

.PHONY: clean
clean:
	@find . -type d -name '.gen' -print0 | xargs -0 rm -rf
	@rm -rf *.Xil
	@rm -f *.log
	@rm -f *.jou

.PHONY: clean_xc7a35t
clean_xc7a35t:
	@cd system/XC7A35T/build && make clean

.PHONY: clean_cocotb
clean_cocotb:
	@cd verif/cocotb && make clean
