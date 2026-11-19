BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;
ALTER TABLE screens DROP COLUMN row_filter;
ALTER TABLE screens DROP COLUMN row_periods;
DELETE FROM schema_migrations WHERE version = '004_screen_rows';
COMMIT;
