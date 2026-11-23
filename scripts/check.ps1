# Compile the two LaTeX assets and fail on any error, overfull box, or undefined reference.
#
#   pwsh -File scripts/check.ps1            # use xelatex from PATH
#   pwsh -File scripts/check.ps1 -XeLaTeX "C:\path\to\xelatex.exe"
#
# Exit code 0 means both files compiled cleanly.

param(
    [string]$XeLaTeX = "xelatex"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$work = Join-Path $root "_check"
$targets = @(
    @{ Name = "report-template";  Path = "assets/latex/report-template.tex"  },
    @{ Name = "figure-snippets";  Path = "assets/latex/figure-snippets.tex"  }
)

function Invoke-XeLaTeX([string]$tex, [string]$dir) {
    Push-Location $dir
    try {
        # Two passes so that references and labels settle.
        & $XeLaTeX -interaction=nonstopmode -halt-on-error "main.tex" *> $null
        & $XeLaTeX -interaction=nonstopmode "main.tex" *> $null
        return (Test-Path "main.pdf")
    }
    finally {
        Pop-Location
    }
}

if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work | Out-Null

$failed = 0
foreach ($t in $targets) {
    $src = Join-Path $root $t.Path
    if (-not (Test-Path $src)) {
        Write-Host ("MISSING  {0}" -f $t.Path) -ForegroundColor Red
        $failed++
        continue
    }

    $dir = Join-Path $work $t.Name
    New-Item -ItemType Directory -Path $dir | Out-Null
    Copy-Item $src (Join-Path $dir "main.tex")

    $ok = Invoke-XeLaTeX "main.tex" $dir
    if (-not $ok) {
        Write-Host ("FAIL     {0}  (no PDF produced)" -f $t.Name) -ForegroundColor Red
        $failed++
        continue
    }

    $log = Join-Path $dir "main.log"
    $issues = @()
    if (Test-Path $log) {
        $issues = Select-String -Path $log -Pattern '^!|Overfull|Underfull|undefined' |
                  ForEach-Object { $_.Line.Trim() }
    }

    $pages = (Select-String -Path $log -Pattern 'Output written on .*\((\d+) page' |
              Select-Object -First 1).Matches.Groups[1].Value

    if ($issues.Count -gt 0) {
        Write-Host ("FAIL     {0}  ({1} issue(s))" -f $t.Name, $issues.Count) -ForegroundColor Red
        $issues | Select-Object -First 10 | ForEach-Object { Write-Host ("         " + $_) }
        $failed++
    }
    else {
        Write-Host ("OK       {0}  ({1} pages)" -f $t.Name, $pages) -ForegroundColor Green
    }
}

Remove-Item $work -Recurse -Force
if ($failed -gt 0) {
    Write-Host ("{0} target(s) failed" -f $failed) -ForegroundColor Red
    exit 1
}
Write-Host "all targets compiled cleanly" -ForegroundColor Green
exit 0
