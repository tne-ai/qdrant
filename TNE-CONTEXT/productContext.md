# Product Context

This file provides a high-level overview of the project and the expected product that will be created. Initially it is based upon projectBrief.md (if provided) and all other available project-related information in the working directory. This file is intended to be updated as the project evolves, and should be used to inform all other modes of the project's goals and context.
2025-09-17 15:12:47 - Migrated from memory-bank and enhanced with detailed analysis

## Project Goal

* Qdrant vector database system - high-performance vector similarity search engine
* Goal: Get Qdrant running with web interface for vector search operations
* **Enhanced Goal:** Complete understanding and documentation of Qdrant architecture for development and deployment

## Key Features

* Vector similarity search with extended filtering support
* RESTful API (port 6333 by default) 
* gRPC API for production-tier searches
* Web interface dashboard at `/dashboard`
* Clustering and distributed deployment support
* Snapshot functionality for data backup
* Multiple storage backends with vector quantization
* Hybrid search with sparse vectors (BM25/TF-IDF-like)
* Payload support with JSON attachments to vectors
* SIMD hardware acceleration
* Write-ahead logging for data persistence

## Overall Architecture

* **Language:** Rust 🦀 (2024 edition, minimum Rust 1.87)
* **Web Framework:** Actix-web for HTTP REST API
* **gRPC Framework:** Tonic for high-performance gRPC API  
* **Storage Engine:** RocksDB (default backend)
* **Configuration:** YAML-based configuration files
* **Build System:** Cargo with workspace structure
* **Web UI:** Integrated dashboard for management
* **Deployment:** Docker containers, native binaries, or cloud (Qdrant Cloud)
* **Performance:** io_uring for async I/O, jemalloc for memory management
* **Clustering:** Raft consensus for distributed operations

2025-09-17 15:12:47 - Enhanced with comprehensive Qdrant v1.15.1 architecture details from README.md and Cargo.toml analysis