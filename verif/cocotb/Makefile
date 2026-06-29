IMAGE_NAME=verilator-cocotb
TAG=latest
CONTAINER_NAME=verilator-dev

.PHONY: run-dev
run:
	podman run --rm -it \
		--name $(CONTAINER_NAME) \
		-v $(PWD)/../..:/workspace \
		-w /workspace \
		$(IMAGE_NAME):$(TAG)

