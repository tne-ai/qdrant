use std::collections::HashMap;
use std::path::PathBuf;

use common::counter::hardware_counter::HardwareCounterCell;
use common::types::PointOffsetType;
use serde_json::Value;

use super::field_index::FieldIndex;
use crate::common::Flusher;
use crate::common::operation_error::OperationResult;
use crate::index::field_index::{CardinalityEstimation, PayloadBlockCondition};
use crate::json_path::JsonPath;
use crate::payload_storage::FilterContext;
use crate::types::{
    Filter, Payload, PayloadFieldSchema, PayloadKeyType, PayloadKeyTypeRef, SeqNumberType,
};

pub enum BuildIndexResult {
    /// Index was built
    Built(Vec<FieldIndex>),
    /// Index was already built
    AlreadyBuilt,
    /// Field Index already exists, but incompatible schema
    /// Requires extra actions to remove the old index.
    IncompatibleSchema,
}

pub trait PayloadIndex {
    /// Get indexed fields
    fn indexed_fields(&self) -> HashMap<PayloadKeyType, PayloadFieldSchema>;

    /// Build the index, if not built before, taking the caller by reference only
    fn build_index(
        &self,
        field: PayloadKeyTypeRef,
        payload_schema: &PayloadFieldSchema,
        hw_counter: &HardwareCounterCell,
    ) -> OperationResult<BuildIndexResult>;

    /// Apply already built indexes
    fn apply_index(
        &mut self,
        field: PayloadKeyType,
        payload_schema: PayloadFieldSchema,
        field_index: Vec<FieldIndex>,
    ) -> OperationResult<()>;

    /// Mark field as one which should be indexed
    fn set_indexed(
        &mut self,
        field: PayloadKeyTypeRef,
        payload_schema: impl Into<PayloadFieldSchema>,
        hw_counter: &HardwareCounterCell,
    ) -> OperationResult<()>;

    /// Remove index
    fn drop_index(&mut self, field: PayloadKeyTypeRef) -> OperationResult<()>;

    /// Remove index if incompatible with new payload schema
    fn drop_index_if_incompatible(
        &mut self,
        field: PayloadKeyTypeRef,
        new_payload_schema: &PayloadFieldSchema,
    ) -> OperationResult<()>;

    /// Estimate amount of points (min, max) which satisfies filtering condition.
    ///
    /// A best estimation of the number of available points should be given.
    fn estimate_cardinality(
        &self,
        query: &Filter,
        hw_counter: &HardwareCounterCell,
    ) -> CardinalityEstimation;

    /// Estimate amount of points (min, max) which satisfies filtering of a nested condition.
    fn estimate_nested_cardinality(
        &self,
        query: &Filter,
        nested_path: &JsonPath,
        hw_counter: &HardwareCounterCell,
    ) -> CardinalityEstimation;

    /// Return list of all point ids, which satisfy filtering criteria
    ///
    /// A best estimation of the number of available points should be given.
    fn query_points(
        &self,
        query: &Filter,
        hw_counter: &HardwareCounterCell,
    ) -> Vec<PointOffsetType>;

    /// Return number of points, indexed by this field
    fn indexed_points(&self, field: PayloadKeyTypeRef) -> usize;

    fn filter_context<'a>(
        &'a self,
        filter: &'a Filter,
        hw_counter: &HardwareCounterCell,
    ) -> Box<dyn FilterContext + 'a>;

    /// Iterate conditions for payload blocks with minimum size of `threshold`
    /// Required for building HNSW index
    fn payload_blocks(
        &self,
        field: PayloadKeyTypeRef,
        threshold: usize,
    ) -> Box<dyn Iterator<Item = PayloadBlockCondition> + '_>;

    /// Overwrite payload for point_id. If payload already exists, replace it.
    fn overwrite_payload(
        &mut self,
        point_id: PointOffsetType,
        payload: &Payload,
        hw_counter: &HardwareCounterCell,
    ) -> OperationResult<()>;

    /// Assign payload to a concrete point with a concrete payload value
    fn set_payload(
        &mut self,
        point_id: PointOffsetType,
        payload: &Payload,
        key: &Option<JsonPath>,
        hw_counter: &HardwareCounterCell,
    ) -> OperationResult<()>;

    /// Get payload for point
    fn get_payload(
        &self,
        point_id: PointOffsetType,
        hw_counter: &HardwareCounterCell,
    ) -> OperationResult<Payload>;

    /// Get payload for point with potential optimization for sequential access.
    fn get_payload_sequential(
        &self,
        point_id: PointOffsetType,
        hw_counter: &HardwareCounterCell,
    ) -> OperationResult<Payload>;

    /// Delete payload by key
    fn delete_payload(
        &mut self,
        point_id: PointOffsetType,
        key: PayloadKeyTypeRef,
        hw_counter: &HardwareCounterCell,
    ) -> OperationResult<Vec<Value>>;

    /// Drop all payload of the point
    fn clear_payload(
        &mut self,
        point_id: PointOffsetType,
        hw_counter: &HardwareCounterCell,
    ) -> OperationResult<Option<Payload>>;

    /// Return function that forces persistence of current storage state.
    fn flusher(&self) -> Flusher;

    #[cfg(feature = "rocksdb")]
    fn take_database_snapshot(&self, path: &std::path::Path) -> OperationResult<()>;

    fn files(&self) -> Vec<PathBuf>;

    fn immutable_files(&self) -> Vec<PathBuf> {
        Vec::new()
    }

    fn versioned_files(&self) -> Vec<(PathBuf, SeqNumberType)> {
        Vec::new()
    }
}
