-- DVS Metrics Catalog, migration 004: which items are a screen's rows.
--   row_periods  periods whose items are rows: 'ty' (default) or 'ty,ly' (TY items + LY-only items)
--   row_filter   condition on the screen's metrics at its grain, e.g. 'avail_inv_u > 0 OR strcntwk@ly > 0'
-- Run as psql (member of dvs_owner), after 003. On the DEV processor:
--   CLIENT=ucm psql -X -f ~/004_screen_rows.sql
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

ALTER TABLE screens ADD COLUMN row_periods text NOT NULL DEFAULT 'ty'
    CHECK (row_periods ~ '^(ty|ly|lly)(,(ty|ly|lly))*$');
ALTER TABLE screens ADD COLUMN row_filter text;
COMMENT ON COLUMN screens.row_periods IS 'periods whose items are the screen rows: ty, or ty,ly (TY + LY-only items)';
COMMENT ON COLUMN screens.row_filter IS 'condition on screen metrics at its grain; name@ly for other periods';

INSERT INTO schema_migrations (version) VALUES ('004_screen_rows');
COMMIT;
