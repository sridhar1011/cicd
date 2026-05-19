# ============================================================
#  local-ci.ps1  -  Python Local CI/CD Quality Gate Runner
#  Compatible: Windows PowerShell 5.1+ / PowerShell 7+
# ============================================================
# Usage (run in PowerShell):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\local-ci.ps1
# ============================================================

$ErrorActionPreference = "Stop"

# ── Colour helpers ─────────────────────────────────────────────────────────────
function Write-Stage {
    param([string]$Number, [string]$Title)
    Write-Host ""
    Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  STAGE $Number : $Title" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
}

function Invoke-Stage {
    param(
        [string]$Description,
        [string[]]$Command
    )
    Write-Host "▶ $Description" -ForegroundColor Yellow
    Write-Host "  Command: $($Command -join ' ')" -ForegroundColor Gray
    Write-Host ""

    & $Command[0] $Command[1..($Command.Length - 1)]

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "✘ FAIL  $Description" -ForegroundColor Red
        Write-Host "Pipeline stopped. Fix the issue above and re-run." -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "✔ PASS  $Description" -ForegroundColor Green
}

# ══════════════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗"
Write-Host "║   Python Local CI/CD Pipeline – START   ║"
Write-Host "╚══════════════════════════════════════════╝"
Write-Host ""

# ── STAGE 1: Code Formatting (Black) ──────────────────────────────────────────
Write-Stage -Number 1 -Title "Code Formatting Check  (black)"
Invoke-Stage -Description "Black formatting check" `
    -Command @("python", "-m", "black", "--check", "--diff", "app/", "tests/")

# ── STAGE 2: Import Sorting (isort) ───────────────────────────────────────────
Write-Stage -Number 2 -Title "Import Sorting Check  (isort)"
Invoke-Stage -Description "isort import sorting check" `
    -Command @("python", "-m", "isort", "--check-only", "--diff", "app/", "tests/")

# ── STAGE 3: Linting (flake8) ─────────────────────────────────────────────────
Write-Stage -Number 3 -Title "Linting  (flake8)"
Invoke-Stage -Description "Flake8 lint check" `
    -Command @("python", "-m", "flake8", "app/", "tests/")

# ── STAGE 4: Type Checking (mypy) ─────────────────────────────────────────────
Write-Stage -Number 4 -Title "Type Checking  (mypy)"
Invoke-Stage -Description "mypy strict type check" `
    -Command @("python", "-m", "mypy", "app/")

# ── STAGE 5: Unit Tests (pytest) ──────────────────────────────────────────────
Write-Stage -Number 5 -Title "Unit Tests  (pytest)"
Invoke-Stage -Description "pytest unit tests" `
    -Command @("python", "-m", "pytest", "tests/", "-v")

# ── STAGE 6: Test Coverage (pytest-cov) ───────────────────────────────────────
Write-Stage -Number 6 -Title "Test Coverage  (pytest-cov)"
Invoke-Stage -Description "Coverage check (min 80%)" `
    -Command @("python", "-m", "pytest", "tests/",
               "--cov=app",
               "--cov-report=term-missing",
               "--cov-fail-under=80")

# ── STAGE 7: Security Scan (bandit) ───────────────────────────────────────────
Write-Stage -Number 7 -Title "Security Scan  (bandit)"
Invoke-Stage -Description "Bandit security scan" `
    -Command @("python", "-m", "bandit", "-r", "app/", "-ll")

# ── STAGE 8: Dependency Vulnerability Scan (pip-audit) ────────────────────────
Write-Stage -Number 8 -Title "Dependency Vulnerability Scan  (pip-audit)"
Invoke-Stage -Description "pip-audit dependency scan" `
    -Command @("python", "-m", "pip_audit")

# ── STAGE 9: Build / Package Validation ───────────────────────────────────────
Write-Stage -Number 9 -Title "Build / Package Validation  (build)"
Invoke-Stage -Description "python -m build package check" `
    -Command @("python", "-m", "build", "--outdir", "dist/")

# ══════════════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗"
Write-Host "║   All Stages PASSED – Pipeline GREEN ✔  ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝"
Write-Host ""
Write-Host "  Your code is ready to push to GitHub / Jenkins!" -ForegroundColor Green
Write-Host ""
