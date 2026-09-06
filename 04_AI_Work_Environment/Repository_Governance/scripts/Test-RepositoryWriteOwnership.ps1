[CmdletBinding()]
param(
    [string]$MatrixPath = (Join-Path $PSScriptRoot '../ownership-matrix.json')
)
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'RepositoryGovernance.psm1') -Force
$schemaPath = Join-Path $PSScriptRoot '../schemas/repository_write_ownership.schema.json'
if (-not (Test-Json -LiteralPath $MatrixPath -SchemaFile $schemaPath -ErrorAction Stop)) { throw 'OWNERSHIP_MATRIX_SCHEMA_FAIL' }
Test-RepositoryOwnershipMatrix -MatrixPath $MatrixPath
