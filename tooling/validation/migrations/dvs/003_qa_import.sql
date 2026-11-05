-- DVS Metrics Catalog, migration 003: rows imported from a client's QA config.
--   origin 'qa_import'  added by core/qa_import.py (drafts; the catalog stays the owner)
--   qa_ref              where in QA it came from: pivot column, config pull, formula hash
-- Run as psql (member of dvs_owner), after 002:
--   /usr/bin/psql -X "host=172.16.50.218 port=5432 dbname=ucm user=psql sslmode=require" -f 003_qa_import.sql
BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['sources', 'measures', 'metrics', 'business_rules', 'screens', 'bindings'] LOOP
        EXECUTE format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I', t, t || '_origin_check');
        EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I CHECK (origin IN (''ucm_sync'', ''dvs_ui'', ''seed'', ''qa_import''))',
                       t, t || '_origin_check');
        EXECUTE format('ALTER TABLE %I ADD COLUMN qa_ref jsonb', t);
        EXECUTE format('COMMENT ON COLUMN %I.qa_ref IS %L', t,
                       'qa_import provenance: {from: pivot:column, config_dir, ran_at, hash of the imported definition}');
    END LOOP;
END $$;

INSERT INTO schema_migrations (version) VALUES ('003_qa_import');
COMMIT;
