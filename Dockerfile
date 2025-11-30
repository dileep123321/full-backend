tage 1 — Builder
# ============================
FROM python:3.12-slim AS builder

WORKDIR /app

# Install system dependencies (required for pip to build wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install in a virtual environment
COPY app/requirements.txt .

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install -r requirements.txt


# ============================
# Stage 2 — Final Image
# ============================
FROM python:3.12-slim

WORKDIR /app

# Copy venv from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY app/ /app/

# Add venv to PATH
ENV PATH="/opt/venv/bin:$PATH"

# Expose the application port
EXPOSE 8080

# Production command (Gunicorn + UvicornWorker)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "src.main:app", "-k", "uvicorn.workers.UvicornWorker"]

