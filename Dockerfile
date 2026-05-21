FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN pip install black isort flake8 mypy pytest pytest-cov bandit pip-audit build

CMD ["python", "app/main.py"]