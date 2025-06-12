.PHONY: install build run clean install-deps help kill stop

# Configuration
PORT ?= 6333

# Default target
help:
	@echo "Available targets:"
	@echo "  install      - Install dependencies and build Qdrant locally"
	@echo "  build        - Build Qdrant in release mode"
	@echo "  run          - Run Qdrant locally (PORT=6333 by default)"
	@echo "  kill/stop    - Stop running Qdrant server"
	@echo "  clean        - Clean build artifacts"
	@echo "  install-deps - Install required dependencies"
	@echo "  install-webui - Install Web UI"
	@echo ""
	@echo "Usage: make run PORT=8080  # Run on custom port"

# Install dependencies and build locally
install: install-deps build install-webui
	@echo "Qdrant built successfully with Web UI! Run 'make run' to start the server."
	@echo "Web UI available at: http://localhost:$(PORT)/dashboard"

# Install required dependencies
install-deps:
	@echo "Installing Rust if not present..."
	@command -v rustc >/dev/null 2>&1 || { \
		echo "Installing Rust..."; \
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; \
	}
	@echo "Adding rustfmt component..."
	@. ~/.cargo/env 2>/dev/null || true; rustup component add rustfmt
	@echo "Installing protobuf compiler..."
	@command -v protoc >/dev/null 2>&1 || { \
		echo "Installing protobuf via Homebrew..."; \
		brew install protobuf; \
	}

# Build Qdrant in release mode
build:
	@echo "Building Qdrant..."
	cargo build --release --bin qdrant

# Install Web UI
install-webui:
	@echo "Installing Qdrant Web UI..."
	./tools/sync-web-ui.sh
	@echo "Web UI installed! Access it at http://localhost:$(PORT)/dashboard"

# Stop running Qdrant server
kill stop:
	@echo "Stopping any running Qdrant servers..."
	@pkill qdrant || echo "No Qdrant server was running"

# Run Qdrant locally with web UI
run: kill
	@echo "Starting Qdrant on http://localhost:$(PORT)"
	QDRANT__HTTP_PORT=$(PORT) ./target/release/qdrant

# Clean build artifacts
clean:
	cargo clean
