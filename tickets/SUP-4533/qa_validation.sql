-- SUP-4533 QA validation — synthesize a dup mapping row and prove the new
-- 010_products.sql block detects + purges it. Uses a fake test id
-- (ZZTEST_SUP4533_A) so it can't collide with real Torrid data.
-- Run on: TRD QA Vertica.

-- ============== 1) SETUP: synthesize the duplicate ==============
-- Simulates: Day 1 stylecolor sent with blank S5_ID -> raw code persisted
-- as id.  Day 2 same stylecolor backfilled with a real S5_ID -> 2nd row.

INSERT INTO TRD_REF_S5_CLIENT_ID_MAPPING (s5_id, client_erp_id, levelid)
  VALUES ('ZZTEST_SUP4533_A', 'ZZTEST_SUP4533_A', 'stylecolor');
INSERT INTO TRD_REF_S5_CLIENT_ID_MAPPING (s5_id, client_erp_id, levelid)
  VALUES ('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', 'ZZTEST_SUP4533_A', 'stylecolor');
commit;

INSERT INTO trd_d_product_existing (id, client_id, name, description, levelid) VALUES
  ('ZZTEST_SUP4533_A', 'ZZTEST_SUP4533_A', 'ZZTEST NAME', 'ZZTEST DESC', 'stylecolor');
INSERT INTO trd_h_prodstd_existing (id, ancestor0) VALUES
  ('ZZTEST_SUP4533_A', 'ZZTEST_PARENT');
INSERT INTO trd_ma_styleattributes_existing (product) VALUES ('ZZTEST_SUP4533_A');
INSERT INTO trd_ma_stylecolorattributes_existing (product) VALUES ('ZZTEST_SUP4533_A');
INSERT INTO trd_ma_sizeattributes_existing (product, sizeattribute) VALUES ('ZZTEST_SUP4533_A', 'TEST');
commit;

-- ============== 2) PRE-STATE PROOF ==============
-- Expect: 1 row, count=2 (the duplicate)
SELECT client_erp_id, COUNT(*) FROM TRD_REF_S5_CLIENT_ID_MAPPING
WHERE client_erp_id = 'ZZTEST_SUP4533_A' GROUP BY client_erp_id;

-- Expect: all five counts = 1 (the stale rows exist)
SELECT 'd_product' t, count(*) c FROM trd_d_product_existing WHERE id = 'ZZTEST_SUP4533_A'
UNION ALL SELECT 'h_prodstd', count(*) FROM trd_h_prodstd_existing WHERE id = 'ZZTEST_SUP4533_A'
UNION ALL SELECT 'styleattr', count(*) FROM trd_ma_styleattributes_existing WHERE product = 'ZZTEST_SUP4533_A'
UNION ALL SELECT 'stylecolorattr', count(*) FROM trd_ma_stylecolorattributes_existing WHERE product = 'ZZTEST_SUP4533_A'
UNION ALL SELECT 'sizeattr', count(*) FROM trd_ma_sizeattributes_existing WHERE product = 'ZZTEST_SUP4533_A';

-- ============== 3) RUN THE NEW FIX BLOCK (verbatim from 010_products.sql) ==============
DROP TABLE IF EXISTS TRD_REF_DUP_CLIENT_ERP_IDS;
CREATE TABLE TRD_REF_DUP_CLIENT_ERP_IDS AS
SELECT client_erp_id, COUNT(*) AS bad_record_count
FROM TRD_REF_S5_CLIENT_ID_MAPPING
GROUP BY client_erp_id
HAVING COUNT(*) > 1;

DELETE FROM trd_d_product_existing WHERE id IN (SELECT client_erp_id FROM TRD_REF_DUP_CLIENT_ERP_IDS);
DELETE FROM trd_h_prodstd_existing WHERE id IN (SELECT client_erp_id FROM TRD_REF_DUP_CLIENT_ERP_IDS);
DELETE FROM trd_ma_styleattributes_existing WHERE product IN (SELECT client_erp_id FROM TRD_REF_DUP_CLIENT_ERP_IDS);
DELETE FROM trd_ma_stylecolorattributes_existing WHERE product IN (SELECT client_erp_id FROM TRD_REF_DUP_CLIENT_ERP_IDS);
DELETE FROM trd_ma_sizeattributes_existing WHERE product IN (SELECT client_erp_id FROM TRD_REF_DUP_CLIENT_ERP_IDS);
commit;

-- ============== 4) POST-STATE PROOF ==============
-- Expect: 1 row -- ZZTEST_SUP4533_A, 2  (proves detection worked)
SELECT * FROM TRD_REF_DUP_CLIENT_ERP_IDS;

-- Expect: all five counts = 0  (proves the stale row was purged everywhere)
SELECT 'd_product' t, count(*) c FROM trd_d_product_existing WHERE id = 'ZZTEST_SUP4533_A'
UNION ALL SELECT 'h_prodstd', count(*) FROM trd_h_prodstd_existing WHERE id = 'ZZTEST_SUP4533_A'
UNION ALL SELECT 'styleattr', count(*) FROM trd_ma_styleattributes_existing WHERE product = 'ZZTEST_SUP4533_A'
UNION ALL SELECT 'stylecolorattr', count(*) FROM trd_ma_stylecolorattributes_existing WHERE product = 'ZZTEST_SUP4533_A'
UNION ALL SELECT 'sizeattr', count(*) FROM trd_ma_sizeattributes_existing WHERE product = 'ZZTEST_SUP4533_A';

-- NOTE: TRD_REF_S5_CLIENT_ID_MAPPING itself still shows 2 rows for our test id
-- at this point -- that's expected. The mapping table only gets rebuilt in the
-- REBUILD step that follows in the real script (pre-existing, unchanged code
-- reading from TRD_IN_PRD_MASTER/TRD_IN_PRD_HIER), which this synthetic test
-- doesn't exercise since ZZTEST_SUP4533_A isn't a real inbound row. The new
-- logic under test -- detect + purge -- is fully proven by steps 3-4 above.

-- ============== 5) CLEANUP ==============
DELETE FROM TRD_REF_S5_CLIENT_ID_MAPPING WHERE client_erp_id = 'ZZTEST_SUP4533_A';
DELETE FROM TRD_REF_DUP_CLIENT_ERP_IDS WHERE client_erp_id = 'ZZTEST_SUP4533_A';
commit;
