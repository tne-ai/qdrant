.PHONY: install run clean help kill stop dev test check docker-run docker-build

# Configuration
PORT ?= 6333
DOCKER_PORT ?= 6333
GRPC_PORT ?= 6334

# Default target
## help: Show this help message.
help:
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' |  sed -e 's/^/ /'

## install: Install dependencies and build Qdrant locally
install:
	@echo "Installing Rust toolchain and dependencies..."
	brew install rustup || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	rustup install stable
	rustup component add rustfmt clippy
	brew install protobuf
	@echo "Building Qdrant release binary..."
	cargo build --release --bin qdrant
	./tools/sync-web-ui.sh
	@echo "✅ Installation complete! Run 'make run' to start Qdrant."

## dev: Build and run in development mode
dev: kill
	@echo "Starting Qdrant in development mode..."
	RUST_LOG=debug cargo run --bin qdrant

## test: Run all tests
test:
	cargo test

## check: Run code quality checks (fmt, clippy)
check:
	cargo fmt --check
	cargo clippy -- -D warnings

## kill/stop: Stop running Qdrant server
kill stop:
	pkill qdrant || echo "No Qdrant server was running"

## run: Run Qdrant locally (PORT=6333 by default)
run: kill
	@echo "Starting Qdrant on port $(PORT)..."
	QDRANT__HTTP_PORT=$(PORT) ./target/release/qdrant &
	@echo "✅ Qdrant started!"
	@echo "   REST API: http://localhost:$(PORT)"
	@echo "   gRPC API: http://localhost:$(GRPC_PORT)"
	@echo "   Web UI: http://localhost:$(PORT)/dashboard"

## docker-build: Build Qdrant Docker image
docker-build:
	docker build -t qdrant/qdrant:local .

## docker-run: Run Qdrant using Docker (DOCKER_PORT=6333 by default)
docker-run:
	@echo "Running Qdrant in Docker on port $(DOCKER_PORT)..."
	docker run -p $(DOCKER_PORT):6333 -p $(GRPC_PORT):6334 \
		-v "$(PWD)/qdrant_storage:/qdrant/storage" \
		qdrant/qdrant:local
	@echo "✅ Qdrant Docker container started!"
	@echo "   Web UI: http://localhost:$(DOCKER_PORT)/dashboard"

## clean: Clean build artifacts
clean:
	cargo clean
	rm -rf qdrant_storage/

# Environment setup note
## Note: For environment variables, consider using 1Password CLI (op) and mise for tool version management
## Example: eval $(op signin) && op read "op://vault/qdrant/env" > .env
