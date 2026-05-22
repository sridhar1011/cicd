# 🐍 Python CI/CD Demo — Local Quality Gates Training Guide

> **Goal:** Understand every stage of a CI/CD pipeline by running the exact same
> quality-gate commands locally — *before* any code ever reaches GitHub Actions
> or Jenkins.

---

## 📁 Project Folder Structure

```
python-cicd-demo/
├── app/
│   ├── __init__.py          ← makes 'app' a Python package
│   └── main.py              ← simple calculator application
├── tests/
│   ├── __init__.py
│   └── test_main.py         ← pytest unit tests
├── dist/                    ← created by 'python -m build' (auto-generated)
├── .flake8                  ← flake8 linter configuration
├── pyproject.toml           ← project metadata + tool settings (PEP 517/518)
├── requirements.txt         ← runtime dependencies
├── requirements-dev.txt     ← all CI/CD tools (testing, linting, security …)
├── local-ci.sh              ← one-click CI runner (Mac / Linux / WSL)
├── local-ci.ps1             ← one-click CI runner (Windows PowerShell)
└── README.md                ← this file
```

---

## 🚀 Local Setup (Do This Once)

```bash
# 1. Create a virtual environment
python -m venv venv

# 2. Activate it
source venv/bin/activate        # Mac / Linux / WSL
# OR
venv\Scripts\activate           # Windows Command Prompt / PowerShell

# 3. Install all CI/CD tools
pip install -r requirements-dev.txt

# 4. Verify tools are installed
python -m pytest --version
python -m black --version
python -m isort --version
python -m flake8 --version
python -m mypy --version
python -m bandit --version
python -m pip_audit --version
python -m build --version
```

---

## 🎯 Stage-by-Stage CI/CD Commands

Each stage below maps to one check that runs in a real CI/CD pipeline.
Run them manually so you *understand* what is happening before you automate them.

---

### ▶ Stage 1 — Run the Application Manually

**Purpose:** Confirm the application itself works before running any checks.

```bash
python -m app.main
```

**Expected output:**
```
========================================
   Welcome to Python CI/CD Calculator
========================================
  1. Add
  2. Subtract
  3. Multiply
  4. Divide
  5. Power
  6. Square Root (single number)

Select operation (1-6):
```

> **Student note:** This is the equivalent of a smoke test — does the application
> even start? In a pipeline this is sometimes called a *sanity check*.

---

### ▶ Stage 2 — Unit Tests with pytest

**What it checks:** Do all functions behave correctly?

```bash
python -m pytest tests/ -v
```

**Expected pass output:**
```
tests/test_main.py::TestAdd::test_add_two_positive_integers PASSED
tests/test_main.py::TestAdd::test_add_negative_numbers      PASSED
...
========================= 20 passed in 0.12s ==========================
```

**Expected fail output (when a test breaks):**
```
FAILED tests/test_main.py::TestAdd::test_add_two_positive_integers
AssertionError: assert 8 == 7
========================= 1 failed, 19 passed =========================
```

**Fix:** Correct the broken function or fix the wrong expected value in the test.

> **Why in CI/CD?** Tests are the first gate. If tests fail, nothing else matters.
> The pipeline must stop immediately.

---

### ▶ Stage 3 — Code Formatting with Black

**What it checks:** Is every file formatted according to Black's style rules?
Black enforces consistent spacing, line length (88 chars), and quotes.

```bash
# Check only – does NOT change files (use this in CI)
python -m black --check --diff app/ tests/

# Auto-fix – rewrites files to match Black's style (use this locally)
python -m black app/ tests/
```

**Expected pass output:**
```
All done! ✨ 🍰 ✨
2 files would be left unchanged.
```

**Expected fail output:**
```
--- app/main.py  2024-01-01 10:00:00
+++ app/main.py  2024-01-01 10:00:01
@@ -1,4 +1,4 @@
-def add( a,b ):
+def add(a, b):
Oh no! 💥 💔 💥
1 file would be reformatted.
```

**Fix:** Run `python -m black app/ tests/` to auto-format, then commit the changes.

> **Why in CI/CD?** Different developers format code differently. Black removes
> style debates entirely. Consistent style = easier code reviews.

---

### ▶ Stage 4 — Import Sorting with isort

**What it checks:** Are imports organised in the correct order?
isort groups imports as: standard library → third-party → local.

```bash
# Check only – does NOT change files (use this in CI)
python -m isort --check-only --diff app/ tests/

# Auto-fix – rewrites import blocks (use this locally)
python -m isort app/ tests/
```

**Expected pass output:**
```
Skipped 2 files
```
*(No output = everything is already sorted)*

**Expected fail output:**
```
ERROR: app/main.py Imports are incorrectly sorted and/or formatted.
--- app/main.py:before       2024-01-01
+++ app/main.py:after        2024-01-01
@@ -1,4 +1,4 @@
-import os
 from typing import Union
+import os
```

**Fix:** Run `python -m isort app/ tests/` then commit.

> **Why in CI/CD?** Unsorted imports cause unnecessary merge conflicts and make
> the codebase harder to read.

---

### ▶ Stage 5 — Linting with flake8

**What it checks:** Syntax errors, undefined variables, unused imports,
lines that are too long, and PEP-8 style violations.

```bash
python -m flake8 app/ tests/
```

**Expected pass output:**
```
(no output — silence means success)
```

**Expected fail output:**
```
app/main.py:5:1: F401 'os' imported but unused
app/main.py:22:89: E501 line too long (93 > 88 characters)
app/main.py:40:1: E302 expected 2 blank lines, found 1
```

**Common error codes:**
| Code | Meaning |
|------|---------|
| E501 | Line too long |
| E302 | Missing blank lines between functions |
| F401 | Unused import |
| F821 | Undefined variable |
| W291 | Trailing whitespace |

**Fix:** Remove unused imports, shorten long lines, add blank lines where needed.

> **Why in CI/CD?** Linting catches bugs (unused variables, missing returns)
> and enforces a baseline code quality standard across the whole team.

---

### ▶ Stage 6 — Type Checking with mypy

**What it checks:** Are type hints correct? Will passing a string where an int
is expected cause a runtime crash?

```bash
python -m mypy app/
```

**Expected pass output:**
```
Success: no issues found in 2 source files
```

**Expected fail output (missing type hint):**
```
app/main.py:10: error: Function is missing a return type annotation
app/main.py:25: error: Argument 1 to "divide" has incompatible type "str"; expected "Union[int, float]"
Found 2 errors in 1 file (checked 2 source files)
```

**Fix:** Add proper type annotations to all functions and variables.

**Before (bad):**
```python
def add(a, b):           # mypy error: missing return type
    return a + b
```

**After (good):**
```python
def add(a: float, b: float) -> float:
    return a + b
```

> **Why in CI/CD?** Type errors cause runtime crashes that are hard to debug.
> mypy catches these *before* deployment to production.

---

### ▶ Stage 7 — Security Scan with bandit

**What it checks:** Common security vulnerabilities in Python code, such as:
- Hardcoded passwords or API keys
- Use of `eval()` or `exec()` (dangerous)
- Insecure random number generation
- SQL injection patterns
- Weak cryptography

```bash
python -m bandit -r app/ -ll
```

*Flags: `-r` = recursive, `-ll` = show only MEDIUM and HIGH severity issues*

**Expected pass output:**
```
Run started: 2024-01-01 10:00:00
Test results:
        No issues identified.
Code scanned:
        Total lines of code: 65
        Total lines skipped (#nosec): 0
```

**Expected fail output (if using eval):**
```
Issue: [B307:blacklist] Use of possibly insecure function - consider using safer alternatives.
   Severity: Medium   Confidence: High
   Location: app/main.py:15
   More Info: https://bandit.readthedocs.io/en/latest/blacklists/blacklist_calls.html#b307-eval
```

**Fix:** Remove dangerous function calls, never hardcode credentials.

**Bad (bandit flags this):**
```python
result = eval(user_input)          # DANGEROUS: arbitrary code execution
password = "admin123"              # DANGEROUS: hardcoded password
```

**Good:**
```python
result = int(user_input)           # safe: explicit conversion
password = os.environ["PASSWORD"]  # safe: read from environment
```

> **Why in CI/CD?** Security vulnerabilities discovered in production cost
> 10× more to fix than if caught early. bandit is the first line of defence.

---

### ▶ Stage 8 — Dependency Vulnerability Scan with pip-audit

**What it checks:** Are any installed packages listed in public CVE (Common
Vulnerabilities and Exposures) databases? A package can be perfectly fine today
and vulnerable tomorrow when a CVE is published.

```bash
python -m pip_audit
```

**Expected pass output:**
```
No known vulnerabilities found
```

**Expected fail output:**
```
Found 1 known vulnerability in 1 package
Name        Version ID                  Fix Versions
----------- ------- ------------------- ------------
requests    2.20.0  GHSA-j8r2-6x86-q33q 2.31.0
```

**Fix:** Upgrade the vulnerable package:
```bash
pip install --upgrade requests
pip freeze > requirements.txt
```

> **Why in CI/CD?** Many high-profile data breaches were caused by outdated
> third-party libraries. This scan runs in CI so no vulnerable dependency
> ever reaches production.

---

### ▶ Stage 9 — Test Coverage with pytest-cov

**What it checks:** What percentage of your application code is actually
executed when tests run? Lines not covered by tests are potential hiding spots
for bugs.

```bash
python -m pytest tests/ --cov=app --cov-report=term-missing --cov-fail-under=80
```

**Expected pass output:**
```
---------- coverage: platform darwin, python 3.11 ----------
Name           Stmts   Miss  Cover   Missing
--------------------------------------------
app/__init__.py    1      0   100%
app/main.py       65      8    88%   72-78
--------------------------------------------
TOTAL             66      8    88%
Required test coverage of 80% reached. Total coverage: 88%
```

**Expected fail output:**
```
FAIL Required test coverage of 80% not reached. Total coverage: 45%
```

**Fix:** Write additional tests to cover the missing lines shown in the
`Missing` column.

> **Why in CI/CD?** 80% coverage is a common industry baseline. It doesn't
> guarantee bug-free code, but it ensures most logic paths are exercised.

---

### ▶ Stage 10 — Build / Package Validation with build

**What it checks:** Can the project be packaged into a distributable format?
Creates both a `.tar.gz` (source dist) and a `.whl` (wheel) file.

```bash
 
```

**Expected pass output:**
```
* Creating virtualenv isolated environment...
* Installing packages in isolated environment... (setuptools, wheel)
* Getting build dependencies for sdist...
* Building sdist...
* Building wheel from sdist
* Creating virtualenv isolated environment...
Successfully built python_cicd_demo-1.0.0.tar.gz and python_cicd_demo-1.0.0-py3-none-any.whl
```

**Expected fail output:**
```
ERROR: Missing 'name' field in pyproject.toml
```

**Fix:** Verify `pyproject.toml` has all required metadata fields (`name`,
`version`, `requires-python`).

> **Why in CI/CD?** If the build stage fails, your code cannot be deployed.
> This stage validates that packaging metadata is always correct.

---

## ⚡ One-Click CI Runner

After confirming each individual command works, run everything in sequence:

### Mac / Linux / WSL (Bash)
```bash
chmod +x local-ci.sh   # make script executable (only needed once)
./local-ci.sh
```

### Windows (PowerShell)
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\local-ci.ps1
```

The script exits immediately on the **first failure** — exactly like a real
CI/CD pipeline. Fix the error, re-run, and continue.

---

## 🐛 Intentional Mistakes Section — Learn From Failures

Introduce each mistake, run `./local-ci.sh`, and watch the pipeline break.
Then fix it and watch it go green. This is the fastest way to understand
what each tool actually does.

---

### Mistake 1 — Bad Formatting (caught by: black)

Open `app/main.py` and change:
```python
# BEFORE (correct)
def add(a: Number, b: Number) -> Number:
    return a + b

# AFTER (intentionally bad — no spaces around colon, extra spaces)
def add(a:Number,b:Number)->Number:
    return a+b
```

**Run:** `python -m black --check --diff app/`

**What you see:**
```
--- app/main.py
+++ app/main.py
@@ def add(a:Number,b:Number)->Number:
+def add(a: Number, b: Number) -> Number:
💥 1 file would be reformatted.
```

**Fix:** `python -m black app/`

---

### Mistake 2 — Unused Import (caught by: flake8)

Add this to the top of `app/main.py`:
```python
import os      # not used anywhere — flake8 will flag this
import json    # not used anywhere — flake8 will flag this
```

**Run:** `python -m flake8 app/`

**What you see:**
```
app/main.py:1:1: F401 'os' imported but unused
app/main.py:2:1: F401 'json' imported but unused
```

**Fix:** Delete the unused import lines.

---

### Mistake 3 — Missing Type Hint (caught by: mypy)

Change this function in `app/main.py`:
```python
# BEFORE (correct)
def add(a: Number, b: Number) -> Number:
    return a + b

# AFTER (missing type hints)
def add(a, b):
    return a + b
```

**Run:** `python -m mypy app/`

**What you see:**
```
app/main.py:15: error: Function is missing a type annotation
Found 1 error in 1 file
```

**Fix:** Restore the type hints.

---

### Mistake 4 — Weak Security Pattern (caught by: bandit)

Add this to `app/main.py` (do NOT commit this to real projects!):
```python
import subprocess

def run_command(user_input: str) -> str:
    result = subprocess.run(user_input, shell=True, capture_output=True)
    return result.stdout.decode()
```

**Run:** `python -m bandit -r app/ -ll`

**What you see:**
```
Issue: [B602:subprocess_popen_with_shell_equals_true]
   subprocess call with shell=True identified, security issue.
   Severity: High   Confidence: High
```

**Fix:** Never use `shell=True` with user input. Remove the function.

---

### Mistake 5 — Failing Test (caught by: pytest)

Change the expected value in a test:
```python
# tests/test_main.py  — find this test and break it:
def test_add_two_positive_integers(self) -> None:
    assert add(3, 4) == 999   # WRONG expected value
```

**Run:** `python -m pytest tests/ -v`

**What you see:**
```
FAILED tests/test_main.py::TestAdd::test_add_two_positive_integers
AssertionError: assert 7 == 999
1 failed, 19 passed
```

**Fix:** Restore the correct expected value `== 7`.

---

### Mistake 6 — Wrong Imports Order (caught by: isort)

Change the imports in `app/main.py` to wrong order:
```python
# WRONG ORDER
from typing import Union
import os          # stdlib should come before 'from typing'
```

**Run:** `python -m isort --check-only --diff app/`

**What you see:**
```
ERROR: app/main.py Imports are incorrectly sorted.
```

**Fix:** `python -m isort app/`

---

### Mistake 7 — Coverage Below Threshold (caught by: pytest-cov)

Comment out half the tests in `tests/test_main.py`:
```python
# class TestMultiply:   ← comment out this entire class
# class TestDivide:     ← and this one too
```

**Run:** `python -m pytest tests/ --cov=app --cov-fail-under=80`

**What you see:**
```
FAIL Required test coverage of 80% not reached. Total coverage: 52%
```

**Fix:** Uncomment the test classes.

---

## 📊 Quick Reference — All Commands

| Stage | Tool | Command |
|-------|------|---------|
| 1 | Run app | `python -m app.main` |
| 2 | pytest | `python -m pytest tests/ -v` |
| 3 | black | `python -m black --check --diff app/ tests/` |
| 4 | isort | `python -m isort --check-only --diff app/ tests/` |
| 5 | flake8 | `python -m flake8 app/ tests/` |
| 6 | mypy | `python -m mypy app/` |
| 7 | bandit | `python -m bandit -r app/ -ll` |
| 8 | pip-audit | `python -m pip_audit` |
| 9 | pytest-cov | `python -m pytest tests/ --cov=app --cov-report=term-missing --cov-fail-under=80` |
| 10 | build | `python -m build --outdir dist/` |

---

## 🔧 Tool Reference — What Each Tool Does

### pytest
| Field | Detail |
|-------|--------|
| **What it checks** | Runs all functions prefixed with `test_` and verifies `assert` statements |
| **Why in CI/CD** | Proves the code works as intended. First gate — if tests fail, the build stops |
| **Issues caught** | Logic errors, wrong return values, unhandled exceptions |
| **Pass signal** | `N passed in X.XXs` |
| **Fail signal** | `FAILED … AssertionError` |

---

### black
| Field | Detail |
|-------|--------|
| **What it checks** | File formatting: spacing, quotes, line length (88 chars), trailing commas |
| **Why in CI/CD** | Removes code-style debates; every commit looks identical regardless of editor |
| **Issues caught** | Inconsistent spacing, mixed quotes, lines over 88 characters |
| **Pass signal** | `All done! 2 files would be left unchanged.` |
| **Fail signal** | `1 file would be reformatted` + diff showing what must change |

---

### isort
| Field | Detail |
|-------|--------|
| **What it checks** | Import block ordering: stdlib → third-party → local |
| **Why in CI/CD** | Prevents unnecessary merge conflicts in import sections |
| **Issues caught** | Wrong import group order, unsorted imports within groups |
| **Pass signal** | No output (silence = success) |
| **Fail signal** | `ERROR: Imports are incorrectly sorted` |

---

### flake8
| Field | Detail |
|-------|--------|
| **What it checks** | PEP-8 style, unused imports (F401), undefined names (F821), line length |
| **Why in CI/CD** | Catches potential bugs (undefined variables) and style violations |
| **Issues caught** | Unused variables, missing whitespace, syntax errors |
| **Pass signal** | No output |
| **Fail signal** | `filename.py:line:col: CODE description` |

---

### mypy
| Field | Detail |
|-------|--------|
| **What it checks** | Type annotations — verifies types are used consistently across the codebase |
| **Why in CI/CD** | Catches type mismatches before runtime crashes in production |
| **Issues caught** | Missing annotations, passing `str` where `int` expected, wrong return type |
| **Pass signal** | `Success: no issues found in N source files` |
| **Fail signal** | `error: Argument 1 has incompatible type "str"; expected "int"` |

---

### bandit
| Field | Detail |
|-------|--------|
| **What it checks** | Security anti-patterns: hardcoded secrets, `eval()`, `shell=True`, weak crypto |
| **Why in CI/CD** | Security vulnerabilities must be caught *before* they reach production |
| **Issues caught** | SQL injection patterns, use of `subprocess` with user input, insecure random |
| **Pass signal** | `No issues identified.` |
| **Fail signal** | `Issue: [B602] subprocess call with shell=True … Severity: High` |

---

### pip-audit
| Field | Detail |
|-------|--------|
| **What it checks** | Compares installed packages against the PyPI Advisory Database (CVE database) |
| **Why in CI/CD** | A package that was safe last week may have a CVE published today |
| **Issues caught** | Known vulnerabilities in third-party libraries |
| **Pass signal** | `No known vulnerabilities found` |
| **Fail signal** | Lists package, version, CVE ID, and the version that fixes it |

---

### pytest-cov
| Field | Detail |
|-------|--------|
| **What it checks** | Percentage of application lines executed during the test run |
| **Why in CI/CD** | Enforces a minimum standard of test completeness (commonly 80%) |
| **Issues caught** | Functions or branches that have no tests at all |
| **Pass signal** | `Required test coverage of 80% reached. Total coverage: 88%` |
| **Fail signal** | `FAIL Required test coverage of 80% not reached. Total coverage: 52%` |

---

### python -m build
| Field | Detail |
|-------|--------|
| **What it checks** | Whether the project can be packaged into `.whl` and `.tar.gz` distributions |
| **Why in CI/CD** | If the build fails, the code cannot be deployed or published to PyPI |
| **Issues caught** | Missing metadata in `pyproject.toml`, broken entry points, import errors |
| **Pass signal** | `Successfully built project-1.0.0.tar.gz and project-1.0.0-py3-none-any.whl` |
| **Fail signal** | `ERROR: Missing 'name' field` or import-time errors |

---

## 🎤 Interview-Style Explanation

> *Use this to answer: "How do you ensure code quality before pushing to GitHub?"*

---

**Answer:**

"Before pushing any code to GitHub, I simulate the full CI/CD pipeline locally
by running the same quality gates that would run in GitHub Actions or Jenkins.

I start with **pytest** to confirm all unit tests pass — this is the most
fundamental check. No point running anything else if the logic is broken.

Next, I check **code formatting with Black** and **import ordering with isort**.
These tools are non-negotiable in a team environment because they eliminate
entire categories of merge conflicts and code review comments.

Then I run **flake8** for linting. It catches unused imports, undefined
variables, and style violations — things that look harmless but cause bugs
at runtime.

After that, **mypy** performs static type checking. Python is dynamically typed
by default, so mypy is what stops you from passing a string where a number is
expected — a class of bug that can be invisible until production.

Once the code itself is clean, I run **bandit** for security scanning. It
checks for dangerous patterns like `eval()`, `shell=True`, and hardcoded
secrets — things that could open the application to attack.

Then **pip-audit** scans all third-party dependencies for known CVEs. A single
outdated library has caused more than a few major data breaches.

I measure **test coverage with pytest-cov** and enforce a minimum of 80%.
Coverage doesn't guarantee bug-free code, but it ensures the important paths
are being exercised.

Finally, I run **python -m build** to confirm the project can be packaged
correctly. If the build stage fails, nothing can be deployed.

By running all of these locally, I catch issues in seconds rather than
finding out 15 minutes later through a failing CI pipeline. When my local
gate is green, I'm confident the pipeline in GitHub Actions will be green too.
This is how professional teams keep their main branch stable."

---

## 📝 Quick Cheat Sheet — Fix Common Failures

| Error Message | Tool | Fix |
|---------------|------|-----|
| `1 file would be reformatted` | black | Run `python -m black app/ tests/` |
| `Imports are incorrectly sorted` | isort | Run `python -m isort app/ tests/` |
| `F401 'x' imported but unused` | flake8 | Delete the unused import |
| `E501 line too long` | flake8 | Break the long line into two |
| `Function is missing a type annotation` | mypy | Add `-> ReturnType` and param types |
| `AssertionError` | pytest | Fix the function logic or the test expectation |
| `Severity: High … shell=True` | bandit | Remove `shell=True`, sanitise input |
| `known vulnerability in package` | pip-audit | `pip install --upgrade <package>` |
| `coverage of 80% not reached` | pytest-cov | Write tests for uncovered lines |
| `Missing 'name' field` | build | Fix `pyproject.toml` metadata |

---

*Happy learning! Remember: a local green pipeline is a team's best friend. 🟢*
trigger
