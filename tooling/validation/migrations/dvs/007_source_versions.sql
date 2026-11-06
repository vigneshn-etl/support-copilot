-- DVS Metrics Catalog, migration 007: versioned sources (Assortment plan snapshots).
--   row_filter  condition on the source rows, e.g. snapshot_version = 'RP'
--   latest_by   version column: per item, keep only the rows with its latest value in the window
--               (QA PS_ASST_PRODUCT_MAX: max(updated_at) per x_product)
-- Run as psql (member of dvs_owner), after 006. On the DEV processor:
--   CLIENT=ucm psql -X -f ~/007_source_versions.sql
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

ALTER TABLE sources ADD COLUMN row_filter text;
ALTER TABLE sources ADD COLUMN latest_by text;
COMMENT ON COLUMN sources.row_filter IS 'condition on source rows, e.g. snapshot_version = ''RP''';
COMMENT ON COLUMN sources.latest_by IS 'version column: keep each item''s rows with the latest value in the window';

INSERT INTO schema_migrations (version) VALUES ('007_source_versions');
COMMIT;
