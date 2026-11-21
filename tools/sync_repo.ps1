# Sincronizacion segura con GitHub para DEFEND_THE_PIZZA_GAME.
param(
    [ValidateSet('Status','Pull','Push')][string]$Mode = 'Status',
    [string]$Message = ''
)
$ErrorActionPreference = 'Stop'
$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Git {
    $gitArgs = @($args)
    $out = & git -C $Repo @gitArgs
    if ($LASTEXITCODE -ne 0) { throw "git $($gitArgs -join ' ') failed ($LASTEXITCODE)" }
    return $out
}

$branch = [string](Git @('branch','--show-current'))
if ($branch.Trim() -ne 'main') { throw "Expected main, currently '$branch'. Stop to prevent changes to the wrong branch." }
$remote = [string](Git @('remote','get-url','origin'))
$remote = $remote.Trim()
$expected = '^(https://github\.com/|git@github\.com:|ssh://git@github\.com/)ortizfram/DEFEND_THE_PIZZA_GAME(\.git)?/?$'
if ($remote -notmatch $expected) { throw "Unrecognized origin: $remote. Refusing sync." }

Git @('fetch','origin','main') | Out-Null
$local = [string](Git @('rev-parse','HEAD'))
$remoteHead = [string](Git @('rev-parse','origin/main'))
$behind = [int]([string](Git @('rev-list','--count','HEAD..origin/main'))).Trim()
$ahead = [int]([string](Git @('rev-list','--count','origin/main..HEAD'))).Trim()
$dirty = @((Git @('status','--porcelain')))
Write-Host "Repo: $Repo"
Write-Host "Origin: $remote"
Write-Host "Branch: main | local: $local | origin/main: $remoteHead"
Write-Host "Ahead: $ahead | Behind: $behind | Changed paths: $($dirty.Count)"

if ($Mode -eq 'Status') {
    Git @('status','-sb')
    exit 0
}
if ($Mode -eq 'Pull') {
    if ($dirty.Count -gt 0) { throw 'Working tree not clean. Commit/reconcile changes before pulling.' }
    if ($ahead -gt 0 -and $behind -gt 0) { throw 'Branches have diverged. No automatic rebase or force.' }
    Git @('merge','--ff-only','origin/main')
    Write-Host 'Pulled with fast-forward (or already up to date).'
    exit 0
}
# Push: never overwrite remote changes.
if ($behind -gt 0) { throw 'Remote has changes absent locally. Pull/review first; no auto overwrite.' }
if ($dirty.Count -gt 0) {
    if ([string]::IsNullOrWhiteSpace($Message)) { throw 'Message required to commit local changes. Inspect git diff first.' }
    Git @('diff','--check') | Out-Null
    Git @('add','--all') | Out-Null
    Git @('diff','--cached','--check') | Out-Null
    Git @('commit','-m',$Message) | Out-Null
}
Git @('push','-u','origin','main') | Out-Null
# Confirm remote branch after push.
Git @('fetch','origin','main') | Out-Null
$nowLocal = [string](Git @('rev-parse','HEAD'))
$nowRemote = [string](Git @('rev-parse','origin/main'))
if ($nowLocal.Trim() -ne $nowRemote.Trim()) { throw 'Push not confirmed: remote does not match local HEAD.' }
Write-Host "REMOTE PUSH CONFIRMED: $($nowLocal.Trim())"
