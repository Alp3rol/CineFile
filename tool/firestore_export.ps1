param(
    [string]$ProjectId = 'cinefile-6252a',
    [Parameter(Mandatory = $true)][string]$Bucket,
    [string]$Database = '(default)',
    [switch]$Execute,
    [string]$Confirmation = ''
)

$ErrorActionPreference = 'Stop'

if ($ProjectId -notmatch '^[a-z][a-z0-9-]{4,28}[a-z0-9]$') {
    throw 'ProjectId has an invalid format.'
}
if ($Bucket -notmatch '^gs://[a-z0-9][a-z0-9._-]{1,220}[a-z0-9]$') {
    throw 'Bucket must be an explicit gs:// bucket with no wildcard or path.'
}
if ($Database -notmatch '^\([a-z]+\)$|^[a-z][a-z0-9-]{2,62}$') {
    throw 'Database has an invalid format.'
}

$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$destination = "$Bucket/cinefile-managed-exports/$stamp"
$arguments = @(
    'firestore', 'export', $destination,
    "--database=$Database",
    "--project=$ProjectId",
    '--quiet'
)

Write-Output "Project:     $ProjectId"
Write-Output "Database:    $Database"
Write-Output "Destination: $destination"
Write-Output "Scope:       entire database (all collection groups and subcollections)"
Write-Output "Command:     gcloud $($arguments -join ' ')"

if (-not $Execute) {
    Write-Output 'PLAN ONLY: no export was started. Add -Execute with the exact confirmation.'
    return
}

$expected = "BACKUP $ProjectId"
if ($Confirmation -cne $expected) {
    throw "Execution requires -Confirmation '$expected'."
}
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    throw 'gcloud is not installed. Use Google Cloud Shell or install Google Cloud CLI.'
}

$activeProject = (& gcloud config get-value project 2>$null).Trim()
if ($activeProject -ne $ProjectId) {
    throw "Active gcloud project is '$activeProject', expected '$ProjectId'."
}

& gcloud @arguments
if ($LASTEXITCODE -ne 0) { throw "Firestore export failed with exit code $LASTEXITCODE." }
Write-Output "EXPORT COMPLETE: $destination"
