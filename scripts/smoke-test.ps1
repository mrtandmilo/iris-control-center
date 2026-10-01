param(
    [string]$BaseUrl = "http://localhost:52773",
    [string]$IrisUser = "_SYSTEM",
    [string]$IrisPassword = $env:IRIS_PASSWORD
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($IrisPassword)) {
    throw "Set IRIS_PASSWORD before running this validation script."
}

$pair = "${IrisUser}:${IrisPassword}"
$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
$headers = @{ Authorization = "Basic $token"; Accept = "application/json" }

Write-Host "[1/2] Checking Control Center health"
$health = Invoke-RestMethod -Uri "$BaseUrl/iris-control-center/api/health" -Headers $headers -Method Get
if ($health.status -ne "ok") { throw "Expected health status 'ok', got '$($health.status)'." }
if ($health.application -ne "IRIS Control Center") { throw "Unexpected application '$($health.application)'." }

Write-Host "[2/2] Checking live service discovery"
$services = Invoke-RestMethod -Uri "$BaseUrl/iris-control-center/api/services" -Headers $headers -Method Get
if ($null -eq $services.services) { throw "Service discovery response did not contain 'services'." }
if ($null -eq $services.count) { throw "Service discovery response did not contain 'count'." }

Write-Host "IRIS Control Center Windows validation passed. Discovered $($services.count) service(s)."
Write-Host "Open $BaseUrl/iris-control-center/ and authenticate with $IrisUser and the same password."
