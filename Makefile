.PHONY: all build clean run help

# Default target
all: build

# Build the ISO using the Docker builder (recommended)
build:
	@echo "Building MaleoOS ISO..."
	./build/build-docker.sh

# Run the built ISO in QEMU
run:
	@echo "Starting QEMU..."
	./qemu.sh

# Clean build artifacts
clean:
	@echo "Cleaning output directory..."
	rm -rf output/*
	rm -f /tmp/maleo.img
	@echo "Clean complete."

# Show help message
help:
	@echo "MaleoOS Makefile"
	@echo "Usage:"
	@echo "  make build  - Build the ISO using Docker"
	@echo "  make run    - Run the built ISO in QEMU"
	@echo "  make clean  - Clean output directory and temporary images"
	@echo "  make help   - Show this help message"
