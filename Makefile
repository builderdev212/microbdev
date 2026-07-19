## GENERAL ##


## XC7A35T (BASYS3) ##
.PHONY: projgen_xc7a35t
projgen_xc7a35t:
	@cd system/XC7A35T/build && make projgen

.PHONY: add_led_xc7a35t
add_led_xc7a35t:
	@cd system/XC7A35T/build && make add_led

.PHONY: open_xc7a35t
open_xc7a35t:
	@cd system/XC7A35T/build && vivado fpga_xc7a35t.xpr &

## CLEAN UP ##
.PHONY: clean_all
clean_all: clean clean_xc7a35t

.PHONY: clean
clean:
	@find . -type d -name '.gen' -print0 | xargs -0 rm -rf
	@rm -rf *.Xil
	@rm -f *.log
	@rm -f *.jou

.PHONY: clean_xc7a35t
clean_xc7a35t:
	@cd system/XC7A35T/build && make clean
