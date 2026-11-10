-- DVS Metrics Catalog, migration 008: rank-band metrics and rank-group screens.
--   metric_type 'band': expr = the item's score; items with score > 0 ranked ascending and cut into
--   quintiles of their count (1..5), others 1 (QA history_bands_ty.ftl). A band metric used inside
--   another band's expr gives its raw band (0 when the score is not > 0), as QA's composite does.
--   screens.row_groups 'pareto:<metric>': rows are rank groups of the items (QA HistoryInfoGraph, Pareto
--   Summary): per period ranked by <metric> descending, cut into Top 20% .. Bottom 20% (+ Total, Top 50).
-- Run as psql (member of dvs_owner), after 007. On the DEV processor:
--   CLIENT=ucm psql -X -f ~/008_band_metrics.sql
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

ALTER TABLE metrics DROP CONSTRAINT metrics_metric_type_check;
ALTER TABLE metrics ADD CONSTRAINT metrics_metric_type_check
    CHECK (metric_type = ANY (ARRAY['simple', 'derived', 'ratio', 'band']));

ALTER TABLE screens ADD COLUMN row_groups text;
COMMENT ON COLUMN screens.row_groups IS 'pareto:<metric>: rows are rank groups of the items, not items';

INSERT INTO schema_migrations (version) VALUES ('008_band_metrics');
COMMIT;
