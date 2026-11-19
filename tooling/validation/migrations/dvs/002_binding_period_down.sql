-- Undo migration 002. Run as psql.
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;
ALTER TABLE bindings DROP COLUMN IF EXISTS period;
DELETE FROM schema_migrations WHERE version = '002_binding_period';
COMMIT;
