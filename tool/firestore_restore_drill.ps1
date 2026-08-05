param(
    [Parameter(Mandatory = $true)][string]$SourceExport,
    [Parameter(Mandatory = $true)][string]$TargetProjectId,
    [string]$Database = '(default)',
    [switch]$Execute,
    [string]$Confirmation = ''
)

$ErrorActionPreference = 'Stop'
$productionProject = 'cinefile-6252a'

if ($TargetProjectId -eq $productionProject) {
    throw 'Restore drill refuses the production project. Use a separate empty test project.'
}
if ($TargetProjectId -notmatch '^[a-z][a-z0-9-]{4,28}[a-z0-9]$') {
    throw 'TargetProjectId has an invalid format.'
}
if ($SourceExport -notmatch '^gs://[a-z0-9][a-z0-9._-]+/.+') {
    throw 'SourceExport must be an explicit gs:// export path, not only a bucket.'
}
if ($Database -notmatch '^\([a-z]+\)$|^[a-z][a-z0-9-]{2,62}$') {
    throw 'Database has an invalid format.'
}

$arguments = @(
    'firestore', 'import', $SourceExport,
    "--database=$Database",
    "--project=$TargetProjectId",
    '--quiet'
)

Write-Output "Source:   $SourceExport"
Write-Output "Target:   $TargetProjectId / $Database"
Write-Output 'Behavior: merges documents; matching document IDs are overwritten; unrelated target documents remain.'
Write-Output "Command:  gcloud $($arguments -join ' ')"

if (-not $Execute) {
    Write-Output 'PLAN ONLY: no import was started. Add -Execute with the exact confirmation.'
    return
}

$expected = "RESTORE $TargetProjectId"
if ($Confirmation -cne $expected) {
    throw "Execution requires -Confirmation '$expected'."
}
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    throw 'gcloud is not installed. Use Google Cloud Shell or install Google Cloud CLI.'
}

$activeProject = (& gcloud config get-value project 2>$null).Trim()
if ($activeProject -ne $TargetProjectId) {
    throw "Active gcloud project is '$activeProject', expected '$TargetProjectId'."
}

& gcloud @arguments
if ($LASTEXITCODE -ne 0) { throw "Firestore import failed with exit code $LASTEXITCODE." }
Write-Output 'RESTORE DRILL IMPORT COMPLETE. Continue with the count and sample checks in FIRESTORE_DISASTER_RECOVERY.md.'
