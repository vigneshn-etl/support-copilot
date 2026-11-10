BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;
DELETE FROM metrics WHERE metric_type = 'band';
ALTER TABLE screens DROP COLUMN row_groups;
ALTER TABLE metrics DROP CONSTRAINT metrics_metric_type_check;
ALTER TABLE metrics ADD CONSTRAINT metrics_metric_type_check
    CHECK (metric_type = ANY (ARRAY['simple', 'derived', 'ratio']));
DELETE FROM schema_migrations WHERE version = '008_band_metrics';
COMMIT;
