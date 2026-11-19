BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;
ALTER TABLE screens DROP COLUMN item_grain;
DELETE FROM schema_migrations WHERE version = '006_item_grain';
COMMIT;
