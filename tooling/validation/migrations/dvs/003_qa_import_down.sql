-- Undo migration 003. Run as psql. Rows with origin 'qa_import' must be removed or re-labelled first.
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['sources', 'measures', 'metrics', 'business_rules', 'screens', 'bindings'] LOOP
        EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS qa_ref', t);
        EXECUTE format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I', t, t || '_origin_check');
        EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I CHECK (origin IN (''ucm_sync'', ''dvs_ui'', ''seed''))',
                       t, t || '_origin_check');
    END LOOP;
END $$;

DELETE FROM schema_migrations WHERE version = '003_qa_import';
COMMIT;
