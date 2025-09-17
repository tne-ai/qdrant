.PHONY: install run clean help kill stop

# Configuration
PORT ?= 6333

# Default target
## help: Show this help message.
help:
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' |  sed -e 's/^/ /'

## install: Install dependencies and build Qdrant locally
install: build
	brew install rustup
	rustup component add rustfmt
	brew install protobuf
	cargo build --release --bin qdrant
	./tools/sync-web-ui.sh

## kill/stop: Stop running Qdrant server
kill stop:
	pkill qdrant || echo "No Qdrant server was running"

## run: Run Qdrant locally (PORT=6333 by default)
run: kill
	QDRANT__HTTP_PORT=$(PORT) ./target/release/qdrant
	@echo "Web UI available at: http://localhost:$(PORT)/dashboard"

## clean: Clean build artifacts
clean:
	cargo clean
