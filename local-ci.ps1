#!/bin/bash

# ============================================================
#  local-ci.sh  -  Python Local CI/CD Quality Gate Runner
#  Compatible: Linux / Jenkins / Ubuntu
# ============================================================

set -e

# ── Colour helpers ──────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

write_stage() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${CYAN}  STAGE $1 : $2${NC}"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
}

invoke_stage() {
    DESCRIPTION=$1
    shift

    echo -e "${YELLOW}▶ $DESCRIPTION${NC}"
    echo "  Command: $@"
    echo ""

    "$@"

    echo ""
    echo -e "${GREEN}✔ PASS  $DESCRIPTION${NC}"
}

# ════════════════════════════════════════════════════════════
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Python Local CI/CD Pipeline – START   ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Create Virtual Environment ─────────────────────────────
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

# ── Install Dependencies ───────────────────────────────────
pip install --upgrade pip

pip install -r requirements.txt

pip install black isort flake8 mypy pytest pytest-cov bandit pip-audit build

# ── STAGE 1: Code Formatting (Black) ───────────────────────
write_stage 1 "Code Formatting Check (black)"
invoke_stage "Black formatting check" \
    python3 -m black --check --diff app/ tests/

# ── STAGE 2: Import Sorting (isort) ────────────────────────
write_stage 2 "Import Sorting Check (isort)"
invoke_stage "isort import sorting check" \
    python3 -m isort --check-only --diff app/ tests/

# ── STAGE 3: Linting (flake8) ──────────────────────────────
write_stage 3 "Linting (flake8)"
invoke_stage "Flake8 lint check" \
    python3 -m flake8 app/ tests/

# ── STAGE 4: Type Checking (mypy) ──────────────────────────
write_stage 4 "Type Checking (mypy)"
invoke_stage "mypy strict type check" \
    python3 -m mypy app/

# ── STAGE 5: Unit Tests (pytest) ───────────────────────────
write_stage 5 "Unit Tests (pytest)"
invoke_stage "pytest unit tests" \
    python3 -m pytest tests/ -v

# ── STAGE 6: Test Coverage (pytest-cov) ────────────────────
write_stage 6 "Test Coverage (pytest-cov)"
invoke_stage "Coverage check (min 80%)" \
    python3 -m pytest tests/ \
    --cov=app \
    --cov-report=term-missing \
    --cov-fail-under=80

# ── STAGE 7: Security Scan (bandit) ────────────────────────
write_stage 7 "Security Scan (bandit)"
invoke_stage "Bandit security scan" \
    python3 -m bandit -r app/ -ll

# ── STAGE 8: Dependency Vulnerability Scan ─────────────────
write_stage 8 "Dependency Vulnerability Scan (pip-audit)"
invoke_stage "pip-audit dependency scan" \
    python3 -m pip_audit

# ── STAGE 9: Build / Package Validation ────────────────────
write_stage 9 "Build / Package Validation (build)"
invoke_stage "python build package check" \
    python3 -m build --outdir dist/

# ════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   All Stages PASSED – Pipeline GREEN ✔  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Your code is ready for GitHub / Jenkins!${NC}"
echo ""
