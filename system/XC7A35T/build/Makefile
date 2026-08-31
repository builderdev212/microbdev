PROJ_NAME:=fpga_xc7a35t

.PHONY: projgen
projgen:
	@vivado -mode batch -source projgen_xc7a35t.tcl -notrace -nojournal -log vivado_projgen.log

.PHONY: open
open:
	@vivado fpga_xc7a35t.xpr &

clean:
	@rm -rf $(PROJ_NAME).runs
	@rm -rf $(PROJ_NAME).srcs
	@rm -rf $(PROJ_NAME).sim
	@rm -rf $(PROJ_NAME).cache
	@rm -rf $(PROJ_NAME).hw
	@rm -rf $(PROJ_NAME).gen
	@rm -rf $(PROJ_NAME).ip_user_files
	@rm -rf $(PROJ_NAME).runs
	@rm -f $(PROJ_NAME).xpr
	@rm -rf .Xil
	@rm -f *.log
	@rm -f $(PROJ_NAME)*.bin.gz
	@rm -f $(PROJ_NAME)*.tar.gz
	@rm -f $(PROJ_NAME)*.prm
	@rm -f *.jou
	@rm -f *.logfile
	@rm -f *.str
	@rm -f *.wcfg
	@rm -f *.pb

