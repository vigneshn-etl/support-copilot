#!/bin/bash
#
# SUP-4493 -- Validation script for the GROUP BY dedup fix.
# See dedup-fix-testing-doc.md in this same directory for the full test plan.
#
# Only touches test_store_master_new_pre (read) and creates
# test_store_master_new_tbl_dedup (new) -- never touches any prod-facing table.

set -eux
set -o pipefail

echo "=== Step 0/1: baseline -- confirm duplicates exist in test_store_master_new_pre ==="

DUP_COUNT_BEFORE=$(clickhouse-client --query="
SELECT count() FROM (
    SELECT product, channel, location, time
    FROM test_store_master_new_pre
    GROUP BY product, channel, location, time
    HAVING count(1) > 1
)
")
echo "DUP_COUNT_BEFORE=${DUP_COUNT_BEFORE}"

TOTAL_ROWS_BEFORE=$(clickhouse-client --query="SELECT count() FROM test_store_master_new_pre")
echo "TOTAL_ROWS_BEFORE=${TOTAL_ROWS_BEFORE}"

DISTINCT_KEYS_BEFORE=$(clickhouse-client --query="
SELECT countDistinct((product, channel, location, time)) FROM test_store_master_new_pre
")
echo "DISTINCT_KEYS_BEFORE=${DISTINCT_KEYS_BEFORE}"

if [ "${DUP_COUNT_BEFORE}" -eq 0 ]; then
    echo "WARNING: no duplicates found in test_store_master_new_pre -- this table needs"
    echo "to be rebuilt with the reproduced bug (see root-cause repro steps) before this"
    echo "validation is meaningful. Stopping."
    exit 1
fi

echo "=== Step 2: run the dedup GROUP BY fix into test_store_master_new_tbl_dedup ==="

clickhouse-client --query="DROP TABLE IF EXISTS test_store_master_new_tbl_dedup"
clickhouse-client --query="
CREATE TABLE test_store_master_new_tbl_dedup ENGINE = MergeTree ORDER BY tuple() AS
SELECT
    product,
    channel,
    location,
    time,
    any(aps_index) AS aps_index,
    any(grade) AS grade,
    any(bi) AS bi,
    any(strclimate) AS strclimate,
    any(strmenscapacity) AS strmenscapacity,
    any(strwomenscapacity) AS strwomenscapacity,
    any(indx) AS indx,
    any(eventdate) AS eventdate
FROM test_store_master_new_pre
GROUP BY product, channel, location, time
"

echo "=== Step 3: row count after dedup (expect == DISTINCT_KEYS_BEFORE) ==="

TOTAL_ROWS_AFTER=$(clickhouse-client --query="SELECT count() FROM test_store_master_new_tbl_dedup")
echo "TOTAL_ROWS_AFTER=${TOTAL_ROWS_AFTER}"

echo "=== Step 4: duplicate check after dedup (expect 0) ==="

DUP_COUNT_AFTER=$(clickhouse-client --query="
SELECT count() FROM (
    SELECT product, channel, location, time
    FROM test_store_master_new_tbl_dedup
    GROUP BY product, channel, location, time
    HAVING count(1) > 1
)
")
echo "DUP_COUNT_AFTER=${DUP_COUNT_AFTER}"

echo "=== Step 5: spot check known duplicate key CL-0781 / GP-01 / LC-0484 @ 2027_W49 (expect 1 row) ==="

clickhouse-client --query="
SELECT * FROM test_store_master_new_tbl_dedup
WHERE product = 'CL-0781' AND channel = 'GP-01' AND location = 'LC-0484' AND time = '2027_W49'
"

echo "=== SUMMARY ==="
echo "Rows before dedup:            ${TOTAL_ROWS_BEFORE}"
echo "Distinct keys before dedup:   ${DISTINCT_KEYS_BEFORE}"
echo "Duplicate groups before:      ${DUP_COUNT_BEFORE}"
echo "Rows after dedup:              ${TOTAL_ROWS_AFTER}  (expect == ${DISTINCT_KEYS_BEFORE})"
echo "Duplicate groups after:        ${DUP_COUNT_AFTER}  (expect 0)"

if [ "${TOTAL_ROWS_AFTER}" -eq "${DISTINCT_KEYS_BEFORE}" ] && [ "${DUP_COUNT_AFTER}" -eq 0 ]; then
    echo "RESULT: PASS"
else
    echo "RESULT: FAIL"
    exit 1
fi
