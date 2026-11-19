BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;
ALTER TABLE sources DROP COLUMN row_filter;
ALTER TABLE sources DROP COLUMN latest_by;
DELETE FROM schema_migrations WHERE version = '007_source_versions';
COMMIT;
