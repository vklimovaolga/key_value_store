
$ErrorActionPreference = "Stop"

Write-Host "`nBuilding Key Value Store release..." -ForegroundColor Cyan

# Build the release using Rebar3
Push-Location $PSScriptRoot

try {
    & rebar3 release

    if ($LASTEXITCODE -ne 0) {
        throw "Rebar3 release failed."
    }

    # Locate the generated release
    $releasePath = Join-Path $PSScriptRoot "_build\default\rel\key_value_store"

    if (-not (Test-Path $releasePath)) {
        throw "Release directory was not found."
    }

    # Locate the included Erlang runtime
    $ertsDirectory = Get-ChildItem $releasePath -Directory -Filter "erts-*" |
        Select-Object -First 1

    if (-not $ertsDirectory) {
        throw "Included Erlang runtime was not found."
    }

    # Find the installed werl.exe
    $werlCommand = Get-Command werl.exe -ErrorAction Stop
    $werlSource = $werlCommand.Source

    # Copy werl.exe into the release runtime
    $destination = Join-Path $ertsDirectory.FullName "bin\werl.exe"

    Copy-Item $werlSource $destination -Force

    Write-Host "`nRelease created successfully!" -ForegroundColor Green
    Write-Host "werl.exe copied successfully." -ForegroundColor Green
    Write-Host "`nYou can now start the release with:" -ForegroundColor Cyan
    Write-Host ".\_build\default\rel\key_value_store\bin\key_value_store.cmd console"
}
finally {
    Pop-Location
}
