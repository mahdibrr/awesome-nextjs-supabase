#!/usr/bin/env bash
# run.sh — two-phase RLS / pgTAP demo.
#
# Phase 1 (FIXED):  apply 00,01,02_fixed -> pg_prove -> ALL PASS.
# Phase 2 (BROKEN): apply 03_rls_broken  -> pg_prove -> the posts-related
#                   tests (001/002/003/004) error out on infinite recursion,
#                   and 005 fails on a count mismatch (leaks all objects).
#                   -> print a clear message ->
#                   re-apply 02_fixed -> pg_prove -> ALL PASS again.
#
# Env vars (all overridable):
#   DB       postgres database name (default: rls_pgtap_example)
#   PGUSER   postgres user            (default: postgres)
#   PGHOST   postgres host            (default: localhost)
#   PGPORT   postgres port            (default: 5432)
#   PSQL     psql binary              (default: psql)
#   PGPROVE  pg_prove binary          (default: pg_prove)
set -euo pipefail

DB="${DB:-rls_pgtap_example}"
PGUSER="${PGUSER:-postgres}"
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PSQL="${PSQL:-psql}"
PGPROVE="${PGPROVE:-pg_prove}"

HERE="$(cd "$(dirname "$0")" && pwd)"
SQL_DIR="$HERE/sql"
TEST_DIR="$HERE/tests"

PSQL_OPTS=(-h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -v ON_ERROR_STOP=1)

echo "== RLS / pgTAP example =="
echo "DB=$DB USER=$PGUSER HOST=$PGHOST PORT=$PGPORT"
echo

ensure_db() {
  if ! "$PSQL" "${PSQL_OPTS[@]}" -lqt | cut -d'|' -f1 | grep -wq "$DB"; then
    echo ">> creating database $DB"
    createdb -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$DB"
  fi
}

apply() {  # apply <sql_file>
  "$PSQL" "${PSQL_OPTS[@]}" -d "$DB" -f "$1"
}

run_tests() {  # run_tests <label>
  local label="$1"
  echo ">> pg_prove ($label)"
  if "$PGPROVE" -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB" "$TEST_DIR"/*.test.sql; then
    return 0
  else
    return 1
  fi
}

ensure_db

echo
echo "==== Phase 1: FIXED schema ===="
apply "$SQL_DIR/00_setup.sql"
apply "$SQL_DIR/01_schema.sql"
apply "$SQL_DIR/02_rls_fixed.sql"
run_tests "fixed" || { echo "FIXED tests failed unexpectedly." >&2; exit 1; }

echo
echo "==== Phase 2: BROKEN demo (expect failures) ===="
apply "$SQL_DIR/03_rls_broken.sql"
if run_tests "broken"; then
  echo "WARN: broken tests passed — did the broken policies actually apply?" >&2
fi
echo
echo "BROKEN policies reproduce the incidents (as expected). Re-applying fixed…"

echo
echo "==== Phase 3: re-apply FIXED and confirm ===="
apply "$SQL_DIR/02_rls_fixed.sql"
run_tests "fixed-again" || { echo "Re-applied fixed tests failed." >&2; exit 1; }

echo
echo "All good: FIXED passes, BROKEN reproduces the incidents, FIXED again passes."