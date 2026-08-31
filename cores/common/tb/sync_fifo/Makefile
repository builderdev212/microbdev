SIMULATOR := verilator
WAVEFORM_VIEWER ?= surfer

TOP       := tb_sync_fifo
DUT       := ../../sync_fifo.v
TB        := tb_sync_fifo.v

BUILD_DIR := obj_dir
SIM       := $(BUILD_DIR)/V$(TOP)
WAVEFORM  := wave.vcd

SIMULATOR_FLAGS := \
	--binary \
	--trace \
	--timing \
	-Wall \
	-Wno-fatal \
	-j 0 \
	--top-module $(TOP)

.PHONY: build
build:
	$(SIMULATOR) $(SIMULATOR_FLAGS) $(DUT) $(TB)

.PHONY: run
run:
	./$(SIM)

.PHONY: view
view:
	$(WAVEFORM_VIEWER) $(WAVEFORM) >/dev/null &

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) $(WAVEFORM)