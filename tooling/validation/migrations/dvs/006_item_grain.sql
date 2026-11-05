-- DVS Metrics Catalog, migration 006: a screen's item grain.
--   item_grain  'stylecolor' (default) or 'sku': SKU screens (Size Views) take their items from the SKU
--               hierarchy (dimensions.json product_sku, QA history_base_tables_sku.ftl).
-- Run as psql (member of dvs_owner), after 005. On the DEV processor:
--   CLIENT=ucm psql -X -f ~/006_item_grain.sql
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

ALTER TABLE screens ADD COLUMN item_grain text NOT NULL DEFAULT 'stylecolor' CHECK (item_grain IN ('stylecolor', 'sku'));
COMMENT ON COLUMN screens.item_grain IS 'grain of the screen items: stylecolor or sku (SKU hierarchy, size level)';

INSERT INTO schema_migrations (version) VALUES ('006_item_grain');
COMMIT;
