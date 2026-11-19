-- DVS Metrics Catalog, migration 002: a screen column can show a metric for LY or LLY.
-- Run as psql (member of dvs_owner), same as 001:
--   /usr/bin/psql -X "host=172.16.50.218 port=5432 dbname=ucm user=psql sslmode=require" -f 002_binding_period.sql
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

ALTER TABLE bindings
    ADD COLUMN period text NOT NULL DEFAULT 'ty' CHECK (period IN ('ty', 'ly', 'lly'));
COMMENT ON COLUMN bindings.period IS
    'which year the column shows: ty, ly (calendar weeks whose cctytime is a ty week), lly';

INSERT INTO schema_migrations (version) VALUES ('002_binding_period');
COMMIT;
