-- DVS Metrics Catalog: schema dvs, migration 001
-- Run as an admin who is a member of dvs_owner (e.g. psql):
--   /usr/bin/psql -X "host=172.16.50.218 port=5432 dbname=ucm user=psql sslmode=require" -f 001_catalog.sql
-- Objects are owned by dvs_owner; dvs_app gets table access through the default privileges
-- set up when the schema was created (SELECT/INSERT/UPDATE/DELETE on tables, USAGE on sequences).

BEGIN;
SET LOCAL ROLE dvs_owner;
SET LOCAL search_path = dvs;

-- ---------------------------------------------------------------- migrations ledger
CREATE TABLE schema_migrations (
    version     text PRIMARY KEY,
    applied_at  timestamptz NOT NULL DEFAULT now(),
    applied_by  text        NOT NULL DEFAULT session_user
);

-- ---------------------------------------------------------------- shared columns
-- Every catalog table carries the same lifecycle columns:
--   status       draft -> approved -> retired (an edit returns a row to draft, version + 1)
--   version      bumped by the app on every content change
--   origin       where the row came from: ucm_sync | dvs_ui | seed
--   ucm_ref      the app_public row a synced row came from (tenant/env/table/key)

-- ---------------------------------------------------------------- sources
CREATE TABLE sources (
    tenant          text NOT NULL,
    environment     text NOT NULL DEFAULT 'qa',
    source_id       text NOT NULL,
    table_name      text NOT NULL,
    item_key        text NOT NULL,
    location_key    text,
    time_key        text,
    level_filters   text[] NOT NULL DEFAULT '{}',
    ucm_table_role  text,
    description     text,
    status          text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'retired')),
    version         integer NOT NULL DEFAULT 1 CHECK (version >= 1),
    origin          text NOT NULL DEFAULT 'dvs_ui' CHECK (origin IN ('ucm_sync', 'dvs_ui', 'seed')),
    ucm_ref         jsonb,
    notes           text,
    created_by      text NOT NULL DEFAULT coalesce(nullif(current_setting('dvs.user', true), ''), session_user),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    approved_by     text,
    approved_at     timestamptz,
    PRIMARY KEY (tenant, environment, source_id),
    CHECK (status <> 'approved' OR approved_by IS NOT NULL)
);

-- ---------------------------------------------------------------- measures
-- One aggregate on one source. agg_kind follows UCM meta_measure_shapes / hs-agent:
--   sum, sum_funded, last_at_max_week (EOP stock), first_at_min_week (BOP stock),
--   count_distinct, count_lastval; plus max, min, avg.
CREATE TABLE measures (
    tenant          text NOT NULL,
    environment     text NOT NULL DEFAULT 'qa',
    measure_id      text NOT NULL,
    label           text NOT NULL,
    source_id       text NOT NULL,
    expr            text NOT NULL,
    agg_kind        text NOT NULL CHECK (agg_kind IN ('sum', 'sum_funded', 'last_at_max_week',
                        'first_at_min_week', 'count_distinct', 'count_lastval', 'max', 'min', 'avg')),
    predicate       text,
    time_window     text NOT NULL DEFAULT 'selected' CHECK (time_window IN ('selected', 'receipt', 'none')),
    location_set    text NOT NULL DEFAULT 'scope' CHECK (location_set IN ('scope', 'scope_dc')),
    rollup          text NOT NULL DEFAULT 'sum' CHECK (rollup IN ('sum', 'max')),
    status          text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'retired')),
    version         integer NOT NULL DEFAULT 1 CHECK (version >= 1),
    origin          text NOT NULL DEFAULT 'dvs_ui' CHECK (origin IN ('ucm_sync', 'dvs_ui', 'seed')),
    ucm_ref         jsonb,
    notes           text,
    created_by      text NOT NULL DEFAULT coalesce(nullif(current_setting('dvs.user', true), ''), session_user),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    approved_by     text,
    approved_at     timestamptz,
    PRIMARY KEY (tenant, environment, measure_id),
    FOREIGN KEY (tenant, environment, source_id) REFERENCES sources (tenant, environment, source_id),
    CHECK (status <> 'approved' OR approved_by IS NOT NULL),
    CHECK (agg_kind NOT IN ('last_at_max_week', 'first_at_min_week', 'count_lastval') OR time_window <> 'none')
);

-- ---------------------------------------------------------------- metrics
-- What a screen shows. expr / denominator name measures and metrics, never raw SQL columns.
-- A ratio is 0 when its denominator is <= 0 (UCM business rule null_ratios = false).
CREATE TABLE metrics (
    tenant          text NOT NULL,
    environment     text NOT NULL DEFAULT 'qa',
    metric_id       text NOT NULL,
    label           text NOT NULL,
    metric_type     text NOT NULL CHECK (metric_type IN ('simple', 'derived', 'ratio')),
    expr            text NOT NULL,
    denominator     text,
    round_digits    smallint CHECK (round_digits BETWEEN 0 and 10),
    requirement     text,
    status          text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'retired')),
    version         integer NOT NULL DEFAULT 1 CHECK (version >= 1),
    origin          text NOT NULL DEFAULT 'dvs_ui' CHECK (origin IN ('ucm_sync', 'dvs_ui', 'seed')),
    ucm_ref         jsonb,
    notes           text,
    created_by      text NOT NULL DEFAULT coalesce(nullif(current_setting('dvs.user', true), ''), session_user),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    approved_by     text,
    approved_at     timestamptz,
    PRIMARY KEY (tenant, environment, metric_id),
    CHECK (status <> 'approved' OR approved_by IS NOT NULL),
    CHECK (metric_type <> 'ratio' OR coalesce(denominator, '') <> '')
);

-- ---------------------------------------------------------------- business rules
-- Which items a screen family counts. One population = ordered rules + one combine rule:
--   having    items whose totals over the window pass `condition`
--   where     items with any row matching `row_filter`
--   classify  a class per item from `condition` (e.g. flow status 0/1/2)
--   combine   boolean of rule ids, e.g. 'flow AND (hist OR onorder)'
CREATE TABLE business_rules (
    tenant          text NOT NULL,
    environment     text NOT NULL DEFAULT 'qa',
    population_id   text NOT NULL,
    rule_id         text NOT NULL,
    step            integer NOT NULL,
    kind            text NOT NULL CHECK (kind IN ('having', 'where', 'classify', 'combine')),
    source_id       text,
    time_window     text CHECK (time_window IN ('selected', 'receipt', 'none')),
    condition       text,
    row_filter      text,
    applies_when    text,
    status          text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'retired')),
    version         integer NOT NULL DEFAULT 1 CHECK (version >= 1),
    origin          text NOT NULL DEFAULT 'dvs_ui' CHECK (origin IN ('ucm_sync', 'dvs_ui', 'seed')),
    ucm_ref         jsonb,
    notes           text,
    created_by      text NOT NULL DEFAULT coalesce(nullif(current_setting('dvs.user', true), ''), session_user),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    approved_by     text,
    approved_at     timestamptz,
    PRIMARY KEY (tenant, environment, population_id, rule_id),
    UNIQUE (tenant, environment, population_id, step),
    FOREIGN KEY (tenant, environment, source_id) REFERENCES sources (tenant, environment, source_id),
    CHECK (status <> 'approved' OR approved_by IS NOT NULL),
    CHECK (kind = 'combine' OR source_id IS NOT NULL),
    CHECK (kind <> 'where' OR coalesce(row_filter, '') <> ''),
    CHECK (kind NOT IN ('having', 'classify', 'combine') OR coalesce(condition, '') <> '')
);

-- ---------------------------------------------------------------- screens
-- A data call (pivot) and the population / weeks it validates with.
CREATE TABLE screens (
    tenant          text NOT NULL,
    environment     text NOT NULL DEFAULT 'qa',
    pivot           text NOT NULL,
    population_id   text NOT NULL,
    time_mode       text NOT NULL DEFAULT 'history' CHECK (time_mode IN ('history', 'assortment')),
    split_by_class  boolean NOT NULL DEFAULT false,
    status          text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'retired')),
    version         integer NOT NULL DEFAULT 1 CHECK (version >= 1),
    origin          text NOT NULL DEFAULT 'dvs_ui' CHECK (origin IN ('ucm_sync', 'dvs_ui', 'seed')),
    ucm_ref         jsonb,
    notes           text,
    created_by      text NOT NULL DEFAULT coalesce(nullif(current_setting('dvs.user', true), ''), session_user),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    approved_by     text,
    approved_at     timestamptz,
    PRIMARY KEY (tenant, environment, pivot),
    CHECK (status <> 'approved' OR approved_by IS NOT NULL)
);

-- ---------------------------------------------------------------- bindings
-- A screen column -> the metric that validates it, plus the screen's own rollup formula.
-- metric_id NULL on a metric column = not covered yet; kind 'attribute' = display field, no metric.
CREATE TABLE bindings (
    tenant          text NOT NULL,
    environment     text NOT NULL DEFAULT 'qa',
    pivot           text NOT NULL,
    viewdefn        text NOT NULL,
    data_index      text NOT NULL,
    label           text NOT NULL,
    kind            text NOT NULL DEFAULT 'metric' CHECK (kind IN ('metric', 'attribute')),
    metric_id       text,
    rollup_formula  text,
    status          text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'retired')),
    version         integer NOT NULL DEFAULT 1 CHECK (version >= 1),
    origin          text NOT NULL DEFAULT 'dvs_ui' CHECK (origin IN ('ucm_sync', 'dvs_ui', 'seed')),
    ucm_ref         jsonb,
    notes           text,
    created_by      text NOT NULL DEFAULT coalesce(nullif(current_setting('dvs.user', true), ''), session_user),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    approved_by     text,
    approved_at     timestamptz,
    PRIMARY KEY (tenant, environment, pivot, viewdefn, data_index),
    FOREIGN KEY (tenant, environment, pivot) REFERENCES screens (tenant, environment, pivot),
    FOREIGN KEY (tenant, environment, metric_id) REFERENCES metrics (tenant, environment, metric_id),
    CHECK (status <> 'approved' OR approved_by IS NOT NULL),
    CHECK (kind <> 'attribute' OR metric_id IS NULL)
);
CREATE INDEX bindings_metric_idx ON bindings (tenant, environment, metric_id);

-- ---------------------------------------------------------------- history (append-only)
-- Filled by trigger on every insert / update / delete of a catalog row, so history holds
-- whoever writes (Studio, sync, or a person in psql). The writer names itself with
--   SELECT set_config('dvs.user', '<name>', true)   (falls back to the database login; 'user' is reserved, so not SET LOCAL)
CREATE TABLE row_history (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant      text NOT NULL,
    environment text NOT NULL,
    table_name  text NOT NULL,
    row_key     jsonb NOT NULL,
    action      text NOT NULL CHECK (action IN ('insert', 'update', 'delete')),
    version     integer,
    status      text,
    changed_by  text NOT NULL,
    changed_at  timestamptz NOT NULL DEFAULT now(),
    before      jsonb,
    after       jsonb
);
CREATE INDEX row_history_lookup_idx ON row_history (tenant, environment, table_name, row_key);

CREATE FUNCTION log_row_history() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = dvs AS $$
DECLARE
    rec  jsonb := to_jsonb(coalesce(NEW, OLD));
    keys text[] := TG_ARGV;
    k    text;
    key  jsonb := '{}'::jsonb;
BEGIN
    FOREACH k IN ARRAY keys LOOP
        key := key || jsonb_build_object(k, rec -> k);
    END LOOP;
    INSERT INTO row_history (tenant, environment, table_name, row_key, action, version, status,
                             changed_by, before, after)
    VALUES (rec ->> 'tenant', rec ->> 'environment', TG_TABLE_NAME, key, lower(TG_OP),
            (rec ->> 'version')::integer, rec ->> 'status',
            coalesce(nullif(current_setting('dvs.user', true), ''), session_user),
            CASE WHEN TG_OP <> 'INSERT' THEN to_jsonb(OLD) END,
            CASE WHEN TG_OP <> 'DELETE' THEN to_jsonb(NEW) END);
    RETURN coalesce(NEW, OLD);
END $$;

CREATE FUNCTION touch_updated() RETURNS trigger
LANGUAGE plpgsql SET search_path = dvs AS $$
BEGIN
    NEW.updated_at := now();
    NEW.updated_by := coalesce(nullif(current_setting('dvs.user', true), ''), session_user);
    RETURN NEW;
END $$;

CREATE TRIGGER sources_touch        BEFORE UPDATE ON sources        FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER measures_touch       BEFORE UPDATE ON measures       FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER metrics_touch        BEFORE UPDATE ON metrics        FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER business_rules_touch BEFORE UPDATE ON business_rules FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER screens_touch        BEFORE UPDATE ON screens        FOR EACH ROW EXECUTE FUNCTION touch_updated();
CREATE TRIGGER bindings_touch       BEFORE UPDATE ON bindings       FOR EACH ROW EXECUTE FUNCTION touch_updated();

CREATE TRIGGER sources_history        AFTER INSERT OR UPDATE OR DELETE ON sources        FOR EACH ROW EXECUTE FUNCTION log_row_history('source_id');
CREATE TRIGGER measures_history       AFTER INSERT OR UPDATE OR DELETE ON measures       FOR EACH ROW EXECUTE FUNCTION log_row_history('measure_id');
CREATE TRIGGER metrics_history        AFTER INSERT OR UPDATE OR DELETE ON metrics        FOR EACH ROW EXECUTE FUNCTION log_row_history('metric_id');
CREATE TRIGGER business_rules_history AFTER INSERT OR UPDATE OR DELETE ON business_rules FOR EACH ROW EXECUTE FUNCTION log_row_history('population_id', 'rule_id');
CREATE TRIGGER screens_history        AFTER INSERT OR UPDATE OR DELETE ON screens        FOR EACH ROW EXECUTE FUNCTION log_row_history('pivot');
CREATE TRIGGER bindings_history       AFTER INSERT OR UPDATE OR DELETE ON bindings       FOR EACH ROW EXECUTE FUNCTION log_row_history('pivot', 'viewdefn', 'data_index');

-- ---------------------------------------------------------------- UCM sync runs
CREATE TABLE sync_runs (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant       text NOT NULL,
    environment  text NOT NULL,
    ucm_env      text NOT NULL,                 -- app_public environment read, e.g. 'repo'
    started_at   timestamptz NOT NULL DEFAULT now(),
    finished_at  timestamptz,
    run_by       text NOT NULL DEFAULT coalesce(nullif(current_setting('dvs.user', true), ''), session_user),
    status       text NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'ok', 'failed')),
    dry_run      boolean NOT NULL DEFAULT true,
    counts       jsonb,                         -- {"added": n, "changed": n, "conflicts": n, "unchanged": n}
    report       jsonb,                         -- per-row diff and conflicts
    error        text
);

-- ---------------------------------------------------------------- app permissions
-- History is append-only for the app; the ledger is read-only for the app.
REVOKE UPDATE, DELETE ON row_history FROM dvs_app;
REVOKE INSERT, UPDATE, DELETE ON schema_migrations FROM dvs_app;
REVOKE ALL ON FUNCTION log_row_history() FROM PUBLIC;

INSERT INTO schema_migrations (version) VALUES ('001_catalog');

COMMIT;
