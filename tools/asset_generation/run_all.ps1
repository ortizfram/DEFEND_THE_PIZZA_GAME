# Rebuild DTP-3D-003 Munchie A/B sources, renders, comparison and A export (Blender, no add-ons).
param([string]$Blender = 'C:\Program Files\Blender Foundation\Blender 5.2\blender.exe')
$ErrorActionPreference = 'Stop'
$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not (Test-Path $Blender)) { throw "Blender not found at '$Blender'. Install from https://www.blender.org/download/ or pass -Blender <path>." }
Push-Location $Repo
try {
    foreach ($s in @('build_munchie_a.py', 'build_munchie_b.py', 'render_compare.py')) {
        & $Blender -b --factory-startup --python-exit-code 1 --python "tools/asset_generation/$s"
        if ($LASTEXITCODE -ne 0) { throw "$s failed ($LASTEXITCODE)" }
    }
    & $Blender -b --factory-startup --python-exit-code 1 --python 'tools/asset_generation/export_munchie.py' -- A
    if ($LASTEXITCODE -ne 0) { throw "export failed ($LASTEXITCODE)" }
    python tools/validate_art_manifest.py
} finally { Pop-Location }
