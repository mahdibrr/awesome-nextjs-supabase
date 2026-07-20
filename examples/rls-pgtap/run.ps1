# run.ps1 — two-phase RLS / pgTAP demo (PowerShell).
#
# Phase 1 (FIXED):  apply 00,01,02_fixed -> pg_prove -> ALL PASS.
# Phase 2 (BROKEN): apply 03_rls_broken  -> pg_prove -> the posts-related
#                  tests (001/002/003/004) error out on infinite recursion,
#                  and 005 fails on a count mismatch (leaks all objects).
#                  -> print a clear message ->
#                  re-apply 02_fixed -> pg_prove -> ALL PASS again.
#
# Env vars (all overridable):
#   DB       postgres database name (default: rls_pgtap_example)
#   PGUSER   postgres user            (default: postgres)
#   PGHOST   postgres host            (default: localhost)
#   PGPORT   postgres port            (default: 5432)
#   PSQL     psql binary              (default: psql)
#   PGPROVE  pg_prove binary          (default: pg_prove)

[CmdletBinding()]
param(
  [string]$DB       = $(if ($env:DB)       { $env:DB }       else { 'rls_pgtap_example' }),
  [string]$PGUSER   = $(if ($env:PGUSER)   { $env:PGUSER }   else { 'postgres' }),
  [string]$PGHOST   = $(if ($env:PGHOST)   { $env:PGHOST }   else { 'localhost' }),
  [int]   $PGPORT   = $(if ($env:PGPORT)   { [int]$env:PGPORT } else { 5432 }),
  [string]$PSQL     = $(if ($env:PSQL)     { $env:PSQL }     else { 'psql' }),
  [string]$PGPROVE  = $(if ($env:PGPROVE)  { $env:PGPROVE }  else { 'pg_prove' })
)

$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$SqlDir  = Join-Path $Here 'sql'
$TestDir = Join-Path $Here 'tests'

Write-Host "== RLS / pgTAP example =="
Write-Host "DB=$DB USER=$PGUSER HOST=$PGHOST PORT=$PGPORT"
Write-Host ""

function Ensure-Db {
  $list = & $PSQL -h $PGHOST -p $PGPORT -U $PGUSER -lqt 2>$null
  $names = $list | ForEach-Object { ($_ -split '\|')[0].Trim() }
  if ($names -notcontains $DB) {
    Write-Host ">> creating database $DB"
    & createdb -h $PGHOST -p $PGPORT -U $PGUSER $DB
    if ($LASTEXITCODE -ne 0) { throw "createdb failed" }
  }
}

function Apply([string]$file) {
  & $PSQL -h $PGHOST -p $PGPORT -U $PGUSER -v ON_ERROR_STOP=1 -d $DB -f $file
  if ($LASTEXITCODE -ne 0) { throw "psql apply failed: $file" }
}

function Run-Tests([string]$label) {
  Write-Host ">> pg_prove ($label)"
  & $PGPROVE -h $PGHOST -p $PGPORT -U $PGUSER -d $DB (Join-Path $TestDir '*.test.sql')
  if ($LASTEXITCODE -eq 0) { return $true } else { return $false }
}

Ensure-Db

Write-Host ""
Write-Host "==== Phase 1: FIXED schema ===="
Apply (Join-Path $SqlDir '00_setup.sql')
Apply (Join-Path $SqlDir '01_schema.sql')
Apply (Join-Path $SqlDir '02_rls_fixed.sql')
if (-not (Run-Tests 'fixed')) { throw "FIXED tests failed unexpectedly." }

Write-Host ""
Write-Host "==== Phase 2: BROKEN demo (expect failures) ===="
Apply (Join-Path $SqlDir '03_rls_broken.sql')
[void](Run-Tests 'broken')
Write-Host ""
Write-Host "BROKEN policies reproduce the incidents (as expected). Re-applying fixed..."

Write-Host ""
Write-Host "==== Phase 3: re-apply FIXED and confirm ===="
Apply (Join-Path $SqlDir '02_rls_fixed.sql')
if (-not (Run-Tests 'fixed-again')) { throw "Re-applied fixed tests failed." }

Write-Host ""
Write-Host "All good: FIXED passes, BROKEN reproduces the incidents, FIXED again passes."