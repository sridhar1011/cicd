#!/bin/bash

set -e

echo "Starting Python CI/CD Pipeline"

rm -rf venv

python3 -m venv venv

source venv/bin/activate

python3 -m pip install --upgrade pip

python3 -m pip install -r requirements.txt

python3 -m pip install \
black \
isort \
flake8 \
mypy \
pytest \
pytest-cov \
bandit \
pip-audit \
build

echo "STAGE 1 - BLACK"
python3 -m black --check --diff app/ tests/

echo "STAGE 2 - ISORT"
python3 -m isort --check-only --diff app/ tests/

echo "STAGE 3 - FLAKE8"
python3 -m flake8 app/ tests/

echo "STAGE 4 - MYPY"
python3 -m mypy app/

echo "STAGE 5 - PYTEST"
python3 -m pytest tests/ -v

echo "STAGE 6 - COVERAGE"
python3 -m pytest tests/ \
--cov=app \
--cov-report=term-missing \
--cov-fail-under=80

echo "STAGE 7 - BANDIT"
python3 -m bandit -r app/ -ll

echo "STAGE 8 - PIP AUDIT"
python3 -m pip_audit

echo "STAGE 9 - BUILD"
python3 -m build --outdir dist/

echo "PIPELINE SUCCESS"

echo "STAGE 10 - BUILD DOCKER IMAGE"

docker build -t python-cicd-demo .
