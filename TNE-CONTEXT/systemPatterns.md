# System Patterns

This file documents recurring patterns and standards used in the project.
It is optional, but recommended to be updated as the project evolves.
2025-09-17 15:14:34 - Enhanced from memory-bank with detailed Qdrant architectural patterns

## Coding Patterns

* **Rust 2024 Edition**: Modern Rust with latest language features and idioms
* **Cargo Workspace**: Multi-crate organization with shared dependencies in workspace
* **Actix-web Framework**: Actor-based web framework for HTTP REST API endpoints
* **Tonic gRPC**: High-performance gRPC implementation for production APIs  
* **Error Handling**: Comprehensive error types using `thiserror` crate patterns
* **Async/Await**: Tokio-based async runtime with `futures` and `futures-util`
* **Configuration**: YAML-based config with `config` crate and environment overrides
* **Logging**: Structured logging with `tracing` and optional console/Tracy profiling
* **Testing**: Integration tests in `tests/` with `sealed_test` for isolation

## Architectural Patterns

* **Vector Database Engine**: Core storage optimized for high-dimensional vector similarity search
* **Dual API Pattern**: REST (port 6333) for ease of use, gRPC for high performance
* **Plugin Architecture**: Modular storage backends (RocksDB default, with quantization options)
* **Distributed Consensus**: Raft-based clustering for horizontal scaling and replication
* **Payload Filtering**: JSON payload attachment with complex query and filtering capabilities
* **Hybrid Search**: Dense + sparse vector support (semantic + keyword matching)
* **Memory Management**: jemalloc allocator with vector quantization for memory efficiency
* **I/O Optimization**: io_uring async I/O with SIMD hardware acceleration
* **Web UI Integration**: Dashboard served at `/dashboard` with build pipeline
* **Configuration Layering**: Development, production, and custom YAML configs

## Testing Patterns

* **Integration Testing**: Comprehensive tests in `tests/` directory with real scenarios
* **Cargo Test Execution**: Standard `cargo test` with workspace-wide test coordination
* **Shell Script Testing**: Automated testing workflows in `tools/` directory
* **Performance Benchmarks**: Criterion-based benchmarking for vector operations
* **Docker Testing**: Container-based integration testing for deployment scenarios
* **Configuration Testing**: Multi-environment config validation and testing
* **API Testing**: Both REST and gRPC endpoint testing with various payloads
* **Clustering Testing**: Distributed consensus and replication testing patterns

2025-09-17 15:14:34 - Documented comprehensive Qdrant architectural and coding patterns based on Cargo.toml and README.md analysis