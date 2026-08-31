IMAGE_NAME=verilator-cocotb
TAG=latest
CONTAINER_NAME=verilator-dev
TEST_RUNNER=/workspace/verif/cocotb/scripts/test.sh

.PHONY: run
run:
	podman run --rm -it \
		--name $(CONTAINER_NAME) \
		-v $(PWD)/../..:/workspace \
		-w /workspace \
		$(IMAGE_NAME):$(TAG)

.PHONY: test
test:
	@test -n "$(TEST)" || (echo "Error: TEST is required"; exit 1)
	@test -n "$(TEST_RUNNER)" || (echo "Error: TEST_RUNNER is required"; exit 1)
	podman run --rm -t \
		--name $(CONTAINER_NAME) \
		--entrypoint /bin/bash \
		-v $(PWD)/../..:/workspace \
		-w /workspace \
		$(IMAGE_NAME):$(TAG) \
		"$(TEST_RUNNER)" -p "$(TEST)"

.PHONY: clean
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name "sim_build*" -exec rm -rf {} +
	find . -type d -name "coverage" -exec rm -rf {} +
	find . -type f -name "*.xml" -delete
	find . -type f -name "*.info" -delete
