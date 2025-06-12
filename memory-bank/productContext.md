# Product Context

This file provides a high-level overview of the project and the expected product that will be created. Initially it is based upon projectBrief.md (if provided) and all other available project-related information in the working directory. This file is intended to be updated as the project evolves, and should be used to inform all other modes of the project's goals and context.
2025-01-06 22:30:25 - Log of updates made will be appended as footnotes to the end of this file.

## Project Goal

* Qdrant vector database system - high-performance vector similarity search engine
* Goal: Get Qdrant running with web interface for vector search operations

## Key Features

* Vector similarity search
* RESTful API
* gRPC API  
* Web interface
* Clustering support
* Snapshot functionality
* Multiple storage backends

## Overall Architecture

* Rust-based vector database
* Actix-web for HTTP API
* Tonic for gRPC API  
* Web UI for management
* Configuration-driven setup