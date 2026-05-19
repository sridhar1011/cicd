#!/usr/bin/env bash
# ============================================================
#  local-ci.sh  –  Python Local CI/CD Quality Gate Runner
#  Compatible: macOS / Linux / WSL
# ============================================================
# Usage:
#   chmod +x local-ci.sh
#   ./local-ci.sh
# ============================================================

set -euo pipefail   # Exit immediately on error, treat unset vars as errors

# ── Colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

PASS="${GREEN}✔ PASS${RESET}"
FAIL="${RED}✘ FAIL${RESET}"

# ── Helper: print stage banner ────────────────────────────────────────────────
stage() {
    local number="$1"
    local title="$2"
    echo ""
    echo -e "${CYAN}${BOLD}════════════════════════════════════════${RESET}"
    echo -e "${CYAN}${BOLD}  STAGE ${number}: ${title}${RESET}"
    echo -e "${CYAN}${BOLD}════════════════════════════════════════${RESET}"
}

# ── Helper: run command, print result, exit on failure ───────────────────────
run() {
    local description="$1"
    shift
    echo -e "${YELLOW}▶ ${description}${RESET}"
    echo -e "  Command: $*"
    echo ""
    if "$@"; then
        echo -e "\n${PASS}  ${description}"
    else
        echo -e "\n${FAIL}  ${description}"
        echo -e "${RED}Pipeline stopped. Fix the issue above and re-run.${RESET}"
        exit 1
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   Python Local CI/CD Pipeline – START   ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""

# ── STAGE 1: Code formatting check (Black) ────────────────────────────────────
stage 1 "Code Formatting Check  (black)"
run "Black formatting check" \
    python -m black --check --diff app/ tests/

# ── STAGE 2: Import sorting check (isort) ────────────────────────────────────
stage 2 "Import Sorting Check  (isort)"
run "isort import sorting check" \
    python -m isort --check-only --diff app/ tests/

# ── STAGE 3: Linting (flake8) ────────────────────────────────────────────────
stage 3 "Linting  (flake8)"
run "Flake8 lint check" \
    python -m flake8 app/ tests/

# ── STAGE 4: Type Checking (mypy) ────────────────────────────────────────────
stage 4 "Type Checking  (mypy)"
run "mypy strict type check" \
    python -m mypy app/

# ── STAGE 5: Unit Tests (pytest) ─────────────────────────────────────────────
stage 5 "Unit Tests  (pytest)"
run "pytest unit tests" \
    python -m pytest tests/ -v

# ── STAGE 6: Test Coverage (pytest-cov) ──────────────────────────────────────
stage 6 "Test Coverage  (pytest-cov)"
run "Coverage check (min 80%)" \
    python -m pytest tests/ \
        --cov=app \
        --cov-report=term-missing \
        --cov-fail-under=80

# ── STAGE 7: Security Scan (bandit) ──────────────────────────────────────────
stage 7 "Security Scan  (bandit)"
run "Bandit security scan" \
    python -m bandit -r app/ -ll

# ── STAGE 8: Dependency Vulnerability Scan (pip-audit) ───────────────────────
stage 8 "Dependency Vulnerability Scan  (pip-audit)"
run "pip-audit dependency scan" \
    python -m pip_audit

# ── STAGE 9: Build / Package Validation (build) ──────────────────────────────
stage 9 "Build / Package Validation  (build)"
run "python -m build package check" \
    python -m build --outdir dist/

# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║   All Stages PASSED – Pipeline GREEN ✔  ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  Your code is ready to push to GitHub / Jenkins!"
echo ""
