# Qdrant Vector Database - LLM Agent Instructions

## Overview

**Qdrant** is a high-performance, open-source vector similarity search engine and database written in Rust. It provides production-ready service with convenient API to store, search and manage high-dimensional vectors with extended filtering support.

## Application Identity

- **Name**: Qdrant Vector Database
- **Version**: 1.15.1 
- **Language**: Rust (Edition 2024, minimum version 1.87)
- **License**: Apache-2.0
- **Repository**: https://github.com/qdrant/qdrant
- **Homepage**: https://qdrant.tech/

## Quick Start

### Prerequisites Installation

```bash
# Install Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# OR via Homebrew
brew install rustup

# Install Protocol Buffers (required for gRPC)
brew install protobuf

# Install mise for environment management (recommended)
brew install mise
```

### Environment Setup

```bash
# Use mise for consistent tooling
mise install
mise exec -- rustup component add rustfmt clippy

# Or manual setup
rustup install stable
rustup component add rustfmt clippy
```

### Installation and Running

```bash
# Install dependencies and build
make install

# Run in development mode (with debug logging)
make dev

# Run production build
make run

# Or with custom port
PORT=8080 make run

# Build Docker image
make docker-build

# Run via Docker
make docker-run
```

## Architecture Overview

### Core Components

1. **Multi-Protocol API Layer**
   - **REST API** (Actix-web, port 6333): Complete REST endpoints for all operations
   - **gRPC API** (Tonic, port 6334): High-performance binary protocol
   - **Web UI** (port 6333/dashboard): Built-in administration interface

2. **Storage Engine**
   - **RocksDB**: Default persistent storage backend
   - **Table of Contents (ToC)**: Central collection manager
   - **Write-Ahead Log (WAL)**: Data consistency and recovery
   - **Vector Quantization**: Memory optimization techniques

3. **Vector Search Architecture**
   - **HNSW Algorithm**: Hierarchical Navigable Small World for ANN search
   - **Distance Metrics**: Cosine similarity, Dot product, Euclidean distance  
   - **Hybrid Search**: Dense + sparse vector combination
   - **Payload Filtering**: Advanced filtering during search operations

4. **Distributed System**
   - **Raft Consensus**: Distributed consensus for cluster coordination
   - **P2P Communication**: Inter-node communication (port 6335)
   - **Automatic Sharding**: Horizontal scaling with shard management
   - **Replication**: Configurable replication factor

### Key Directories

- **`src/`**: Main application code
  - `main.rs` (651 lines): Bootstrap, runtime setup, service orchestration
  - `settings.rs`: Configuration system with hierarchical YAML loading
  - `actix/`: REST API implementation (Actix-web framework)
  - `tonic/`: gRPC API implementation (Tonic framework)
- **`lib/`**: Workspace crates for modular architecture
- **`config/`**: Environment-specific configuration files
- **`tools/`**: Development and maintenance scripts

## Configuration

### Configuration Files

1. **`config/config.yaml`** (351 lines): Main configuration with comprehensive options:
   - Storage settings (paths, WAL, optimizers)
   - Service configuration (ports, CORS, TLS)
   - Cluster settings (consensus, P2P)
   - HNSW index parameters

2. **`config/development.yaml`** (33 lines): Development overrides:
   - Debug logging level
   - Local inference service configuration
   - Performance optimizations for development

3. **`config/production.yaml`** (7 lines): Production-ready settings:
   - INFO logging level
   - Host binding configuration

### Environment Variables

All configuration can be overridden with environment variables using the pattern:
`QDRANT__SECTION__PARAMETER`

Examples:
```bash
export QDRANT__SERVICE__HTTP_PORT=6333
export QDRANT__SERVICE__GRPC_PORT=6334
export QDRANT__STORAGE__STORAGE_PATH="./qdrant_storage"
export QDRANT__LOG_LEVEL="DEBUG"
```

## Development Workflow

### Building and Testing

```bash
# Development build with debugging
cargo build

# Release build (optimized)
cargo build --release

# Run tests
make test
# OR
cargo test

# Code quality checks
make check
# This runs:
# - cargo fmt --check (formatting)
# - cargo clippy -- -D warnings (linting)

# Clean build artifacts
make clean
```

### Docker Development

```bash
# Build Docker image
make docker-build

# Run containerized version
make docker-run

# This maps:
# - Port 6333 (HTTP/REST API + Web UI)  
# - Port 6334 (gRPC API)
# - Volume ./qdrant_storage:/qdrant/storage
```

## API Usage Examples

### REST API (HTTP)

```bash
# Health check
curl http://localhost:6333/

# Create collection
curl -X PUT http://localhost:6333/collections/my_collection \
  -H "Content-Type: application/json" \
  -d '{
    "vectors": {
      "size": 768,
      "distance": "Cosine"
    }
  }'

# Insert vectors
curl -X PUT http://localhost:6333/collections/my_collection/points \
  -H "Content-Type: application/json" \
  -d '{
    "points": [
      {
        "id": 1,
        "vector": [0.1, 0.2, 0.3, ...],
        "payload": {"city": "Berlin"}
      }
    ]
  }'

# Search vectors
curl -X POST http://localhost:6333/collections/my_collection/points/search \
  -H "Content-Type: application/json" \
  -d '{
    "vector": [0.1, 0.2, 0.3, ...],
    "limit": 10,
    "filter": {
      "must": [
        {"key": "city", "match": {"value": "Berlin"}}
      ]
    }
  }'
```

### gRPC API

The gRPC API provides the same functionality with better performance for high-throughput scenarios. Protocol buffers definitions are available in the `openapi/` directory.

## Key Features to Understand

### Vector Search Capabilities
- **Dense Vectors**: Traditional embeddings from ML models
- **Sparse Vectors**: BM25/TF-IDF style sparse representations  
- **Hybrid Search**: Combines dense and sparse for best results
- **Multi-Vector**: Multiple vector types per point

### Filtering and Querying
- **Payload Filtering**: Rich filtering on associated metadata
- **Geo Filtering**: Location-based queries
- **Range Filtering**: Numeric range queries
- **Complex Boolean Logic**: Nested AND/OR/NOT conditions

### Performance Features
- **HNSW Indexing**: Sub-linear search performance
- **Vector Quantization**: Reduced memory usage
- **Parallel Processing**: Multi-threaded operations
- **Resource Management**: CPU and I/O budget allocation

### Production Features
- **High Availability**: Cluster mode with consensus
- **Horizontal Scaling**: Automatic sharding
- **Backup/Restore**: Snapshot management
- **Monitoring**: Prometheus metrics, health checks
- **Security**: JWT RBAC, API keys, TLS support

## Troubleshooting

### Common Issues

1. **Port conflicts**: Check if ports 6333/6334/6335 are available
2. **Storage permissions**: Ensure write access to storage directory
3. **Memory usage**: Monitor RAM consumption with large datasets
4. **Build errors**: Ensure Rust 1.87+ and protobuf are installed

### Logging and Debugging

```bash
# Enable debug logging
export RUST_LOG=debug
export QDRANT__LOG_LEVEL=DEBUG

# Run with detailed logging
make dev

# Check logs for specific modules
export RUST_LOG=qdrant::actix=debug,collection=info
```

### Performance Tuning

Key configuration parameters for performance:
- `storage.performance.max_search_threads`: Search parallelization
- `storage.optimizers.default_segment_number`: Segment management
- `storage.hnsw_index.m`: HNSW graph connectivity
- `storage.hnsw_index.ef_construct`: Index build quality

## Advanced Usage

### Cluster Deployment

```yaml
# config/cluster.yaml
cluster:
  enabled: true
  p2p:
    port: 6335
    enable_tls: false
  consensus:
    tick_period_ms: 100
```

### Custom Inference Integration

Qdrant supports integration with inference services for automatic embedding generation:

```yaml
inference:
  address: "http://localhost:2114/api/v1/infer"
  timeout: 10
  token: "your-inference-token"
```

### Monitoring and Observability

- **Health endpoint**: `GET /health`
- **Metrics endpoint**: `GET /metrics` (Prometheus format)
- **Telemetry**: Usage statistics (can be disabled)
- **Distributed tracing**: Optional tracing support

## Security Considerations

### Authentication Methods
1. **API Keys**: Simple token-based authentication
2. **JWT RBAC**: Role-based access control with JWT tokens
3. **Read-only keys**: Separate keys for read-only access

### TLS Configuration
```yaml
service:
  enable_tls: true
  verify_https_client_certificate: false

tls:
  cert: ./tls/cert.pem
  key: ./tls/key.pem
  ca_cert: ./tls/cacert.pem
  cert_ttl: 3600
```

## Maintenance Operations

### Backup and Restore

```bash
# Create snapshot
curl -X POST http://localhost:6333/collections/my_collection/snapshots

# List snapshots  
curl http://localhost:6333/collections/my_collection/snapshots

# Recover from snapshot
curl -X PUT http://localhost:6333/collections/recovery \
  -H "Content-Type: application/json" \
  -d '{"location": "file://path/to/snapshot"}'
```

### Collection Management

```bash
# List collections
curl http://localhost:6333/collections

# Collection info
curl http://localhost:6333/collections/my_collection

# Delete collection
curl -X DELETE http://localhost:6333/collections/my_collection
```

## Best Practices for Agents

1. **Always check health endpoint** before operations
2. **Use appropriate distance metrics** for your embedding model
3. **Implement proper error handling** for network timeouts
4. **Monitor memory usage** during bulk operations  
5. **Use batch operations** for better performance
6. **Configure appropriate replication** for production
7. **Regular snapshots** for data protection
8. **Use filtering efficiently** to improve search performance

## File Organization

When working with Qdrant codebase:
- **Main business logic**: `src/main.rs`, `src/settings.rs`
- **API implementations**: `src/actix/`, `src/tonic/`
- **Library crates**: `lib/` directory (collection, segment, storage, api)
- **Configuration templates**: `config/` directory
- **Documentation**: `docs/` directory
- **Development tools**: `tools/` directory

This guide provides comprehensive instructions for LLM agents to understand, deploy, configure, and work with the Qdrant vector database system effectively.