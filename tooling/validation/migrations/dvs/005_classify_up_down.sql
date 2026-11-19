BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;
DELETE FROM business_rules WHERE kind = 'classify_up';
ALTER TABLE business_rules DROP CONSTRAINT business_rules_group_level_check;
ALTER TABLE business_rules DROP CONSTRAINT business_rules_check3;
ALTER TABLE business_rules ADD CONSTRAINT business_rules_check3
    CHECK (kind NOT IN ('having', 'classify', 'combine') OR coalesce(condition, '') <> '');
ALTER TABLE business_rules DROP CONSTRAINT business_rules_check1;
ALTER TABLE business_rules ADD CONSTRAINT business_rules_check1 CHECK (kind = 'combine' OR source_id IS NOT NULL);
ALTER TABLE business_rules DROP CONSTRAINT business_rules_kind_check;
ALTER TABLE business_rules ADD CONSTRAINT business_rules_kind_check
    CHECK (kind IN ('having', 'where', 'classify', 'combine'));
ALTER TABLE business_rules DROP COLUMN group_level;
DELETE FROM schema_migrations WHERE version = '005_classify_up';
COMMIT;
