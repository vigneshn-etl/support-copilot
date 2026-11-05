-- Undo migration 001 (drops every catalog table and its history). Run as psql.
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;
DROP TABLE IF EXISTS bindings, screens, business_rules, metrics, measures, sources,
                     row_history, sync_runs, schema_migrations;
DROP FUNCTION IF EXISTS log_row_history(), touch_updated();
COMMIT;
