-- DVS Metrics Catalog, migration 005: population rule kind 'classify_up'.
--   An item's class decided per group (group_level, e.g. style): QA Style Review makes a style Carryover if any
--   of its colors is, else New if any is, else Sell Down, and every color takes its style's status.
-- Run as psql (member of dvs_owner), after 004. On the DEV processor:
--   CLIENT=ucm psql -X -f ~/005_classify_up.sql
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

ALTER TABLE business_rules ADD COLUMN group_level text;
COMMENT ON COLUMN business_rules.group_level IS 'classify_up: product level the class is decided at (e.g. style)';
ALTER TABLE business_rules DROP CONSTRAINT business_rules_kind_check;
ALTER TABLE business_rules ADD CONSTRAINT business_rules_kind_check
    CHECK (kind IN ('having', 'where', 'classify', 'classify_up', 'combine'));
ALTER TABLE business_rules DROP CONSTRAINT business_rules_check1;
ALTER TABLE business_rules ADD CONSTRAINT business_rules_check1
    CHECK (kind IN ('combine', 'classify_up') OR source_id IS NOT NULL);
ALTER TABLE business_rules DROP CONSTRAINT business_rules_check3;
ALTER TABLE business_rules ADD CONSTRAINT business_rules_check3
    CHECK (kind NOT IN ('having', 'classify', 'classify_up', 'combine') OR coalesce(condition, '') <> '');
ALTER TABLE business_rules ADD CONSTRAINT business_rules_group_level_check
    CHECK (kind <> 'classify_up' OR coalesce(group_level, '') <> '');

INSERT INTO schema_migrations (version) VALUES ('005_classify_up');
COMMIT;
