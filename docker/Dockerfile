FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/install -r requirements.txt

FROM python:3.12-slim

RUN useradd -r -u 10001 -g root appuser \
    && mkdir -p /app \
    && chown -R appuser:root /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:$PATH"

WORKDIR /app

COPY --from=builder /install /install
COPY app/ /app/

USER appuser

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "src.main:app", "-k", "uvicorn.workers.UvicornWorker"]
