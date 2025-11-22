CONTAINER_IMG := ghcr.io/builderdev212/cocotb-runner

clean:
	@rm -rf *.Xil
	@rm -f *.log
	@rm -f *.jou

clean_xc7a35t:
	@cd src/system/XC7A35T/build && make clean

projgen_xc7a35t:
	@cd src/system/XC7A35T/build && make projgen

add_led_xc7a35t:
	@cd src/system/XC7A35T/build && make add_led

open_xc7a35t:
	@cd src/system/XC7A35T/build && vivado fpga_xc7a35t.xpr &

run::
	@podman run -it --rm \
	    -e DISPLAY \
	    -v "/tmp/.X11-unix":"/tmp/.X11-unix" \
	    -v "${XAUTHORITY}":"/root/.Xauthority" \
		-v "${PWD}":"/usr/src/verilogbits/" \
	    --ipc host \
	    ${CONTAINER_IMG}

clean::
	@find . -type d -name "*__pycache__" -exec echo {} + -exec rm -rf {} +
	@find . -type d -name "*.pytest_cache" -exec echo {} + -exec rm -rf {} +
	@find . -type d -name "*sim_build" -exec echo {} + -exec rm -rf {} +
	@find . -type d -name "*.venv" -exec echo {} + -exec rm -rf {} +
	@find . -name "verilogbits.log" -exec echo {} + -exec rm -rf {} +