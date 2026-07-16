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

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name "sim_build*" -exec rm -rf {} +
	find . -type f -name "*.xml" -delete
	find . -type f -name "*.info" -delete