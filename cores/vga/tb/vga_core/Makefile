SIMULATOR := verilator
WAVEFORM_VIEWER ?= surfer

TOP       := tb_vga_core
DUT       := \
	../../vga_core.v \
	../../vga_double_framebuffer.v \
	../../vga_pos_sync.v
TB        := tb_vga_core.v

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